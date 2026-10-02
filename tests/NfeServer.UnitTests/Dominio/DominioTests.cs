using NfeServer.Domain.Comum;
using NfeServer.Domain.Fiscal;

namespace NfeServer.UnitTests.Dominio;

public class ChaveAcessoTests
{
    private static ChaveAcesso ChaveExemplo(int tipoEmissao = 1) =>
        ChaveAcesso.Gerar(35, new DateTimeOffset(2026, 10, 1, 10, 0, 0, TimeSpan.FromHours(-3)), "11222333000181",
            ModeloDocumento.NFe, 1, 123, tipoEmissao, "12345678");

    [Fact]
    public void Gerar_produz_chave_valida_com_campos_decompostos()
    {
        var chave = ChaveExemplo();

        Assert.Equal(44, chave.Valor.Length);
        Assert.StartsWith("3526101122233300018155001000000123112345678", chave.Valor);
        Assert.Equal(35, chave.CodigoUf);
        Assert.Equal("11222333000181", chave.Cnpj);
        Assert.Equal(ModeloDocumento.NFe, chave.Modelo);
        Assert.Equal(1, chave.Serie);
        Assert.Equal(123, chave.Numero);
        Assert.Equal(1, chave.TipoEmissao);
        Assert.True(ChaveAcesso.TryParse(chave.Valor, out _));
    }

    [Fact]
    public void Parse_aceita_prefixo_NFe_e_rejeita_digito_errado()
    {
        var chave = ChaveExemplo().Valor;
        Assert.Equal(chave, ChaveAcesso.Parse("NFe" + chave).Valor);

        var dvErrado = chave[..43] + (char)('0' + (chave[43] - '0' + 1) % 10);
        Assert.False(ChaveAcesso.TryParse(dvErrado, out _));
        Assert.Throws<RegraNegocioException>(() => ChaveAcesso.Parse(dvErrado));
    }

    [Fact]
    public void Mudar_tipo_de_emissao_muda_o_digito()
    {
        Assert.NotEqual(ChaveExemplo(1).Valor[43], ChaveExemplo(6).Valor[43]);
        Assert.Equal('6', ChaveExemplo(6).Valor[34]);
    }

    [Fact]
    public void ExtrairDeTexto_encontra_chave_no_xMotivo_de_duplicidade()
    {
        var chave = ChaveExemplo().Valor;
        var motivo = $"Rejeicao: Duplicidade de NF-e, com diferenca na Chave de Acesso [chNFe:{chave}][nRec:351000000000001]";

        Assert.Equal(chave, ChaveAcesso.ExtrairDeTexto(motivo)?.Valor);
        Assert.Null(ChaveAcesso.ExtrairDeTexto("Rejeicao: sem chave"));
    }
}

public class CnpjTests
{
    [Theory]
    [InlineData("11.222.333/0001-81", true)]
    [InlineData("11222333000181", true)]
    [InlineData("11222333000182", false)]
    [InlineData("00000000000000", false)]
    [InlineData("123", false)]
    [InlineData("12.ABC.345/01DE-35", true)] // exemplo oficial de CNPJ alfanumérico da RFB
    public void Valida_numerico_e_alfanumerico(string cnpj, bool valido) => Assert.Equal(valido, Cnpj.EhValido(cnpj));

    [Fact]
    public void Normalizar_remove_mascara_e_preserva_letras() => Assert.Equal("12ABC34501DE35", Cnpj.Normalizar("12.abc.345/01de-35"));
}

public class ContingenciaSvcTests
{
    [Theory]
    [InlineData("GO", TipoContingencia.SvcRs)] // estava nas duas listas no Delphi
    [InlineData("DF", TipoContingencia.SvcAn)] // não estava em nenhuma no Delphi
    [InlineData("SP", TipoContingencia.SvcAn)]
    [InlineData("BA", TipoContingencia.SvcRs)]
    public void Escolhe_o_autorizador_pela_UF(string uf, TipoContingencia esperado) =>
        Assert.Equal(esperado, ContingenciaSvc.Para(uf, contingenciaAtiva: true));

    [Fact]
    public void Sem_contingencia_ativa_nao_aplica() => Assert.Equal(TipoContingencia.Nenhuma, ContingenciaSvc.Para("SP", false));

    [Fact]
    public void NFCe_nao_tem_SVC() => Assert.False(ContingenciaSvc.Aplicavel(ModeloDocumento.NFCe));
}

public class JustificativaTests
{
    [Theory]
    [InlineData("curta")]
    [InlineData("               ")]
    public void Rejeita_menos_de_15_caracteres(string texto) =>
        Assert.Throws<RegraNegocioException>(() => Justificativa.Validar(texto));

    [Fact]
    public void Aceita_e_apara_texto_valido() =>
        Assert.Equal("Erro na digitacao do valor", Justificativa.Validar("  Erro na digitacao do valor  "));
}
