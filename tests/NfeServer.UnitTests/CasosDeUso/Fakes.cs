using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using NfeServer.Application;
using NfeServer.Application.Abstracoes;
using NfeServer.Application.CasosDeUso;
using NfeServer.Application.Consultas;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.UnitTests.CasosDeUso;

internal static class Cenario
{
    public const string Cnpj = "11222333000181";

    public static readonly string Chave = ChaveAcesso.Gerar(35, new DateTimeOffset(2026, 10, 1, 10, 0, 0, TimeSpan.FromHours(-3)),
        Cnpj, ModeloDocumento.NFe, 1, 123, 1, "12345678").Valor;

    public static Empresa Empresa(string uf = "SP") => new()
    {
        Cnpj = Cnpj, RazaoSocial = "EMPRESA TESTE", Uf = uf, Ambiente = 2, CertificadoPfx = "AAAA", SenhaPfx = "senha",
    };

    public static ProtocoloAutorizacao Protocolo(string? chave = null, int cStat = 100) =>
        new(chave ?? Chave, "135260000000001", cStat, "Autorizado o uso da NF-e", DateTimeOffset.Now, "digest=", "<protNFe/>");

    public static DocumentoPreparado Documento() =>
        new(Chave, ModeloDocumento.NFe, 1, 123, Ambiente.Homologacao, DateTimeOffset.Now, "<NFe/>", false);

    public static FakeRepositorios Repositorios() => new();

    public static AutorizarNotaFiscal Autorizar(FakeRepositorios repos, FakeSefaz sefaz) =>
        new(repos, repos, sefaz, new FakeDanfe(), Options.Create(new OpcoesEmissao()), TimeProvider.System, NullLogger<AutorizarNotaFiscal>.Instance);

    public static CancelarNotaFiscal Cancelar(FakeRepositorios repos, FakeSefaz sefaz) =>
        new(repos, repos, repos, sefaz, new FakeDanfe(), TimeProvider.System, NullLogger<CancelarNotaFiscal>.Instance);

    public static InutilizarNumeracao Inutilizar(FakeRepositorios repos, FakeSefaz sefaz) =>
        new(repos, repos, sefaz, TimeProvider.System, NullLogger<InutilizarNumeracao>.Instance);
}

internal sealed class FakeRepositorios : IEmpresaRepository, INotaFiscalRepository, ICancelamentoRepository, IInutilizacaoRepository
{
    public List<Empresa> Empresas { get; } = [];
    public List<NotaFiscal> Notas { get; } = [];
    public List<Cancelamento> Cancelamentos { get; } = [];
    public List<Inutilizacao> Inutilizacoes { get; } = [];

    public Task<Empresa?> ObterPorCnpjAsync(string cnpj, CancellationToken ct) => Task.FromResult(Empresas.FirstOrDefault(e => e.Cnpj == cnpj));
    Task<IReadOnlyList<Empresa>> IEmpresaRepository.ListarAsync(FiltroConsulta filtro, CancellationToken ct) => Task.FromResult<IReadOnlyList<Empresa>>(Empresas);
    public Task GravarAsync(Empresa empresa, CancellationToken ct) { Empresas.RemoveAll(e => e.Cnpj == empresa.Cnpj); Empresas.Add(empresa); return Task.CompletedTask; }
    public Task<bool> ExcluirAsync(string cnpj, CancellationToken ct) => Task.FromResult(Empresas.RemoveAll(e => e.Cnpj == cnpj) > 0);

    public Task<NotaFiscal?> ObterPorChaveAsync(string chave, CancellationToken ct) => Task.FromResult(Notas.FirstOrDefault(n => n.Chave == chave));
    Task<IReadOnlyList<NotaFiscal>> INotaFiscalRepository.ListarAsync(FiltroConsulta filtro, CancellationToken ct) => Task.FromResult<IReadOnlyList<NotaFiscal>>(Notas);
    public Task GravarAsync(NotaFiscal nota, CancellationToken ct) { Notas.RemoveAll(n => n.Chave == nota.Chave); Notas.Add(nota); return Task.CompletedTask; }
    public Task MarcarCanceladaAsync(string chave, CancellationToken ct) { Notas.Where(n => n.Chave == chave).ToList().ForEach(n => n.Cancelada = true); return Task.CompletedTask; }

    public Task GravarAsync(Cancelamento cancelamento, CancellationToken ct) { Cancelamentos.Add(cancelamento); return Task.CompletedTask; }
    Task<IReadOnlyList<Cancelamento>> ICancelamentoRepository.ListarAsync(FiltroConsulta filtro, CancellationToken ct) => Task.FromResult<IReadOnlyList<Cancelamento>>(Cancelamentos);

    public Task GravarAsync(Inutilizacao inutilizacao, CancellationToken ct) { Inutilizacoes.Add(inutilizacao); return Task.CompletedTask; }
    Task<IReadOnlyList<Inutilizacao>> IInutilizacaoRepository.ListarAsync(FiltroConsulta filtro, CancellationToken ct) => Task.FromResult<IReadOnlyList<Inutilizacao>>(Inutilizacoes);
}

internal sealed class FakeSefaz : ISefazNFeGateway
{
    public Func<RetornoAutorizacao> Autorizacao { get; set; } = () => new(100, "Autorizado", Cenario.Protocolo(), "<retEnviNFe/>");
    public Func<RetornoConsultaProtocolo> Consulta { get; set; } = () => new(100, "Autorizado", Cenario.Protocolo(), false, null, "<retConsSitNFe/>");
    public Queue<RetornoEvento> Eventos { get; } = new();
    public Func<RetornoInutilizacao> Inutilizacao { get; set; } = () => new(102, "Inutilizacao homologada", "135000000000009", DateTimeOffset.Now, "<procInutNFe/>");

    public int Autorizacoes { get; private set; }
    public List<string> ChavesConsultadas { get; } = [];
    public List<PedidoCancelamento> Cancelamentos { get; } = [];
    public TipoContingencia? ContingenciaRecebida { get; private set; }

    public DocumentoPreparado Preparar(Empresa empresa, string xml, TipoContingencia contingencia)
    {
        ContingenciaRecebida = contingencia;
        return Cenario.Documento();
    }

    public RetornoAutorizacao Autorizar(Empresa empresa, DocumentoPreparado documento, bool envioAssincrono) { Autorizacoes++; return Autorizacao(); }
    public RetornoConsultaProtocolo ConsultarProtocolo(Empresa empresa, string chave) { ChavesConsultadas.Add(chave); return Consulta(); }
    public string MontarXmlProcessado(string xmlAssinado, string protocoloXml) => $"<nfeProc>{xmlAssinado}{protocoloXml}</nfeProc>";
    public RetornoEvento Cancelar(Empresa empresa, PedidoCancelamento pedido) { Cancelamentos.Add(pedido); return Eventos.Dequeue(); }
    public RetornoEvento EnviarCartaCorrecao(Empresa empresa, PedidoCartaCorrecao pedido) => Eventos.Dequeue();
    public RetornoInutilizacao Inutilizar(Empresa empresa, PedidoInutilizacao pedido) => Inutilizacao();
}

internal sealed class FakeDanfe : IDanfeService
{
    public byte[]? GerarDanfe(string xmlProcessado, ModeloDocumento modelo) => [0x25, 0x50, 0x44, 0x46];
    public byte[]? GerarEvento(string xmlNfe, string xmlEvento) => [0x25, 0x50, 0x44, 0x46];
}
