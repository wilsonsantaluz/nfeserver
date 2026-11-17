using NfeServer.Application.Abstracoes;
using NfeServer.Application.Consultas;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.CasosDeUso;

public sealed class GerenciarEmpresas(IEmpresaRepository empresas, ICertificadoInspector certificados)
{
    /// <summary>
    /// Grava ou atualiza. Certificado, senha e CSC omitidos mantêm os valores já gravados
    /// (as listagens não devolvem mais esses segredos). A validade vem do próprio PFX.
    /// </summary>
    public async Task<string> GravarAsync(Empresa dados, CancellationToken ct)
    {
        dados.Cnpj = Cnpj.Normalizar(dados.Cnpj);
        var existente = string.IsNullOrEmpty(dados.Cnpj) ? null : await empresas.ObterPorCnpjAsync(dados.Cnpj, ct);
        if (existente is not null)
            dados.PreservarSegredosDe(existente);

        dados.Validar();
        dados.Validade = certificados.Inspecionar(dados.CertificadoPfx, dados.SenhaPfx).ValidoAte;

        await empresas.GravarAsync(dados, ct);
        return $"Empresa {dados.Cnpj} gravada/atualizada";
    }

    public async Task<string> ExcluirAsync(string? cnpj, CancellationToken ct)
    {
        var normalizado = Cnpj.Normalizar(cnpj);
        if (string.IsNullOrEmpty(normalizado))
            throw new RegraNegocioException("Cnpj não informado");
        if (!await empresas.ExcluirAsync(normalizado, ct))
            throw new RegraNegocioException($"Empresa {normalizado} não encontrada");
        return $"Empresa {normalizado} excluida";
    }

    public Task<IReadOnlyList<Empresa>> ListarAsync(FiltroConsulta filtro, CancellationToken ct) => empresas.ListarAsync(filtro, ct);
}
