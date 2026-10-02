using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using Microsoft.Extensions.Caching.Memory;
using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;

namespace NfeServer.Infrastructure.Certificados;

/// <summary>
/// Carrega o A1 em memória e mantém em cache por empresa. O Delphi regravava o PFX em disco
/// com nome fixo a cada requisição (concorrência entre requisições da mesma empresa).
/// </summary>
internal sealed class ProvedorCertificados(IMemoryCache cache, TimeProvider relogio)
{
    private static readonly TimeSpan Expiracao = TimeSpan.FromMinutes(30);

    public X509Certificate2 Obter(Empresa empresa)
    {
        var chaveCache = $"cert:{empresa.Cnpj}:{Hash(empresa.CertificadoPfx, empresa.SenhaPfx)}";
        var certificado = cache.GetOrCreate(chaveCache, entrada =>
        {
            entrada.SlidingExpiration = Expiracao;
            entrada.RegisterPostEvictionCallback((_, valor, _, _) => (valor as X509Certificate2)?.Dispose());
            return Carregar(empresa.CertificadoPfx, empresa.SenhaPfx, ArmazenamentoParaUso);
        })!;

        if (certificado.NotAfter < relogio.GetLocalNow().DateTime)
            throw new RegraNegocioException($"O certificado está vencido desde {certificado.NotAfter:dd/MM/yyyy}");
        return certificado;
    }

    /// <summary>
    /// No Windows o SChannel não usa chave efêmera na autenticação TLS mútua com a SEFAZ,
    /// por isso MachineKeySet (o contêiner é removido no Dispose).
    /// </summary>
    private static X509KeyStorageFlags ArmazenamentoParaUso =>
        OperatingSystem.IsWindows() ? X509KeyStorageFlags.MachineKeySet : X509KeyStorageFlags.EphemeralKeySet;

    internal static X509Certificate2 Carregar(string pfxBase64, string senha, X509KeyStorageFlags flags)
    {
        byte[] bytes;
        try
        {
            bytes = Convert.FromBase64String(pfxBase64);
        }
        catch (FormatException ex)
        {
            throw new RegraNegocioException($"O certificado não pode ser decodificado: {ex.Message}");
        }

        try
        {
            return new X509Certificate2(bytes, senha, flags);
        }
        catch (CryptographicException ex)
        {
            throw new RegraNegocioException($"O certificado não pode ser carregado (senha incorreta ou arquivo inválido): {ex.Message}");
        }
    }

    private static string Hash(string pfx, string senha) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(pfx + "\0" + senha)))[..16];
}

internal sealed class InspetorCertificado : ICertificadoInspector
{
    public InformacoesCertificado Inspecionar(string pfxBase64, string senha)
    {
        using var certificado = ProvedorCertificados.Carregar(pfxBase64, senha, X509KeyStorageFlags.EphemeralKeySet);
        if (!certificado.HasPrivateKey)
            throw new RegraNegocioException("O arquivo pfx não contém a chave privada");
        return new InformacoesCertificado(certificado.GetNameInfo(X509NameType.SimpleName, false), certificado.NotAfter);
    }
}
