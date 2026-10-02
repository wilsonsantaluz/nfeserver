using System.Text;
using NfeServer.Domain.Entidades;

namespace NfeServer.Api.Legado;

internal static class MapeamentoLegado
{
    public static string Base64(string? texto) =>
        string.IsNullOrEmpty(texto) ? string.Empty : Convert.ToBase64String(Encoding.UTF8.GetBytes(texto));

    public static string DeBase64(string? base64)
    {
        if (string.IsNullOrWhiteSpace(base64))
            return string.Empty;
        try
        {
            return Encoding.UTF8.GetString(Convert.FromBase64String(base64.Trim()));
        }
        catch (FormatException)
        {
            throw new Domain.Comum.RegraNegocioException("O campo xml deve conter o XML da nota em base64");
        }
    }

    public static ValidacaoResponseLegado ParaValidacao(NotaFiscal nota, int modeloSolicitado)
    {
        var resposta = new ValidacaoResponseLegado
        {
            Cnpj = nota.Cnpj,
            Numero = nota.Numero,
            Serie = nota.Serie,
            Modelo = nota.Modelo == 0 ? modeloSolicitado : nota.Modelo,
            Chave = nota.Chave,
            DanfeBase64 = nota.Danfe,
            XMotivo = nota.Motivo,
            CStat = nota.Status,
            Protocolo = nota.Protocolo,
            Digito = nota.DigitoVal,
            DataProcesamemento = nota.DataProcessamento,
            DataValidacao = nota.DataValidacao,
        };
        // Mesmo critério do Delphi: XMLs só depois que a nota chegou a ser processada.
        if (nota.DataProcessamento != default)
        {
            resposta.XmlProcesado = Base64(nota.Xml);
            resposta.XmlRetorno = Base64(nota.XmlRetorno);
        }
        return resposta;
    }

    public static CancelamentoLegado ParaLegado(Cancelamento c, bool xmlEmBase64) => new()
    {
        Cnpj = c.Cnpj,
        Numero = c.Numero,
        Serie = c.Serie,
        Chave = c.Chave,
        Ambiente = c.Ambiente,
        ProtocoloNota = c.ProtocoloNota,
        ProtocoloCancelamento = c.ProtocoloCancelamento,
        Data = c.Data,
        Justificativa = c.Justificativa,
        CStat = c.CStat,
        XMotivo = c.XMotivo,
        XmlRetorno = xmlEmBase64 ? Base64(c.XmlRetorno) : c.XmlRetorno,
        Danfe = c.Danfe,
    };

    public static CartaCorrecaoLegado ParaLegado(CartaCorrecao c, bool xmlEmBase64) => new()
    {
        Cnpj = c.Cnpj,
        Chave = c.Chave,
        DataHora = c.DataHora,
        Sequencia = c.Sequencia,
        XCorrecao = c.XCorrecao,
        XmlEvento = xmlEmBase64 ? Base64(c.XmlEvento) : c.XmlEvento,
        ProtocoloCce = c.ProtocoloCce,
        CStat = c.CStat,
        XMotivo = c.XMotivo,
        Danfe = c.Danfe,
    };

    public static InutilizacaoLegado ParaLegado(Inutilizacao i, bool xmlEmBase64) => new()
    {
        Cnpj = i.Cnpj,
        NumeroInicial = i.NumeroInicial,
        NumeroFinal = i.NumeroFinal,
        Serie = i.Serie,
        Modelo = i.Modelo,
        Ano = i.Ano,
        Justificativa = i.Justificativa,
        DhRecbto = i.DhRecbto,
        Protocolo = i.Protocolo,
        XmlEvento = xmlEmBase64 ? Base64(i.XmlEvento) : i.XmlEvento,
        XMotivo = i.XMotivo,
        CStat = i.CStat,
        Danfe = i.Danfe,
    };

    public static NotaLegado ParaLegado(NotaFiscal n) => new()
    {
        Cnpj = n.Cnpj,
        Numero = n.Numero,
        Serie = n.Serie,
        Chave = n.Chave,
        DataEmissao = n.DataEmissao,
        Xml = n.Xml,
        XmlRetorno = n.XmlRetorno,
        Status = n.Status,
        Motivo = n.Motivo,
        Txt = n.Txt,
        DigitoVal = n.DigitoVal,
        DataValidacao = n.DataValidacao,
        DataProcessamento = n.DataProcessamento,
        Protocolo = n.Protocolo,
        Danfe = n.Danfe,
        Cancelada = n.Cancelada,
    };

    /// <summary>Sem PFX, senha e CSC: o Delphi devolvia os três a qualquer GET.</summary>
    public static EmpresaLegado ParaLegado(Empresa e) => new()
    {
        Cnpj = e.Cnpj,
        RazaoSocial = e.RazaoSocial,
        Endereco = e.Endereco,
        Bairro = e.Bairro,
        Cidade = e.Cidade,
        CodMunicipio = e.CodMunicipio,
        Complemento = e.Complemento,
        Uf = e.Uf,
        Numero = e.Numero,
        Telefone = e.Telefone,
        InscricaoMunicipal = e.InscricaoMunicipal,
        InscricaoEstadual = e.InscricaoEstadual,
        NomeCertificadoPfx = e.NomeCertificadoPfx,
        Validade = e.Validade,
        Ambiente = e.Ambiente,
        Contigencia = e.Contigencia,
        IdCsc = e.IdCsc,
        PossuiCertificado = e.PossuiCertificado,
    };

    public static Empresa ParaDominio(EmpresaLegado e) => new()
    {
        Cnpj = e.Cnpj,
        RazaoSocial = e.RazaoSocial,
        Endereco = e.Endereco,
        Bairro = e.Bairro,
        Cidade = e.Cidade,
        CodMunicipio = e.CodMunicipio,
        Complemento = e.Complemento,
        Uf = e.Uf,
        Numero = e.Numero,
        Telefone = e.Telefone,
        InscricaoMunicipal = e.InscricaoMunicipal,
        InscricaoEstadual = e.InscricaoEstadual,
        NomeCertificadoPfx = e.NomeCertificadoPfx,
        CertificadoPfx = e.CertificadoPfx,
        SenhaPfx = e.SenhaPfx,
        Validade = e.Validade,
        Ambiente = e.Ambiente,
        Contigencia = e.Contigencia,
        Csc = e.Csc,
        IdCsc = e.IdCsc,
    };

    public static InfoNfeLegado ParaLegado(ResumoDashboard r) => new()
    {
        NotasEmitidas = r.NotasEmitidas,
        NotasCanceladas = r.NotasCanceladas,
        NotasInutilizadas = r.NotasInutilizadas,
        ErrosEmissao = r.ErrosEmissao,
        DataUpdate = r.DataUpdate,
        AnaliseMensal = new ListaLegada<AnaliseLegado>(r.Analises.Select(a => new AnaliseLegado(a.Tipo, a.Valor, a.Data)).ToList()),
    };
}
