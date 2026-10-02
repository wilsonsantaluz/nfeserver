using System.Xml.Linq;
using NfeServer.Domain.Comum;

namespace NfeServer.Infrastructure.Fiscal;

internal static class XmlFiscal
{
    public const string NamespaceNFe = "http://www.portalfiscal.inf.br/nfe";
    private const string Declaracao = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

    public static string SemDeclaracao(string xml)
    {
        var texto = xml.TrimStart('﻿', ' ', '\r', '\n', '\t');
        if (!texto.StartsWith("<?xml", StringComparison.Ordinal))
            return texto;
        var fim = texto.IndexOf("?>", StringComparison.Ordinal);
        return fim < 0 ? texto : texto[(fim + 2)..].TrimStart();
    }

    /// <summary>Aceita tanto &lt;NFe&gt; quanto &lt;nfeProc&gt; (o ACBr aceitava os dois).</summary>
    public static string ExtrairNFe(string xml)
    {
        XDocument documento;
        try
        {
            documento = XDocument.Parse(SemDeclaracao(xml), LoadOptions.PreserveWhitespace);
        }
        catch (System.Xml.XmlException ex)
        {
            throw new RegraNegocioException($"XML da nota inválido: {ex.Message}");
        }

        var raiz = documento.Root!;
        if (raiz.Name.LocalName == "NFe")
            return SemDeclaracao(xml);

        var nfe = raiz.Descendants().FirstOrDefault(e => e.Name.LocalName == "NFe")
            ?? throw new RegraNegocioException($"O XML informado não contém o elemento NFe (raiz: {raiz.Name.LocalName})");
        return nfe.ToString(SaveOptions.DisableFormatting);
    }

    /// <summary>Envolve elementos já assinados sem reserializá-los (preserva as assinaturas).</summary>
    public static string Envolver(string elemento, params string[] filhos) =>
        $"{Declaracao}<{elemento} versao=\"4.00\" xmlns=\"{NamespaceNFe}\">{string.Concat(filhos.Select(SemDeclaracao))}</{elemento}>";

    public static string? ElementoBruto(string xml, string nomeLocal)
    {
        if (string.IsNullOrWhiteSpace(xml))
            return null;
        try
        {
            var documento = XDocument.Parse(SemDeclaracao(xml), LoadOptions.PreserveWhitespace);
            return documento.Descendants().FirstOrDefault(e => e.Name.LocalName == nomeLocal)?.ToString(SaveOptions.DisableFormatting);
        }
        catch (System.Xml.XmlException)
        {
            return null;
        }
    }
}
