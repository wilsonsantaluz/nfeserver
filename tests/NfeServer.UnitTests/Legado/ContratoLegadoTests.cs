using System.Text.Json;
using NfeServer.Api.Legado;
using NfeServer.Application.Consultas;
using NfeServer.Domain.Comum;
using NfeServer.Infrastructure.Legado;

namespace NfeServer.UnitTests.Legado;

public class JsonLegadoTests
{
    [Fact]
    public void Lista_sai_no_formato_TObjectList_do_Delphi()
    {
        var json = JsonLegado.Serializar(new ListaLegada<NotaLegado>([new NotaLegado { Chave = "123", Status = 100 }]));
        using var doc = JsonDocument.Parse(json);

        Assert.True(doc.RootElement.GetProperty("ownsObjects").GetBoolean());
        var item = doc.RootElement.GetProperty("listHelper")[0];
        Assert.Equal("123", item.GetProperty("chave").GetString());
        Assert.Equal(100, item.GetProperty("status").GetInt32());
        Assert.Equal("1899-12-30T00:00:00.000Z", item.GetProperty("dataEmissao").GetString());
    }

    [Fact]
    public void Datas_seguem_o_formato_do_REST_Json()
    {
        var json = JsonLegado.Serializar(new ValidacaoResponseLegado { DataValidacao = new DateTime(2026, 10, 1, 14, 5, 9, 120) });
        Assert.Contains("\"dataValidacao\":\"2026-10-01T14:05:09.120Z\"", json);
        Assert.Contains("\"xmlProcesado\"", json); // grafia original mantida
        Assert.Contains("\"dataProcesamemento\"", json);
    }

    [Fact]
    public void Entrada_aceita_caixa_diferente_e_numeros_como_texto()
    {
        // payload real do front (nfe_view_empresa.js): "Ambiente" maiúsculo, validade como texto
        var empresa = JsonLegado.Desserializar<EmpresaLegado>("""{"cnpj":"11222333000181","Ambiente":1,"contigencia":"0","validade":"2027-01-31"}""");

        Assert.Equal(1, empresa.Ambiente);
        Assert.Equal(0, empresa.Contigencia);
        Assert.Equal(new DateTime(2027, 1, 31), empresa.Validade);
    }

    [Fact]
    public void Mensagem_tem_o_formato_de_setResponse() =>
        Assert.Equal("""{"codretorno":200,"msg":"Empresa gravada"}""", JsonLegado.Serializar(new MensagemLegada(200, "Empresa gravada")));

    [Fact]
    public void DataLegada_ida_e_volta()
    {
        var data = new DateTime(2025, 12, 31, 23, 59, 58, 7);
        Assert.Equal(data, DataLegada.Converter(DataLegada.Formatar(data)));
        Assert.Equal(default, DataLegada.Converter("1899-12-30T00:00:00.000Z"));
    }
}

public class FiltroConsultaTests
{
    [Fact]
    public void Ignora_campos_fora_da_lista_e_normaliza_cnpj()
    {
        var filtro = FiltroConsulta.DeJson("""{"cnpj":"11.222.333/0001-81","operacao":"validacao","serie":1}""", CamposFiltro.Notas);

        Assert.Equal("11222333000181", filtro.Condicoes["cnpj"]);
        Assert.Equal(1L, filtro.Condicoes["serie"]);
        Assert.False(filtro.Condicoes.ContainsKey("operacao"));
    }

    [Fact]
    public void Bloqueia_operadores_do_Mongo() =>
        Assert.Throws<RegraNegocioException>(() => FiltroConsulta.DeJson("""{"cnpj":{"$ne":""}}""", CamposFiltro.Empresas));

    [Fact]
    public void Json_vazio_ou_chaves_vazias_lista_tudo()
    {
        Assert.Empty(FiltroConsulta.DeJson(null, CamposFiltro.Notas).Condicoes);
        Assert.Empty(FiltroConsulta.DeJson("{}", CamposFiltro.Notas).Condicoes);
    }

    [Fact]
    public void Json_invalido_e_regra_de_negocio() =>
        Assert.Throws<RegraNegocioException>(() => FiltroConsulta.DeJson("{cnpj:", CamposFiltro.Notas));
}
