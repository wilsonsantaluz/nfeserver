using NfeServer.Application.Abstracoes;
using NfeServer.Application.CasosDeUso;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.UnitTests.CasosDeUso;

public class AutorizarNotaFiscalTests
{
    private static SolicitacaoAutorizacao Solicitacao(string? xml = "<NFe/>", string? txt = null) =>
        new(Cenario.Cnpj, 123, 1, 55, xml, txt);

    [Fact]
    public async Task Autorizada_monta_nfeProc_gera_danfe_e_grava()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        var sefaz = new FakeSefaz();

        var nota = await Cenario.Autorizar(repos, sefaz).ExecutarAsync(Solicitacao(), default);

        Assert.Equal(100, nota.Status);
        Assert.Equal("135260000000001", nota.Protocolo);
        Assert.StartsWith("<nfeProc>", nota.Xml);
        Assert.NotEmpty(nota.Danfe);
        Assert.Single(repos.Notas);
    }

    [Fact]
    public async Task Nota_ja_autorizada_na_base_nao_e_reenviada()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        repos.Notas.Add(new NotaFiscal { Chave = Cenario.Chave, Protocolo = "135000000000001", Status = 100 });
        var sefaz = new FakeSefaz();

        var nota = await Cenario.Autorizar(repos, sefaz).ExecutarAsync(Solicitacao(), default);

        Assert.Equal("135000000000001", nota.Protocolo);
        Assert.Equal(0, sefaz.Autorizacoes);
    }

    [Fact]
    public async Task Duplicidade_204_recupera_protocolo_pela_consulta_e_grava()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        var sefaz = new FakeSefaz
        {
            Autorizacao = () => new(204, $"Rejeicao: Duplicidade de NF-e [chNFe:{Cenario.Chave}]", Cenario.Protocolo(cStat: 204) with { NumeroProtocolo = "" }, "<ret/>"),
        };

        var nota = await Cenario.Autorizar(repos, sefaz).ExecutarAsync(Solicitacao(), default);

        Assert.Equal([Cenario.Chave], sefaz.ChavesConsultadas);
        Assert.Equal(100, nota.Status);
        Assert.Equal("135260000000001", nota.Protocolo);
        Assert.Single(repos.Notas); // o Delphi não gravava em caso de 204
    }

    [Fact]
    public async Task Duplicidade_com_chave_diferente_nao_monta_nfeProc_com_xml_local()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        var outraChave = ChaveAcesso.Gerar(35, DateTimeOffset.Now, Cenario.Cnpj, ModeloDocumento.NFe, 1, 123, 1, "87654321").Valor;
        var sefaz = new FakeSefaz
        {
            Autorizacao = () => new(539, $"Rejeicao: Duplicidade com diferenca na chave [chNFe:{outraChave}]", null, "<ret/>"),
            Consulta = () => new(100, "Autorizado", Cenario.Protocolo(outraChave), false, null, "<ret/>"),
        };

        var nota = await Cenario.Autorizar(repos, sefaz).ExecutarAsync(Solicitacao(), default);

        Assert.Equal(539, nota.Status);
        Assert.Empty(nota.Protocolo);
        Assert.Contains(outraChave, nota.Motivo);
    }

    [Fact]
    public async Task Empresa_inexistente_retorna_5001_sem_gravar()
    {
        var repos = Cenario.Repositorios();
        var nota = await Cenario.Autorizar(repos, new FakeSefaz()).ExecutarAsync(Solicitacao(), default);

        Assert.Equal(CodigosRetorno.ErroInterno, nota.Status);
        Assert.Contains("Nenhuma empresa", nota.Motivo);
        Assert.Empty(repos.Notas);
    }

    [Fact]
    public async Task Txt_do_ACBr_e_recusado_com_mensagem_clara()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());

        var nota = await Cenario.Autorizar(repos, new FakeSefaz()).ExecutarAsync(Solicitacao(xml: null, txt: "[infNFe]"), default);

        Assert.Equal(CodigosRetorno.ErroInterno, nota.Status);
        Assert.Contains("TXT/INI", nota.Motivo);
    }

    [Fact]
    public async Task Contingencia_ativa_na_empresa_chega_ao_gateway()
    {
        var repos = Cenario.Repositorios();
        var empresa = Cenario.Empresa("GO");
        empresa.Contigencia = 1;
        repos.Empresas.Add(empresa);
        var sefaz = new FakeSefaz();

        await Cenario.Autorizar(repos, sefaz).ExecutarAsync(Solicitacao(), default);

        Assert.Equal(TipoContingencia.SvcRs, sefaz.ContingenciaRecebida);
    }
}

public class CancelarNotaFiscalTests
{
    private static SolicitacaoCancelamento Solicitacao(string? protocolo = "135260000000001") =>
        new(Cenario.Cnpj, Cenario.Chave, protocolo, "Cancelamento por erro de digitacao", new DateTime(2026, 10, 1), 0, 0, 0);

    private static RetornoEvento Evento(int cStat) =>
        new(cStat, $"cStat {cStat}", cStat == 135 ? "135260000000099" : null, DateTimeOffset.Now, cStat == 135 ? "<procEventoNFe/>" : "", "<retEnvEvento/>");

    [Fact]
    public async Task Rejeicao_577_e_reenviada_com_a_hora_atual_e_marca_a_nota()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        repos.Notas.Add(new NotaFiscal { Chave = Cenario.Chave, Protocolo = "135260000000001", Xml = "<nfeProc/>" });
        var sefaz = new FakeSefaz();
        sefaz.Eventos.Enqueue(Evento(577));
        sefaz.Eventos.Enqueue(Evento(135));

        var cancelamento = await Cenario.Cancelar(repos, sefaz).ExecutarAsync(Solicitacao(), default);

        Assert.Equal(2, sefaz.Cancelamentos.Count);
        Assert.Equal(135, cancelamento.CStat);
        Assert.Equal("135260000000099", cancelamento.ProtocoloCancelamento);
        Assert.Equal("<procEventoNFe/>", cancelamento.XmlRetorno);
        Assert.True(repos.Notas.Single().Cancelada);
        Assert.Single(repos.Cancelamentos);
    }

    [Fact]
    public async Task Data_sem_hora_nao_e_usada_como_dhEvento()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        var sefaz = new FakeSefaz();
        sefaz.Eventos.Enqueue(Evento(135));

        await Cenario.Cancelar(repos, sefaz).ExecutarAsync(Solicitacao(), default);

        Assert.True(sefaz.Cancelamentos.Single().DataHoraEvento > DateTimeOffset.Now.AddMinutes(-1));
    }

    [Fact]
    public async Task Evento_duplicado_573_nao_e_gravado()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        var sefaz = new FakeSefaz();
        sefaz.Eventos.Enqueue(Evento(573));

        var cancelamento = await Cenario.Cancelar(repos, sefaz).ExecutarAsync(Solicitacao(), default);

        Assert.Equal(573, cancelamento.CStat);
        Assert.Empty(repos.Cancelamentos);
    }

    [Fact]
    public async Task Sem_protocolo_e_sem_nota_na_base_falha_antes_de_enviar()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        var sefaz = new FakeSefaz();

        var cancelamento = await Cenario.Cancelar(repos, sefaz).ExecutarAsync(Solicitacao(protocolo: null), default);

        Assert.Equal(CodigosRetorno.ErroInterno, cancelamento.CStat);
        Assert.Empty(sefaz.Cancelamentos);
        Assert.Empty(repos.Cancelamentos);
    }
}

public class InutilizarNumeracaoTests
{
    [Fact]
    public async Task Homologada_grava_e_duplicada_nao()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());
        var sefaz = new FakeSefaz();
        var caso = Cenario.Inutilizar(repos, sefaz);
        var solicitacao = new SolicitacaoInutilizacao(Cenario.Cnpj, 55, 2026, 1, 10, 12, "Falha no sistema de numeracao");

        var homologada = await caso.ExecutarAsync(solicitacao, default);
        sefaz.Inutilizacao = () => new(563, "Duplicidade", null, null, "<ret/>");
        await caso.ExecutarAsync(solicitacao, default);

        Assert.Equal(102, homologada.CStat);
        Assert.Equal("135000000000009", homologada.Protocolo);
        Assert.Single(repos.Inutilizacoes);
    }

    [Fact]
    public async Task Faixa_invalida_e_rejeitada_localmente()
    {
        var repos = Cenario.Repositorios();
        repos.Empresas.Add(Cenario.Empresa());

        var resultado = await Cenario.Inutilizar(repos, new FakeSefaz())
            .ExecutarAsync(new SolicitacaoInutilizacao(Cenario.Cnpj, 55, 2026, 1, 20, 10, "Falha no sistema de numeracao"), default);

        Assert.Equal(CodigosRetorno.ErroInterno, resultado.CStat);
        Assert.Empty(repos.Inutilizacoes);
    }
}
