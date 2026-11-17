using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography.Xml;
using System.Xml;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;
using NfeServer.Infrastructure.Certificados;
using NfeServer.Infrastructure.Fiscal;
using NfeServer.Infrastructure.Pdf;

namespace NfeServer.UnitTests.Infraestrutura;

/// <summary>Exercita o Zeus de verdade, sem rede: carga do XML, contingência, assinatura e DANFE.</summary>
public class ZeusGatewayTests
{
    private const string Cnpj = "11222333000181";

    [Fact]
    public void Preparar_assina_e_a_assinatura_continua_valida_no_nfeProc()
    {
        var gateway = CriarGateway();
        var documento = gateway.Preparar(Empresa(), XmlNFe(), TipoContingencia.Nenhuma);

        Assert.Equal(ChaveOriginal.Valor, documento.Chave);
        Assert.Equal(123, documento.Numero);
        Assert.Contains("<Signature", documento.XmlAssinado);

        var nfeProc = gateway.MontarXmlProcessado(documento.XmlAssinado, ProtocoloXml(documento.Chave));
        Assert.StartsWith("<?xml", nfeProc);
        Assert.True(AssinaturaValida(nfeProc), "a montagem do nfeProc não pode alterar o XML assinado");
    }

    [Fact]
    public void Contingencia_svc_recalcula_chave_e_preenche_justificativa()
    {
        var documento = CriarGateway().Preparar(Empresa(), XmlNFe(), TipoContingencia.SvcAn);

        Assert.True(documento.EmContingencia);
        var chave = ChaveAcesso.Parse(documento.Chave);
        Assert.Equal(6, chave.TipoEmissao); // teSVCAN
        Assert.NotEqual(ChaveOriginal.Valor, chave.Valor);
        Assert.Contains("<tpEmis>6</tpEmis>", documento.XmlAssinado);
        Assert.Contains("<xJust>", documento.XmlAssinado);
        Assert.True(AssinaturaValida(documento.XmlAssinado));
    }

    [Fact]
    public void Ambiente_do_xml_diferente_da_empresa_e_recusado()
    {
        var empresa = Empresa();
        empresa.Ambiente = 1;
        var erro = Assert.Throws<Domain.Comum.RegraNegocioException>(() => CriarGateway().Preparar(empresa, XmlNFe(), TipoContingencia.Nenhuma));
        Assert.Contains("ambiente", erro.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void Danfe_A4_e_gerado_a_partir_do_nfeProc()
    {
        var gateway = CriarGateway();
        var documento = gateway.Preparar(Empresa(), XmlNFe(), TipoContingencia.Nenhuma);
        var nfeProc = gateway.MontarXmlProcessado(documento.XmlAssinado, ProtocoloXml(documento.Chave));

        var pdf = new DanfeService(Options.Create(new OpcoesDanfe()), NullLogger<DanfeService>.Instance)
            .GerarDanfe(nfeProc, ModeloDocumento.NFe);

        Assert.NotNull(pdf);
        Assert.Equal("%PDF", System.Text.Encoding.ASCII.GetString(pdf![..4]));
    }

    private static readonly ChaveAcesso ChaveOriginal = ChaveAcesso.Gerar(35,
        new DateTimeOffset(2026, 10, 1, 10, 0, 0, TimeSpan.FromHours(-3)), Cnpj, ModeloDocumento.NFe, 1, 123, 1, "12345678");

    private static ZeusSefazNFeGateway CriarGateway() =>
        new(new ProvedorCertificados(new MemoryCache(new MemoryCacheOptions()), TimeProvider.System),
            Options.Create(new OpcoesSefaz()), TimeProvider.System, NullLogger<ZeusSefazNFeGateway>.Instance);

    private static readonly Lazy<string> PfxBase64 = new(() =>
    {
        using var rsa = RSA.Create(2048);
        var pedido = new CertificateRequest($"CN=EMPRESA TESTE:{Cnpj}", rsa, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        using var certificado = pedido.CreateSelfSigned(DateTimeOffset.Now.AddDays(-1), DateTimeOffset.Now.AddYears(1));
        return Convert.ToBase64String(certificado.Export(X509ContentType.Pfx, "1234"));
    });

    private static Empresa Empresa() => new()
    {
        Cnpj = Cnpj, RazaoSocial = "EMPRESA TESTE", Uf = "SP", Ambiente = 2, CertificadoPfx = PfxBase64.Value, SenhaPfx = "1234",
    };

    private static bool AssinaturaValida(string xml)
    {
        var documento = new XmlDocument { PreserveWhitespace = true };
        documento.LoadXml(xml);
        var gerenciador = new XmlNamespaceManager(documento.NameTable);
        gerenciador.AddNamespace("ds", "http://www.w3.org/2000/09/xmldsig#");
        var assinatura = (XmlElement)documento.SelectSingleNode("//ds:Signature", gerenciador)!;
        var signedXml = new SignedXml(documento);
        signedXml.LoadXml(assinatura);
        return signedXml.CheckSignature();
    }

    private static string ProtocoloXml(string chave) =>
        $"""<protNFe versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe"><infProt><tpAmb>2</tpAmb><verAplic>SP_NFE_PL009_V4</verAplic><chNFe>{chave}</chNFe><dhRecbto>2026-10-01T10:00:05-03:00</dhRecbto><nProt>135260000000001</nProt><digVal>abc=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe>""";

    private static string XmlNFe() => $"""
        <?xml version="1.0" encoding="UTF-8"?>
        <NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe versao="4.00" Id="NFe{ChaveOriginal.Valor}"><ide><cUF>35</cUF><cNF>12345678</cNF><natOp>VENDA DE MERCADORIA</natOp><mod>55</mod><serie>1</serie><nNF>123</nNF><dhEmi>2026-10-01T10:00:00-03:00</dhEmi><tpNF>1</tpNF><idDest>1</idDest><cMunFG>3550308</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>{ChaveOriginal.Valor[^1]}</cDV><tpAmb>2</tpAmb><finNFe>1</finNFe><indFinal>1</indFinal><indPres>1</indPres><procEmi>0</procEmi><verProc>NfeServer 1.0</verProc></ide><emit><CNPJ>{Cnpj}</CNPJ><xNome>EMPRESA TESTE LTDA</xNome><enderEmit><xLgr>RUA DAS FLORES</xLgr><nro>100</nro><xBairro>CENTRO</xBairro><cMun>3550308</cMun><xMun>SAO PAULO</xMun><UF>SP</UF><CEP>01001000</CEP><cPais>1058</cPais><xPais>BRASIL</xPais></enderEmit><IE>123456789012</IE><CRT>3</CRT></emit><dest><CPF>12345678909</CPF><xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xNome><enderDest><xLgr>RUA B</xLgr><nro>2</nro><xBairro>CENTRO</xBairro><cMun>3550308</cMun><xMun>SAO PAULO</xMun><UF>SP</UF><CEP>01001000</CEP><cPais>1058</cPais><xPais>BRASIL</xPais></enderDest><indIEDest>9</indIEDest></dest><det nItem="1"><prod><cProd>001</cProd><cEAN>SEM GTIN</cEAN><xProd>CAMISETA ALGODAO</xProd><NCM>61091000</NCM><CFOP>5102</CFOP><uCom>UN</uCom><qCom>1.0000</qCom><vUnCom>10.00</vUnCom><vProd>10.00</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>UN</uTrib><qTrib>1.0000</qTrib><vUnTrib>10.00</vUnTrib><indTot>1</indTot></prod><imposto><ICMS><ICMS00><orig>0</orig><CST>00</CST><modBC>3</modBC><vBC>10.00</vBC><pICMS>18.00</pICMS><vICMS>1.80</vICMS></ICMS00></ICMS><PIS><PISOutr><CST>99</CST><vBC>0.00</vBC><pPIS>0.0000</pPIS><vPIS>0.00</vPIS></PISOutr></PIS><COFINS><COFINSOutr><CST>99</CST><vBC>0.00</vBC><pCOFINS>0.0000</pCOFINS><vCOFINS>0.00</vCOFINS></COFINSOutr></COFINS></imposto></det><total><ICMSTot><vBC>10.00</vBC><vICMS>1.80</vICMS><vICMSDeson>0.00</vICMSDeson><vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST><vFCPSTRet>0.00</vFCPSTRet><vProd>10.00</vProd><vFrete>0.00</vFrete><vSeg>0.00</vSeg><vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol><vPIS>0.00</vPIS><vCOFINS>0.00</vCOFINS><vOutro>0.00</vOutro><vNF>10.00</vNF></ICMSTot></total><transp><modFrete>9</modFrete></transp><pag><detPag><tPag>01</tPag><vPag>10.00</vPag></detPag></pag></infNFe></NFe>
        """;
}
