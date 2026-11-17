using Microsoft.Extensions.Logging;
using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.CasosDeUso;

public sealed record SolicitacaoCancelamento(
    string Cnpj, string Chave, string? Protocolo, string? Justificativa, DateTime? Data, long Numero, int Serie, int Ambiente);

/// <summary>Porta de TServiceCancelar (Delphi), sem o protocolo fictício que ele inventava.</summary>
public sealed class CancelarNotaFiscal(
    IEmpresaRepository empresas,
    INotaFiscalRepository notas,
    ICancelamentoRepository cancelamentos,
    ISefazNFeGateway sefaz,
    IDanfeService danfe,
    TimeProvider relogio,
    ILogger<CancelarNotaFiscal> logger)
{
    public async Task<Cancelamento> ExecutarAsync(SolicitacaoCancelamento solicitacao, CancellationToken ct)
    {
        var cancelamento = new Cancelamento
        {
            Cnpj = Cnpj.Normalizar(solicitacao.Cnpj),
            Chave = solicitacao.Chave?.Trim() ?? string.Empty,
            Numero = solicitacao.Numero,
            Serie = solicitacao.Serie,
            Ambiente = solicitacao.Ambiente,
            ProtocoloNota = solicitacao.Protocolo?.Trim() ?? string.Empty,
            Justificativa = solicitacao.Justificativa ?? string.Empty,
            Data = solicitacao.Data ?? relogio.GetLocalNow().DateTime,
            CStat = CodigosRetorno.ErroInterno,
        };
        var enviado = false;

        try
        {
            var empresa = await EmpresaEmissora.ObterAsync(empresas, solicitacao.Cnpj, ct);
            var chave = ChaveAcesso.Parse(solicitacao.Chave);
            var justificativa = Justificativa.Validar(solicitacao.Justificativa);
            var nota = await notas.ObterPorChaveAsync(chave.Valor, ct);

            cancelamento.Chave = chave.Valor;
            cancelamento.Justificativa = justificativa;
            cancelamento.Numero = cancelamento.Numero == 0 ? chave.Numero : cancelamento.Numero;
            cancelamento.Serie = cancelamento.Serie == 0 ? chave.Serie : cancelamento.Serie;
            cancelamento.Ambiente = cancelamento.Ambiente == 0 ? (int)empresa.AmbienteSefaz : cancelamento.Ambiente;
            if (string.IsNullOrEmpty(cancelamento.ProtocoloNota))
                cancelamento.ProtocoloNota = nota?.Protocolo is { Length: > 0 } p
                    ? p
                    : throw new RegraNegocioException("Protocolo de autorização não informado e a nota não foi encontrada na base");

            enviado = true;
            var retorno = sefaz.Cancelar(empresa, new PedidoCancelamento(chave.Valor, cancelamento.ProtocoloNota, justificativa,
                DataHoraEvento(solicitacao.Data)));

            if (retorno.CStat == CodigosRetorno.DataHoraEventoRejeitada)
            {
                logger.LogInformation("Cancelamento {Chave} rejeitado por data/hora ({CStat}); reenviando com a hora atual", chave, retorno.CStat);
                retorno = sefaz.Cancelar(empresa, new PedidoCancelamento(chave.Valor, cancelamento.ProtocoloNota, justificativa,
                    relogio.GetLocalNow()));
            }

            cancelamento.CStat = retorno.CStat;
            cancelamento.XMotivo = retorno.XMotivo;
            cancelamento.XmlRetorno = retorno.XmlRetorno;

            if (CodigosRetorno.EventoAceito(retorno.CStat))
            {
                cancelamento.ProtocoloCancelamento = retorno.Protocolo ?? string.Empty;
                if (!string.IsNullOrEmpty(retorno.XmlEvento))
                    cancelamento.XmlRetorno = retorno.XmlEvento;
                await notas.MarcarCanceladaAsync(chave.Valor, ct);
                if (nota is { Xml.Length: > 0 } && !string.IsNullOrEmpty(retorno.XmlEvento))
                    cancelamento.Danfe = EmpresaEmissora.Base64(danfe.GerarEvento(nota.Xml, retorno.XmlEvento));
            }
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogError(ex, "Erro ao cancelar {Chave}", cancelamento.Chave);
            cancelamento.CStat = CodigosRetorno.ErroInterno;
            cancelamento.XMotivo = ex.Message;
        }

        if (enviado && cancelamento.CStat != CodigosRetorno.EventoDuplicado)
            await Persistencia.GravarComSegurancaAsync(() => cancelamentos.GravarAsync(cancelamento, ct), logger, cancelamento.Chave, ct);
        return cancelamento;
    }

    /// <summary>
    /// O Delphi usava a data (sem hora) do pedido, quase sempre rejeitada com 577.
    /// Usa a data informada só quando ela tem hora e não está no futuro.
    /// </summary>
    private DateTimeOffset DataHoraEvento(DateTime? informada)
    {
        var agora = relogio.GetLocalNow();
        if (informada is { } data && data.TimeOfDay != TimeSpan.Zero && data <= agora.DateTime)
            return new DateTimeOffset(data, agora.Offset);
        return agora;
    }
}
