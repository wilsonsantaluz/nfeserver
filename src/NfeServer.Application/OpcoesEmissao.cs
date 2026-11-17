namespace NfeServer.Application;

public sealed class OpcoesEmissao
{
    public const string Secao = "Emissao";

    /// <summary>UFs que recebem o lote em modo assíncrono (no Delphi: SP e BA, fixo no código).</summary>
    public List<string> UfsEnvioAssincrono { get; set; } = ["SP", "BA"];
}
