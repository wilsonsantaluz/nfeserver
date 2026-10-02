namespace NfeServer.Domain.Entidades;

public sealed class NotaFiscal
{
    public string Cnpj { get; set; } = string.Empty;
    public long Numero { get; set; }
    public int Serie { get; set; }
    public int Modelo { get; set; }
    public int Ambiente { get; set; }
    public string Chave { get; set; } = string.Empty;
    public DateTime DataEmissao { get; set; }
    /// <summary>XML assinado ou, depois de autorizado, o nfeProc.</summary>
    public string Xml { get; set; } = string.Empty;
    public string XmlRetorno { get; set; } = string.Empty;
    public string Txt { get; set; } = string.Empty;
    public int Status { get; set; }
    public string Motivo { get; set; } = string.Empty;
    public DateTime DataValidacao { get; set; }
    public DateTime DataProcessamento { get; set; }
    public string Protocolo { get; set; } = string.Empty;
    public string DigitoVal { get; set; } = string.Empty;
    public bool Cancelada { get; set; }
    /// <summary>PDF do DANFE em base64.</summary>
    public string Danfe { get; set; } = string.Empty;

    public bool PossuiProtocolo => !string.IsNullOrEmpty(Protocolo);
}
