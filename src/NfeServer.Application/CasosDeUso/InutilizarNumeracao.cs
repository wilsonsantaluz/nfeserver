using Microsoft.Extensions.Logging;
using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.CasosDeUso;

public sealed record SolicitacaoInutilizacao(
    string Cnpj, int Modelo, int Ano, int Serie, int NumeroInicial, int NumeroFinal, string? Justificativa);

public sealed class InutilizarNumeracao(
    IEmpresaRepository empresas,
    IInutilizacaoRepository inutilizacoes,
    ISefazNFeGateway sefaz,
    TimeProvider relogio,
    ILogger<InutilizarNumeracao> logger)
{
    public async Task<Inutilizacao> ExecutarAsync(SolicitacaoInutilizacao solicitacao, CancellationToken ct)
    {
        var inutilizacao = new Inutilizacao
        {
            Cnpj = Cnpj.Normalizar(solicitacao.Cnpj),
            Modelo = solicitacao.Modelo == 0 ? (int)ModeloDocumento.NFe : solicitacao.Modelo,
            Ano = solicitacao.Ano == 0 ? relogio.GetLocalNow().Year : solicitacao.Ano,
            Serie = solicitacao.Serie,
            NumeroInicial = solicitacao.NumeroInicial,
            NumeroFinal = solicitacao.NumeroFinal,
            Justificativa = solicitacao.Justificativa ?? string.Empty,
            CStat = CodigosRetorno.ErroInterno,
        };
        var enviado = false;

        try
        {
            var empresa = await EmpresaEmissora.ObterAsync(empresas, solicitacao.Cnpj, ct);
            var pedido = CriarPedido(inutilizacao);
            inutilizacao.Justificativa = pedido.Justificativa;

            enviado = true;
            var retorno = sefaz.Inutilizar(empresa, pedido);
            inutilizacao.CStat = retorno.CStat;
            inutilizacao.XMotivo = retorno.XMotivo;
            inutilizacao.XmlEvento = retorno.XmlProcessado;

            if (retorno.CStat is CodigosRetorno.InutilizacaoHomologada or CodigosRetorno.InutilizacaoDuplicada)
            {
                inutilizacao.Protocolo = retorno.Protocolo ?? string.Empty;
                inutilizacao.DhRecbto = retorno.DataRecebimento?.DateTime ?? default;
            }
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogError(ex, "Erro ao inutilizar {Cnpj} série {Serie} {Inicial}-{Final}",
                inutilizacao.Cnpj, inutilizacao.Serie, inutilizacao.NumeroInicial, inutilizacao.NumeroFinal);
            inutilizacao.CStat = CodigosRetorno.ErroInterno;
            inutilizacao.XMotivo = ex.Message;
        }

        if (enviado && inutilizacao.CStat != CodigosRetorno.InutilizacaoDuplicada)
            await Persistencia.GravarComSegurancaAsync(() => inutilizacoes.GravarAsync(inutilizacao, ct), logger,
                $"inutilização {inutilizacao.Cnpj} {inutilizacao.Serie}/{inutilizacao.NumeroInicial}-{inutilizacao.NumeroFinal}", ct);
        return inutilizacao;
    }

    private static PedidoInutilizacao CriarPedido(Inutilizacao inutilizacao)
    {
        if (inutilizacao.Modelo is not ((int)ModeloDocumento.NFe or (int)ModeloDocumento.NFCe))
            throw new RegraNegocioException($"Modelo inválido para inutilização: {inutilizacao.Modelo}");
        if (inutilizacao.Serie is < 0 or > 999)
            throw new RegraNegocioException($"Série inválida: {inutilizacao.Serie}");
        if (inutilizacao.NumeroInicial <= 0 || inutilizacao.NumeroFinal < inutilizacao.NumeroInicial)
            throw new RegraNegocioException("Faixa de numeração inválida");

        return new PedidoInutilizacao(
            (ModeloDocumento)inutilizacao.Modelo,
            inutilizacao.Ano % 100, // o leiaute pede o ano com 2 dígitos
            inutilizacao.Serie,
            inutilizacao.NumeroInicial,
            inutilizacao.NumeroFinal,
            Justificativa.Validar(inutilizacao.Justificativa));
    }
}
