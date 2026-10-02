using NfeServer.Domain.Entidades;

namespace NfeServer.Api.V2;

/// <param name="Xml">XML da NF-e/NFC-e (texto, sem base64).</param>
public sealed record EmitirNotaRequest(string Cnpj, string Xml);

public sealed record CancelarNotaRequest(string Cnpj, string Justificativa, string? Protocolo);

public sealed record CartaCorrecaoRequest(string Cnpj, string Correcao, int Sequencia = 1);

public sealed record InutilizarRequest(string Cnpj, int Modelo, int Ano, int Serie, int NumeroInicial, int NumeroFinal, string Justificativa);

public sealed record EmpresaRequest(
    string RazaoSocial, string Uf, int Ambiente, bool Contingencia,
    string? Endereco, string? Numero, string? Complemento, string? Bairro, string? Cidade, string? CodMunicipio,
    string? Telefone, string? InscricaoEstadual, string? InscricaoMunicipal,
    string? NomeCertificadoPfx, string? CertificadoPfxBase64, string? SenhaPfx, string? Csc, string? IdCsc);

public sealed record NotaResumoResponse(
    string Chave, string Cnpj, int Modelo, int Serie, long Numero, DateTime DataEmissao,
    int CStat, string Motivo, string Protocolo, DateTime? DataAutorizacao, bool Cancelada)
{
    public static NotaResumoResponse De(NotaFiscal n) => new(n.Chave, n.Cnpj, n.Modelo, n.Serie, n.Numero, n.DataEmissao,
        n.Status, n.Motivo, n.Protocolo, n.DataValidacao == default ? null : n.DataValidacao, n.Cancelada);
}

public sealed record NotaResponse(NotaResumoResponse Resumo, string Xml, string XmlRetorno, bool PossuiDanfe)
{
    public static NotaResponse De(NotaFiscal n) => new(NotaResumoResponse.De(n), n.Xml, n.XmlRetorno, n.Danfe.Length > 0);
}

public sealed record EventoResponse(string Chave, int CStat, string Motivo, string Protocolo, string Xml);

public sealed record InutilizacaoResponse(int CStat, string Motivo, string Protocolo, DateTime? DataRecebimento, string Xml);

public sealed record EmpresaResponse(
    string Cnpj, string RazaoSocial, string Uf, int Ambiente, bool Contingencia, string NomeCertificadoPfx,
    DateTime ValidadeCertificado, bool PossuiCertificado, bool PossuiCsc, string IdCsc)
{
    public static EmpresaResponse De(Empresa e) => new(e.Cnpj, e.RazaoSocial, e.Uf, e.Ambiente, e.ContingenciaAtiva,
        e.NomeCertificadoPfx, e.Validade, e.PossuiCertificado, e.PossuiCsc, e.IdCsc);
}
