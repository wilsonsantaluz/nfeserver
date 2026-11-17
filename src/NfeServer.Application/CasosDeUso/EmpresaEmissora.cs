using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.CasosDeUso;

internal static class EmpresaEmissora
{
    public static async Task<Empresa> ObterAsync(IEmpresaRepository empresas, string? cnpj, CancellationToken ct)
    {
        var normalizado = Cnpj.Normalizar(cnpj);
        var empresa = string.IsNullOrEmpty(normalizado) ? null : await empresas.ObterPorCnpjAsync(normalizado, ct);
        if (empresa is null)
            throw new RegraNegocioException($"Nenhuma empresa cadastrada com o cnpj informado {cnpj}");
        if (!empresa.PossuiCertificado)
            throw new RegraNegocioException("Arquivo de certificado ou senha não informados para a empresa");
        if (!Uf.EhValida(empresa.Uf))
            throw new RegraNegocioException("A UF da empresa não foi informada");
        return empresa;
    }

    public static string Base64(byte[]? conteudo) => conteudo is null ? string.Empty : Convert.ToBase64String(conteudo);
}
