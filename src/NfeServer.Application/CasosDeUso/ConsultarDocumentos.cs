using NfeServer.Application.Abstracoes;
using NfeServer.Application.Consultas;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.CasosDeUso;

public sealed class ConsultarDocumentos(
    INotaFiscalRepository notas,
    ICancelamentoRepository cancelamentos,
    IInutilizacaoRepository inutilizacoes,
    ICartaCorrecaoRepository cartas,
    IDashboardConsultas dashboard,
    IDanfeService danfe)
{
    public Task<IReadOnlyList<NotaFiscal>> ListarNotasAsync(FiltroConsulta filtro, CancellationToken ct) => notas.ListarAsync(filtro, ct);
    public Task<IReadOnlyList<Cancelamento>> ListarCancelamentosAsync(FiltroConsulta filtro, CancellationToken ct) => cancelamentos.ListarAsync(filtro, ct);
    public Task<IReadOnlyList<Inutilizacao>> ListarInutilizacoesAsync(FiltroConsulta filtro, CancellationToken ct) => inutilizacoes.ListarAsync(filtro, ct);
    public Task<IReadOnlyList<CartaCorrecao>> ListarCartasCorrecaoAsync(FiltroConsulta filtro, CancellationToken ct) => cartas.ListarAsync(filtro, ct);
    public Task<ResumoDashboard> ObterResumoAsync(CancellationToken ct) => dashboard.ObterResumoAsync(ct);

    public async Task<NotaFiscal> ObterNotaAsync(string? chave, CancellationToken ct) =>
        await notas.ObterPorChaveAsync(ChaveAcesso.Parse(chave).Valor, ct)
        ?? throw new RegraNegocioException($"Nota {chave} não encontrada");

    /// <summary>DANFE em base64: o gravado na nota ou, se ausente, gerado a partir do nfeProc.</summary>
    public async Task<string> ObterDanfeAsync(string? chave, CancellationToken ct)
    {
        var nota = await ObterNotaAsync(chave, ct);
        if (!string.IsNullOrEmpty(nota.Danfe))
            return nota.Danfe;
        if (!nota.PossuiProtocolo)
            throw new RegraNegocioException($"Nota {nota.Chave} não está autorizada");

        var modelo = ChaveAcesso.Parse(nota.Chave).Modelo;
        return EmpresaEmissora.Base64(danfe.GerarDanfe(nota.Xml, modelo))
            is { Length: > 0 } base64 ? base64 : throw new RegraNegocioException("Não foi possível gerar o DANFE");
    }
}
