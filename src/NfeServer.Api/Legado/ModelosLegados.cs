using System.Text.Json.Serialization;

namespace NfeServer.Api.Legado;

// Contratos do servidor Delphi (model\*.pas e model\request\*.pas). Os nomes JSON são os
// nomes dos campos Delphi sem o prefixo F, inclusive os erros de digitação
// ("xmlProcesado", "dataProcesamemento", "contigencia"): os clientes dependem deles.

public sealed class RequisicaoLegada
{
    [JsonPropertyName("operacao")] public string? Operacao { get; set; }
}

public sealed class ValidacaoRequestLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("numero")] public int Numero { get; set; }
    [JsonPropertyName("serie")] public int Serie { get; set; }
    [JsonPropertyName("modelo")] public int Modelo { get; set; }
    /// <summary>XML em base64.</summary>
    [JsonPropertyName("xml")] public string? Xml { get; set; }
    [JsonPropertyName("txt")] public string? Txt { get; set; }
    [JsonPropertyName("lote")] public string? Lote { get; set; }
}

public sealed class ValidacaoResponseLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("numero")] public long Numero { get; set; }
    [JsonPropertyName("serie")] public int Serie { get; set; }
    [JsonPropertyName("modelo")] public int Modelo { get; set; }
    [JsonPropertyName("xmlProcesado")] public string XmlProcesado { get; set; } = string.Empty;
    [JsonPropertyName("chave")] public string Chave { get; set; } = string.Empty;
    [JsonPropertyName("xmlRetorno")] public string XmlRetorno { get; set; } = string.Empty;
    [JsonPropertyName("danfeBase64")] public string DanfeBase64 { get; set; } = string.Empty;
    [JsonPropertyName("xmotivo")] public string XMotivo { get; set; } = string.Empty;
    [JsonPropertyName("cstat")] public int CStat { get; set; }
    [JsonPropertyName("protocolo")] public string Protocolo { get; set; } = string.Empty;
    [JsonPropertyName("digito")] public string Digito { get; set; } = string.Empty;
    [JsonPropertyName("dataProcesamemento")] public DateTime DataProcesamemento { get; set; }
    [JsonPropertyName("dataValidacao")] public DateTime DataValidacao { get; set; }
}

public sealed class CancelamentoRequestLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("numero")] public int Numero { get; set; }
    [JsonPropertyName("serie")] public int Serie { get; set; }
    [JsonPropertyName("chave")] public string Chave { get; set; } = string.Empty;
    [JsonPropertyName("modelo")] public int Modelo { get; set; }
    [JsonPropertyName("ambiente")] public int Ambiente { get; set; }
    [JsonPropertyName("protocolo")] public string? Protocolo { get; set; }
    [JsonPropertyName("data")] public DateTime Data { get; set; }
    [JsonPropertyName("justificativa")] public string? Justificativa { get; set; }
}

/// <summary>TCancelamento: resposta do cancelamento e item da listagem.</summary>
public sealed class CancelamentoLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("numero")] public long Numero { get; set; }
    [JsonPropertyName("serie")] public int Serie { get; set; }
    [JsonPropertyName("chave")] public string Chave { get; set; } = string.Empty;
    [JsonPropertyName("ambiente")] public int Ambiente { get; set; }
    [JsonPropertyName("protocoloNota")] public string ProtocoloNota { get; set; } = string.Empty;
    [JsonPropertyName("protocoloCancelamento")] public string ProtocoloCancelamento { get; set; } = string.Empty;
    [JsonPropertyName("data")] public DateTime Data { get; set; }
    [JsonPropertyName("justificativa")] public string Justificativa { get; set; } = string.Empty;
    [JsonPropertyName("cstat")] public int CStat { get; set; }
    [JsonPropertyName("xmotivo")] public string XMotivo { get; set; } = string.Empty;
    [JsonPropertyName("xmlRetorno")] public string XmlRetorno { get; set; } = string.Empty;
    [JsonPropertyName("danfe")] public string Danfe { get; set; } = string.Empty;
}

public sealed class CartaCorrecaoRequestLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("chave")] public string Chave { get; set; } = string.Empty;
    [JsonPropertyName("dataHora")] public DateTime DataHora { get; set; }
    [JsonPropertyName("sequencia")] public int Sequencia { get; set; }
    [JsonPropertyName("xcorrecao")] public string? XCorrecao { get; set; }
}

public sealed class CartaCorrecaoLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("chave")] public string Chave { get; set; } = string.Empty;
    [JsonPropertyName("dataHora")] public DateTime DataHora { get; set; }
    [JsonPropertyName("sequencia")] public int Sequencia { get; set; }
    [JsonPropertyName("xcorrecao")] public string XCorrecao { get; set; } = string.Empty;
    [JsonPropertyName("xmlEvento")] public string XmlEvento { get; set; } = string.Empty;
    [JsonPropertyName("protocoloCCe")] public string ProtocoloCce { get; set; } = string.Empty;
    [JsonPropertyName("cstat")] public int CStat { get; set; }
    [JsonPropertyName("xmotivo")] public string XMotivo { get; set; } = string.Empty;
    [JsonPropertyName("danfe")] public string Danfe { get; set; } = string.Empty;
}

public sealed class InutilizacaoRequestLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("numeroInicial")] public int NumeroInicial { get; set; }
    [JsonPropertyName("numeroFinal")] public int NumeroFinal { get; set; }
    [JsonPropertyName("serie")] public int Serie { get; set; }
    [JsonPropertyName("modelo")] public int Modelo { get; set; }
    [JsonPropertyName("ano")] public int Ano { get; set; }
    [JsonPropertyName("justificativa")] public string? Justificativa { get; set; }
}

public sealed class InutilizacaoLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("numeroInicial")] public int NumeroInicial { get; set; }
    [JsonPropertyName("numeroFinal")] public int NumeroFinal { get; set; }
    [JsonPropertyName("serie")] public int Serie { get; set; }
    [JsonPropertyName("modelo")] public int Modelo { get; set; }
    [JsonPropertyName("ano")] public int Ano { get; set; }
    [JsonPropertyName("justificativa")] public string Justificativa { get; set; } = string.Empty;
    [JsonPropertyName("dhRecbto")] public DateTime DhRecbto { get; set; }
    [JsonPropertyName("protocolo")] public string Protocolo { get; set; } = string.Empty;
    [JsonPropertyName("xmlEvento")] public string XmlEvento { get; set; } = string.Empty;
    [JsonPropertyName("xmotivo")] public string XMotivo { get; set; } = string.Empty;
    [JsonPropertyName("cstat")] public int CStat { get; set; }
    [JsonPropertyName("danfe")] public string Danfe { get; set; } = string.Empty;
}

/// <summary>TNota: item da listagem de notas (XML sem base64, como no banco).</summary>
public sealed class NotaLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("numero")] public long Numero { get; set; }
    [JsonPropertyName("serie")] public int Serie { get; set; }
    [JsonPropertyName("chave")] public string Chave { get; set; } = string.Empty;
    [JsonPropertyName("dataEmissao")] public DateTime DataEmissao { get; set; }
    [JsonPropertyName("xml")] public string Xml { get; set; } = string.Empty;
    [JsonPropertyName("xmlRetorno")] public string XmlRetorno { get; set; } = string.Empty;
    [JsonPropertyName("status")] public int Status { get; set; }
    [JsonPropertyName("motivo")] public string Motivo { get; set; } = string.Empty;
    [JsonPropertyName("txt")] public string Txt { get; set; } = string.Empty;
    [JsonPropertyName("digitoval")] public string DigitoVal { get; set; } = string.Empty;
    [JsonPropertyName("dataValidacao")] public DateTime DataValidacao { get; set; }
    [JsonPropertyName("dataProcessamento")] public DateTime DataProcessamento { get; set; }
    [JsonPropertyName("protocolo")] public string Protocolo { get; set; } = string.Empty;
    [JsonPropertyName("danfe")] public string Danfe { get; set; } = string.Empty;
    [JsonPropertyName("cancelada")] public bool Cancelada { get; set; }
}

public sealed class EmpresaLegado
{
    [JsonPropertyName("cnpj")] public string Cnpj { get; set; } = string.Empty;
    [JsonPropertyName("razaoSocial")] public string RazaoSocial { get; set; } = string.Empty;
    [JsonPropertyName("endereco")] public string Endereco { get; set; } = string.Empty;
    [JsonPropertyName("bairro")] public string Bairro { get; set; } = string.Empty;
    [JsonPropertyName("cidade")] public string Cidade { get; set; } = string.Empty;
    [JsonPropertyName("codMunicipio")] public string CodMunicipio { get; set; } = string.Empty;
    [JsonPropertyName("complemento")] public string Complemento { get; set; } = string.Empty;
    [JsonPropertyName("uf")] public string Uf { get; set; } = string.Empty;
    [JsonPropertyName("numero")] public string Numero { get; set; } = string.Empty;
    [JsonPropertyName("telefone")] public string Telefone { get; set; } = string.Empty;
    [JsonPropertyName("inscricaoMunicipal")] public string InscricaoMunicipal { get; set; } = string.Empty;
    [JsonPropertyName("inscricaoEstadual")] public string InscricaoEstadual { get; set; } = string.Empty;
    [JsonPropertyName("nomecertificadoPfx")] public string NomeCertificadoPfx { get; set; } = string.Empty;
    /// <summary>Só entrada; nunca é devolvido nas listagens.</summary>
    [JsonPropertyName("certificadoPfx")] public string CertificadoPfx { get; set; } = string.Empty;
    /// <summary>Só entrada; nunca é devolvido nas listagens.</summary>
    [JsonPropertyName("senhaPfx")] public string SenhaPfx { get; set; } = string.Empty;
    [JsonPropertyName("validade")] public DateTime Validade { get; set; }
    [JsonPropertyName("ambiente")] public int Ambiente { get; set; }
    [JsonPropertyName("contigencia")] public int Contigencia { get; set; }
    /// <summary>Só entrada.</summary>
    [JsonPropertyName("csc")] public string Csc { get; set; } = string.Empty;
    [JsonPropertyName("idCsc")] public string IdCsc { get; set; } = string.Empty;
    [JsonPropertyName("possuiCertificado")] public bool PossuiCertificado { get; set; }
}

public sealed class InfoNfeLegado
{
    [JsonPropertyName("notasEmitidas")] public int NotasEmitidas { get; set; }
    [JsonPropertyName("notasCanceladas")] public int NotasCanceladas { get; set; }
    [JsonPropertyName("notasInutilizadas")] public int NotasInutilizadas { get; set; }
    [JsonPropertyName("errosEmissao")] public int ErrosEmissao { get; set; }
    [JsonPropertyName("dataUpdate")] public DateTime DataUpdate { get; set; }
    [JsonPropertyName("analissemensal")] public ListaLegada<AnaliseLegado> AnaliseMensal { get; set; } = new([]);
}

public sealed record AnaliseLegado(
    [property: JsonPropertyName("tipo")] string Tipo,
    [property: JsonPropertyName("valor")] double Valor,
    [property: JsonPropertyName("data")] DateTime Data);

public sealed class ChaveRequestLegado
{
    [JsonPropertyName("chave")] public string Chave { get; set; } = string.Empty;
}
