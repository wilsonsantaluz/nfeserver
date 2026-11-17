using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NFe.Danfe.PdfClown;
using NFe.Danfe.PdfClown.Modelo;
using NFe.Danfe.QuestPdf.ImpressaoEventoNfe;
using NFe.Danfe.QuestPdf.ImpressaoNfce;
using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Fiscal;
using QuestPDF.Fluent;
using QuestPDF.Infrastructure;

namespace NfeServer.Infrastructure.Pdf;

public sealed class OpcoesDanfe
{
    public const string Secao = "Danfe";

    /// <summary>Mesmo local do Delphi: logo\logo.bmp ao lado do executável.</summary>
    public string CaminhoLogo { get; set; } = Path.Combine(AppContext.BaseDirectory, "logo", "logo.bmp");

    /// <summary>Community é gratuita só abaixo de US$ 1 mi de receita anual; acima, Professional/Enterprise.</summary>
    public LicenseType LicencaQuestPdf { get; set; } = LicenseType.Community;
}

/// <summary>
/// NF-e (A4) via PdfClown, NFC-e (bobina) e CC-e via QuestPDF. Gera em memória: o Delphi
/// gravava cada PDF em reports\ e nunca apagava.
/// </summary>
internal sealed class DanfeService : IDanfeService
{
    private readonly ILogger<DanfeService> _logger;
    private readonly OpcoesDanfe _opcoes;

    public DanfeService(IOptions<OpcoesDanfe> opcoes, ILogger<DanfeService> logger)
    {
        _opcoes = opcoes.Value;
        _logger = logger;
        // Relativo à pasta do executável: como serviço do Windows o diretório atual é System32.
        if (!Path.IsPathRooted(_opcoes.CaminhoLogo))
            _opcoes.CaminhoLogo = Path.Combine(AppContext.BaseDirectory, _opcoes.CaminhoLogo);
        QuestPDF.Settings.License = _opcoes.LicencaQuestPdf;
    }

    public byte[]? GerarDanfe(string xmlProcessado, ModeloDocumento modelo) =>
        Tentar("DANFE", () => modelo == ModeloDocumento.NFCe ? GerarNfce(xmlProcessado) : GerarNfe(xmlProcessado));

    public byte[]? GerarEvento(string xmlNfe, string xmlEvento) =>
        Tentar("evento", () => new EventoNfeDocument(xmlNfe, xmlEvento, Logo()).GeneratePdf());

    private byte[] GerarNfe(string xml)
    {
        using var danfe = new DanfeDoc(DanfeViewModelCreator.CriarDeStringXml(xml));
        if (File.Exists(_opcoes.CaminhoLogo))
            danfe.AdicionarLogoImagem(_opcoes.CaminhoLogo);
        danfe.Gerar();
        using var saida = new MemoryStream();
        danfe.Salvar(saida);
        return saida.ToArray();
    }

    private byte[] GerarNfce(string xml)
    {
        var documento = new DanfeNfceDocument(xml, Logo());
        documento.TamanhoImpressao(TamanhoImpressao.Impressao80);
        return documento.GeneratePdf();
    }

    private byte[] Logo() => File.Exists(_opcoes.CaminhoLogo) ? File.ReadAllBytes(_opcoes.CaminhoLogo) : [];

    private byte[]? Tentar(string tipo, Func<byte[]> gerar)
    {
        try
        {
            return gerar();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Falha ao gerar o PDF do {Tipo}", tipo);
            return null;
        }
    }
}
