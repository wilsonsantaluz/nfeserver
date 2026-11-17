using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.Abstracoes;

/// <summary>
/// Porta para os web services da SEFAZ (NF-e 55 e NFC-e 65). Trabalha só com XML em
/// string para não vazar tipos da biblioteca fiscal (hoje Zeus DFe.NET) para as regras.
/// As chamadas são síncronas porque a biblioteca é síncrona.
/// </summary>
public interface ISefazNFeGateway
{
    /// <summary>Carrega o XML, aplica contingência SVC, assina e gera o QR Code da NFC-e.</summary>
    DocumentoPreparado Preparar(Empresa empresa, string xml, TipoContingencia contingencia);

    RetornoAutorizacao Autorizar(Empresa empresa, DocumentoPreparado documento, bool envioAssincrono);

    RetornoConsultaProtocolo ConsultarProtocolo(Empresa empresa, string chave);

    /// <summary>Monta o nfeProc preservando byte a byte o XML assinado.</summary>
    string MontarXmlProcessado(string xmlAssinado, string protocoloXml);

    RetornoEvento Cancelar(Empresa empresa, PedidoCancelamento pedido);

    RetornoEvento EnviarCartaCorrecao(Empresa empresa, PedidoCartaCorrecao pedido);

    RetornoInutilizacao Inutilizar(Empresa empresa, PedidoInutilizacao pedido);
}

public sealed record DocumentoPreparado(
    string Chave,
    ModeloDocumento Modelo,
    int Serie,
    long Numero,
    Ambiente Ambiente,
    DateTimeOffset DataEmissao,
    string XmlAssinado,
    bool EmContingencia);

public sealed record ProtocoloAutorizacao(
    string Chave,
    string NumeroProtocolo,
    int CStat,
    string XMotivo,
    DateTimeOffset DataRecebimento,
    string DigestValue,
    string ProtocoloXml);

public sealed record RetornoAutorizacao(int CStat, string XMotivo, ProtocoloAutorizacao? Protocolo, string XmlRetorno);

public sealed record RetornoConsultaProtocolo(
    int CStat,
    string XMotivo,
    ProtocoloAutorizacao? Protocolo,
    bool Cancelada,
    string? ProtocoloCancelamento,
    string XmlRetorno);

public sealed record PedidoCancelamento(string Chave, string ProtocoloAutorizacao, string Justificativa, DateTimeOffset DataHoraEvento);

public sealed record PedidoCartaCorrecao(string Chave, int Sequencia, string Correcao, DateTimeOffset DataHoraEvento);

public sealed record PedidoInutilizacao(ModeloDocumento Modelo, int Ano, int Serie, int NumeroInicial, int NumeroFinal, string Justificativa);

/// <param name="XmlEvento">procEventoNFe quando o evento foi registrado.</param>
public sealed record RetornoEvento(int CStat, string XMotivo, string? Protocolo, DateTimeOffset? DataRegistro, string XmlEvento, string XmlRetorno);

/// <param name="XmlProcessado">procInutNFe quando homologada; senão, o retorno da SEFAZ.</param>
public sealed record RetornoInutilizacao(int CStat, string XMotivo, string? Protocolo, DateTimeOffset? DataRecebimento, string XmlProcessado);
