namespace NfeServer.Infrastructure.Fiscal;

public sealed class OpcoesSefaz
{
    public const string Secao = "Sefaz";

    /// <summary>Timeout por chamada (o Delphi usava 30 s).</summary>
    public int TimeoutMs { get; set; } = 30_000;

    /// <summary>Pasta dos XSD do PL vigente. Vazio desliga a validação local de schema.</summary>
    public string DiretorioSchemas { get; set; } = string.Empty;

    /// <summary>A cadeia ICP-Brasil costuma não estar no repositório confiável do Windows.</summary>
    public bool ValidarCertificadoServidor { get; set; }

    /// <summary>Consultas ao recibo no envio assíncrono enquanto o lote estiver em processamento (105).</summary>
    public int TentativasConsultaRecibo { get; set; } = 5;

    /// <summary>Versão do QR Code da NFC-e (2 ou 3, conforme a NT vigente na UF).</summary>
    public int VersaoQrCodeNfce { get; set; } = 2;
}
