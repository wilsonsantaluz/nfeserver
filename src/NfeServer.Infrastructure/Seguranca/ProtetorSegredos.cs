using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Options;

namespace NfeServer.Infrastructure.Seguranca;

public sealed class OpcoesSeguranca
{
    public const string Secao = "Seguranca";

    /// <summary>
    /// Criptografa senha do PFX e CSC no banco. Deixe desligado enquanto o servidor Delphi
    /// ler as mesmas coleções: ele só entende texto puro.
    /// </summary>
    public bool ProtegerSegredosNoBanco { get; set; }

    /// <summary>Pasta do anel de chaves do Data Protection (protegido por DPAPI no Windows).</summary>
    public string DiretorioChaves { get; set; } = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "NfeServer", "chaves");

    /// <summary>Chaves aceitas no cabeçalho X-Api-Key. Lista vazia desliga a autenticação (modo legado).</summary>
    public List<string> ApiKeys { get; set; } = [];
}

public interface IProtetorSegredos
{
    string Proteger(string valor);
    /// <summary>Aceita valores protegidos e, para compatibilidade, texto puro gravado pelo Delphi.</summary>
    string Abrir(string valor);
}

internal sealed class ProtetorSegredos(IDataProtectionProvider provider, IOptions<OpcoesSeguranca> opcoes) : IProtetorSegredos
{
    private const string Prefixo = "dp1:";
    private readonly IDataProtector _protector = provider.CreateProtector("NfeServer.Empresa.Segredos.v1");

    public string Proteger(string valor) =>
        !opcoes.Value.ProtegerSegredosNoBanco || string.IsNullOrEmpty(valor) || valor.StartsWith(Prefixo, StringComparison.Ordinal)
            ? valor
            : Prefixo + _protector.Protect(valor);

    public string Abrir(string valor) =>
        valor?.StartsWith(Prefixo, StringComparison.Ordinal) == true
            ? _protector.Unprotect(valor[Prefixo.Length..])
            : valor ?? string.Empty;
}
