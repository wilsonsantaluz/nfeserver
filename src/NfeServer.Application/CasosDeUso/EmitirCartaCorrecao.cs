using Microsoft.Extensions.Logging;
using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.CasosDeUso;

public sealed record SolicitacaoCartaCorrecao(string Cnpj, string Chave, int Sequencia, string? Correcao, DateTime? DataHora);

public sealed class EmitirCartaCorrecao(
    IEmpresaRepository empresas,
    INotaFiscalRepository notas,
    ICartaCorrecaoRepository cartas,
    ISefazNFeGateway sefaz,
    IDanfeService danfe,
    TimeProvider relogio,
    ILogger<EmitirCartaCorrecao> logger)
{
    private const int SequenciaMaxima = 20;

    public async Task<CartaCorrecao> ExecutarAsync(SolicitacaoCartaCorrecao solicitacao, CancellationToken ct)
    {
        var carta = new CartaCorrecao
        {
            Cnpj = Cnpj.Normalizar(solicitacao.Cnpj),
            Chave = solicitacao.Chave?.Trim() ?? string.Empty,
            DataHora = solicitacao.DataHora ?? relogio.GetLocalNow().DateTime,
            Sequencia = solicitacao.Sequencia <= 0 ? 1 : solicitacao.Sequencia,
            XCorrecao = solicitacao.Correcao ?? string.Empty,
            CStat = CodigosRetorno.ErroInterno,
        };
        var enviado = false;

        try
        {
            var empresa = await EmpresaEmissora.ObterAsync(empresas, solicitacao.Cnpj, ct);
            var chave = ChaveAcesso.Parse(solicitacao.Chave);
            if (chave.Modelo != ModeloDocumento.NFe)
                throw new RegraNegocioException("Carta de correção não é permitida para NFC-e (modelo 65)");
            if (carta.Sequencia > SequenciaMaxima)
                throw new RegraNegocioException($"Sequência da carta de correção deve estar entre 1 e {SequenciaMaxima}");
            carta.Chave = chave.Valor;
            carta.XCorrecao = Justificativa.ValidarCorrecao(solicitacao.Correcao);

            var agora = relogio.GetLocalNow();
            var dataHora = solicitacao.DataHora is { } d && d <= agora.DateTime ? new DateTimeOffset(d, agora.Offset) : agora;

            enviado = true;
            var retorno = sefaz.EnviarCartaCorrecao(empresa, new PedidoCartaCorrecao(chave.Valor, carta.Sequencia, carta.XCorrecao, dataHora));
            carta.CStat = retorno.CStat;
            carta.XMotivo = retorno.XMotivo;
            carta.XmlEvento = retorno.XmlRetorno;

            if (CodigosRetorno.EventoAceito(retorno.CStat))
            {
                carta.ProtocoloCce = retorno.Protocolo ?? string.Empty;
                if (!string.IsNullOrEmpty(retorno.XmlEvento))
                    carta.XmlEvento = retorno.XmlEvento;
                var nota = await notas.ObterPorChaveAsync(chave.Valor, ct);
                if (nota is { Xml.Length: > 0 } && !string.IsNullOrEmpty(retorno.XmlEvento))
                    carta.Danfe = EmpresaEmissora.Base64(danfe.GerarEvento(nota.Xml, retorno.XmlEvento));
            }
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogError(ex, "Erro ao emitir carta de correção {Chave}", carta.Chave);
            carta.CStat = CodigosRetorno.ErroInterno;
            carta.XMotivo = ex.Message;
        }

        if (enviado && carta.CStat != CodigosRetorno.EventoDuplicado)
            await Persistencia.GravarComSegurancaAsync(() => cartas.GravarAsync(carta, ct), logger, carta.Chave, ct);
        return carta;
    }
}
