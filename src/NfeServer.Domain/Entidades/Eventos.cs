namespace NfeServer.Domain.Entidades;

public sealed class Cancelamento
{
    public string Cnpj { get; set; } = string.Empty;
    public long Numero { get; set; }
    public int Serie { get; set; }
    public string Chave { get; set; } = string.Empty;
    public int Ambiente { get; set; }
    public string ProtocoloNota { get; set; } = string.Empty;
    public string ProtocoloCancelamento { get; set; } = string.Empty;
    public DateTime Data { get; set; }
    public string Justificativa { get; set; } = string.Empty;
    public int CStat { get; set; }
    public string XMotivo { get; set; } = string.Empty;
    /// <summary>procEventoNFe do cancelamento quando aceito; senão, o retorno bruto da SEFAZ.</summary>
    public string XmlRetorno { get; set; } = string.Empty;
    public string Danfe { get; set; } = string.Empty;
}

public sealed class CartaCorrecao
{
    public string Cnpj { get; set; } = string.Empty;
    public string Chave { get; set; } = string.Empty;
    public DateTime DataHora { get; set; }
    public int Sequencia { get; set; }
    public string XCorrecao { get; set; } = string.Empty;
    public string XmlEvento { get; set; } = string.Empty;
    public int CStat { get; set; }
    public string XMotivo { get; set; } = string.Empty;
    public string ProtocoloCce { get; set; } = string.Empty;
    public string Danfe { get; set; } = string.Empty;
}

public sealed class Inutilizacao
{
    public string Cnpj { get; set; } = string.Empty;
    public int NumeroInicial { get; set; }
    public int NumeroFinal { get; set; }
    public int Serie { get; set; }
    public int Modelo { get; set; }
    public int Ano { get; set; }
    public string Justificativa { get; set; } = string.Empty;
    public string Protocolo { get; set; } = string.Empty;
    public string XMotivo { get; set; } = string.Empty;
    public int CStat { get; set; }
    public string XmlEvento { get; set; } = string.Empty;
    public string Danfe { get; set; } = string.Empty;
    public DateTime DhRecbto { get; set; }
}
