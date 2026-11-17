using DFe.Utils;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NFe.Classes.Informacoes.Identificacao.Tipos;
using NFe.Classes.Protocolo;
using NFe.Classes.Servicos.Tipos;
using NFe.Servicos;
using NFe.Servicos.Retorno;
using NFe.Utils;
using NFe.Utils.Consulta;
using NFe.Utils.InformacoesSuplementares;
using NFe.Utils.NFe;
using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;
using NfeServer.Infrastructure.Certificados;
using ModeloDocumento = NfeServer.Domain.Fiscal.ModeloDocumento;
using ModeloZeus = DFe.Classes.Flags.ModeloDocumento;
using NotaZeus = NFe.Classes.NFe;

namespace NfeServer.Infrastructure.Fiscal;

/// <summary>Adaptador da porta <see cref="ISefazNFeGateway"/> sobre o Zeus DFe.NET.</summary>
internal sealed class ZeusSefazNFeGateway(
    ProvedorCertificados certificados,
    IOptions<OpcoesSefaz> opcoes,
    TimeProvider relogio,
    ILogger<ZeusSefazNFeGateway> logger) : ISefazNFeGateway
{
    private const string JustificativaContingencia = "Contingencia SVC ativada pelo emissor por indisponibilidade da SEFAZ autorizadora";

    public DocumentoPreparado Preparar(Empresa empresa, string xml, TipoContingencia contingencia)
    {
        var nfe = Carregar(XmlFiscal.ExtrairNFe(xml));
        var ide = nfe.infNFe.ide;
        var modelo = ide.mod switch
        {
            ModeloZeus.NFe => ModeloDocumento.NFe,
            ModeloZeus.NFCe => ModeloDocumento.NFCe,
            _ => throw new RegraNegocioException($"Modelo de documento não suportado: {(int)ide.mod}"),
        };

        if ((int)ide.tpAmb != (int)empresa.AmbienteSefaz)
            throw new RegraNegocioException(
                $"O ambiente do XML (tpAmb={(int)ide.tpAmb}) difere do configurado na empresa ({(int)empresa.AmbienteSefaz})");

        var emContingencia = AplicarContingencia(nfe, modelo, contingencia);
        var certificado = certificados.Obter(empresa);
        var cfg = ConfiguracaoZeus.Criar(empresa, opcoes.Value, modelo, ide.tpEmis);

        nfe.Signature = null;
        nfe.Assina(cfg, certificado);
        if (modelo == ModeloDocumento.NFCe)
            GerarQrCode(nfe, empresa, cfg);

        var chave = ChaveAcesso.Parse(nfe.infNFe.Id);
        return new DocumentoPreparado(chave.Valor, modelo, ide.serie, ide.nNF, empresa.AmbienteSefaz, ide.dhEmi,
            nfe.ObterXmlString(), emContingencia);
    }

    public RetornoAutorizacao Autorizar(Empresa empresa, DocumentoPreparado documento, bool envioAssincrono)
    {
        var nfe = Carregar(documento.XmlAssinado);
        using var servico = CriarServico(empresa, documento.Modelo, nfe.infNFe.ide.tpEmis);

        var indicador = envioAssincrono ? IndicadorSincronizacao.Assincrono : IndicadorSincronizacao.Sincrono;
        var envio = servico.NFeAutorizacao(NovoIdLote(), indicador, [nfe]);
        var retorno = envio.Retorno;
        logger.LogInformation("Autorização {Chave}: lote cStat {CStat} - {XMotivo}", documento.Chave, retorno.cStat, retorno.xMotivo);

        // Algumas UFs respondem 103 mesmo a pedidos síncronos.
        if (retorno.cStat == CodigosRetorno.LoteRecebido && retorno.infRec?.nRec is { Length: > 0 } recibo)
            return ConsultarRecibo(servico, recibo, documento.Chave, retorno.infRec.tMed);

        return retorno.protNFe?.infProt is { } infProt
            ? new RetornoAutorizacao(infProt.cStat, infProt.xMotivo, Protocolo(retorno.protNFe), envio.RetornoStr)
            : new RetornoAutorizacao(retorno.cStat, retorno.xMotivo, null, envio.RetornoStr);
    }

    public RetornoConsultaProtocolo ConsultarProtocolo(Empresa empresa, string chave)
    {
        var chaveAcesso = ChaveAcesso.Parse(chave);
        using var servico = CriarServico(empresa, chaveAcesso.Modelo, (TipoEmissao)chaveAcesso.TipoEmissao);
        var consulta = servico.NfeConsultaProtocolo(chaveAcesso.Valor);
        var retorno = consulta.Retorno;

        var cancelamento = retorno.procEventoNFe?
            .Select(p => p.retEvento?.infEvento)
            .FirstOrDefault(e => e is not null
                                 && e.tpEvento is NFeTipoEvento.TeNfeCancelamento or NFeTipoEvento.TeNfeCancelamentoSubstituicao
                                 && CodigosRetorno.EventoAceito(e.cStat));
        var cancelada = retorno.cStat is CodigosRetorno.Cancelada or CodigosRetorno.CanceladaForaPrazo || cancelamento is not null;

        logger.LogInformation("Consulta {Chave}: cStat {CStat} - {XMotivo}; cancelada={Cancelada}",
            chaveAcesso, retorno.cStat, retorno.xMotivo, cancelada);

        return new RetornoConsultaProtocolo(
            retorno.cStat,
            retorno.xMotivo,
            retorno.protNFe?.infProt is not null ? Protocolo(retorno.protNFe) : null,
            cancelada,
            cancelamento?.nProt,
            consulta.RetornoStr);
    }

    public string MontarXmlProcessado(string xmlAssinado, string protocoloXml) =>
        XmlFiscal.Envolver("nfeProc", xmlAssinado, protocoloXml);

    public RetornoEvento Cancelar(Empresa empresa, PedidoCancelamento pedido)
    {
        var chave = ChaveAcesso.Parse(pedido.Chave);
        using var servico = CriarServico(empresa, chave.Modelo, (TipoEmissao)chave.TipoEmissao);
        var retorno = servico.RecepcaoEventoCancelamento(NovoIdLote(), 1, pedido.ProtocoloAutorizacao, chave.Valor,
            pedido.Justificativa, chave.Cnpj, pedido.DataHoraEvento);
        return ParaRetornoEvento(retorno, "Cancelamento", chave.Valor);
    }

    public RetornoEvento EnviarCartaCorrecao(Empresa empresa, PedidoCartaCorrecao pedido)
    {
        var chave = ChaveAcesso.Parse(pedido.Chave);
        using var servico = CriarServico(empresa, chave.Modelo, (TipoEmissao)chave.TipoEmissao);
        var retorno = servico.RecepcaoEventoCartaCorrecao(NovoIdLote(), pedido.Sequencia, chave.Valor, pedido.Correcao,
            chave.Cnpj, pedido.DataHoraEvento);
        return ParaRetornoEvento(retorno, "Carta de correção", chave.Valor);
    }

    public RetornoInutilizacao Inutilizar(Empresa empresa, PedidoInutilizacao pedido)
    {
        using var servico = CriarServico(empresa, pedido.Modelo, TipoEmissao.teNormal);
        var retorno = servico.NfeInutilizacao(empresa.Cnpj, pedido.Ano, ConfiguracaoZeus.ParaZeus(pedido.Modelo), pedido.Serie,
            pedido.NumeroInicial, pedido.NumeroFinal, pedido.Justificativa);
        var info = retorno.Retorno.infInut;
        logger.LogInformation("Inutilização {Cnpj} série {Serie} {Inicial}-{Final}: cStat {CStat} - {XMotivo}",
            empresa.Cnpj, pedido.Serie, pedido.NumeroInicial, pedido.NumeroFinal, info.cStat, info.xMotivo);

        var xml = retorno.RetornoStr;
        if (info.cStat == CodigosRetorno.InutilizacaoHomologada
            && XmlFiscal.ElementoBruto(retorno.EnvioStr, "inutNFe") is { } pedidoXml
            && XmlFiscal.ElementoBruto(retorno.RetornoStr, "retInutNFe") is { } retornoXml)
        {
            xml = XmlFiscal.Envolver("procInutNFe", pedidoXml, retornoXml);
        }

        return new RetornoInutilizacao(info.cStat, info.xMotivo, info.nProt,
            info.dhRecbto is { } dh ? new DateTimeOffset(dh) : null, xml);
    }

    private ServicosNFe CriarServico(Empresa empresa, ModeloDocumento modelo, TipoEmissao tipoEmissao) =>
        new(ConfiguracaoZeus.Criar(empresa, opcoes.Value, modelo, tipoEmissao), certificados.Obter(empresa));

    private RetornoAutorizacao ConsultarRecibo(ServicosNFe servico, string recibo, string chave, int tempoMedioSegundos)
    {
        var espera = TimeSpan.FromSeconds(Math.Clamp(tempoMedioSegundos, 1, 5));
        for (var tentativa = 1; tentativa <= opcoes.Value.TentativasConsultaRecibo; tentativa++)
        {
            Thread.Sleep(espera);
            var consulta = servico.NFeRetAutorizacao(recibo);
            var retorno = consulta.Retorno;
            if (retorno.cStat == CodigosRetorno.LoteEmProcessamento)
                continue;

            var protocolo = retorno.protNFe?.FirstOrDefault(p => p.infProt?.chNFe == chave) ?? retorno.protNFe?.FirstOrDefault();
            return protocolo?.infProt is { } infProt
                ? new RetornoAutorizacao(infProt.cStat, infProt.xMotivo, Protocolo(protocolo), consulta.RetornoStr)
                : new RetornoAutorizacao(retorno.cStat, retorno.xMotivo, null, consulta.RetornoStr);
        }

        logger.LogWarning("Recibo {Recibo} ainda em processamento após {Tentativas} consultas", recibo, opcoes.Value.TentativasConsultaRecibo);
        return new RetornoAutorizacao(CodigosRetorno.LoteEmProcessamento,
            $"Lote em processamento na SEFAZ (recibo {recibo}); reenvie a nota para obter o resultado", null, string.Empty);
    }

    private bool AplicarContingencia(NotaZeus nfe, ModeloDocumento modelo, TipoContingencia contingencia)
    {
        var ide = nfe.infNFe.ide;
        if (ide.tpEmis != TipoEmissao.teNormal)
            return true; // o cliente já gerou o XML em contingência
        if (contingencia == TipoContingencia.Nenhuma || !ContingenciaSvc.Aplicavel(modelo))
            return false;

        // tpEmis faz parte da chave de acesso: o Id e o DV precisam ser recalculados.
        ide.tpEmis = contingencia == TipoContingencia.SvcAn ? TipoEmissao.teSVCAN : TipoEmissao.teSVCRS;
        ide.dhCont = relogio.GetLocalNow();
        ide.xJust = JustificativaContingencia;
        var chave = ChaveAcesso.Gerar((int)ide.cUF, ide.dhEmi, nfe.infNFe.emit.CNPJ, modelo, ide.serie, ide.nNF, (int)ide.tpEmis, ide.cNF);
        nfe.infNFe.Id = "NFe" + chave.Valor;
        ide.cDV = chave.Valor[^1] - '0';

        logger.LogWarning("Contingência {Tipo} aplicada; nova chave {Chave}", ide.tpEmis, chave);
        return true;
    }

    private void GerarQrCode(NotaZeus nfe, Empresa empresa, ConfiguracaoServico cfg)
    {
        if (!empresa.PossuiCsc)
        {
            if (nfe.infNFeSupl?.qrCode is { Length: > 0 })
                return; // QR Code gerado pelo cliente
            throw new RegraNegocioException("CSC e IdCSC não configurados na empresa; obrigatórios para NFC-e");
        }

        var versao = opcoes.Value.VersaoQrCodeNfce switch
        {
            1 => VersaoQrCode.QrCodeVersao1,
            3 => VersaoQrCode.QrCodeVersao3,
            _ => VersaoQrCode.QrCodeVersao2,
        };
        nfe.infNFeSupl = new NFe.Classes.infNFeSupl();
        nfe.infNFeSupl.qrCode = nfe.infNFeSupl.ObterUrlQrCode(nfe, versao, empresa.IdCsc, empresa.Csc, cfg.Certificado);
        nfe.infNFeSupl.urlChave = nfe.infNFeSupl.ObterUrlConsulta(nfe, versao);
    }

    private RetornoEvento ParaRetornoEvento(RetornoRecepcaoEvento retorno, string descricao, string chave)
    {
        var info = retorno.Retorno.retEvento?.FirstOrDefault()?.infEvento;
        if (info is null)
        {
            logger.LogWarning("{Evento} {Chave}: lote cStat {CStat} - {XMotivo}", descricao, chave, retorno.Retorno.cStat, retorno.Retorno.xMotivo);
            return new RetornoEvento(retorno.Retorno.cStat, retorno.Retorno.xMotivo, null, null, string.Empty, retorno.RetornoStr);
        }

        logger.LogInformation("{Evento} {Chave}: cStat {CStat} - {XMotivo}", descricao, chave, info.cStat, info.xMotivo);
        var xmlEvento = CodigosRetorno.EventoAceito(info.cStat) && retorno.ProcEventosNFe?.FirstOrDefault() is { } proc
            ? proc.ObterXmlString()
            : string.Empty;
        return new RetornoEvento(info.cStat, info.xMotivo, info.nProt, new DateTimeOffset(info.dhRegEvento), xmlEvento, retorno.RetornoStr);
    }

    private static NotaZeus Carregar(string xml)
    {
        try
        {
            return new NotaZeus().CarregarDeXmlString(xml);
        }
        catch (InvalidOperationException ex)
        {
            throw new RegraNegocioException($"Nota fiscal não pode ser lida a partir do XML informado: {ex.InnerException?.Message ?? ex.Message}");
        }
    }

    private static ProtocoloAutorizacao Protocolo(protNFe protocolo)
    {
        var info = protocolo.infProt;
        return new ProtocoloAutorizacao(info.chNFe, info.nProt ?? string.Empty, info.cStat, info.xMotivo, info.dhRecbto,
            info.digVal ?? string.Empty, FuncoesXml.ClasseParaXmlString(protocolo));
    }

    private static int NovoIdLote() => Random.Shared.Next(1, int.MaxValue);
}
