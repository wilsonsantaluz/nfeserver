using MongoDB.Driver;
using NfeServer.Application.Abstracoes;
using NfeServer.Application.Consultas;
using NfeServer.Domain.Entidades;
using NfeServer.Infrastructure.Seguranca;

namespace NfeServer.Infrastructure.Persistencia.Mongo;

internal sealed class NotaFiscalRepository(ContextoMongo contexto) : INotaFiscalRepository
{
    private readonly IMongoCollection<NotaFiscal> _colecao = contexto.Colecao<NotaFiscal>(Colecoes.Notas);

    public async Task<NotaFiscal?> ObterPorChaveAsync(string chave, CancellationToken ct) =>
        await _colecao.Find(n => n.Chave == chave)
            .Sort(Builders<NotaFiscal>.Sort.Descending(n => n.Protocolo))
            .FirstOrDefaultAsync(ct);

    public Task<IReadOnlyList<NotaFiscal>> ListarAsync(FiltroConsulta filtro, CancellationToken ct) =>
        ContextoMongo.ListarAsync(_colecao, filtro, ct);

    public Task GravarAsync(NotaFiscal nota, CancellationToken ct) =>
        _colecao.ReplaceOneAsync(n => n.Chave == nota.Chave, nota, new ReplaceOptions { IsUpsert = true }, ct);

    public Task MarcarCanceladaAsync(string chave, CancellationToken ct) =>
        _colecao.UpdateManyAsync(n => n.Chave == chave, Builders<NotaFiscal>.Update.Set(n => n.Cancelada, true), cancellationToken: ct);
}

internal sealed class EmpresaRepository(ContextoMongo contexto, IProtetorSegredos protetor) : IEmpresaRepository
{
    private readonly IMongoCollection<Empresa> _colecao = contexto.Colecao<Empresa>(Colecoes.Empresas);

    public async Task<Empresa?> ObterPorCnpjAsync(string cnpj, CancellationToken ct)
    {
        var empresa = await _colecao.Find(e => e.Cnpj == cnpj).FirstOrDefaultAsync(ct);
        return empresa is null ? null : Abrir(empresa);
    }

    public async Task<IReadOnlyList<Empresa>> ListarAsync(FiltroConsulta filtro, CancellationToken ct) =>
        (await ContextoMongo.ListarAsync(_colecao, filtro, ct)).Select(Abrir).ToList();

    public async Task GravarAsync(Empresa empresa, CancellationToken ct)
    {
        var senhaAberta = empresa.SenhaPfx;
        var cscAberto = empresa.Csc;
        empresa.SenhaPfx = protetor.Proteger(senhaAberta);
        empresa.Csc = protetor.Proteger(cscAberto);
        try
        {
            await _colecao.ReplaceOneAsync(e => e.Cnpj == empresa.Cnpj, empresa, new ReplaceOptions { IsUpsert = true }, ct);
        }
        finally
        {
            empresa.SenhaPfx = senhaAberta;
            empresa.Csc = cscAberto;
        }
    }

    public async Task<bool> ExcluirAsync(string cnpj, CancellationToken ct) =>
        (await _colecao.DeleteManyAsync(e => e.Cnpj == cnpj, ct)).DeletedCount > 0;

    private Empresa Abrir(Empresa empresa)
    {
        empresa.SenhaPfx = protetor.Abrir(empresa.SenhaPfx);
        empresa.Csc = protetor.Abrir(empresa.Csc);
        return empresa;
    }
}

internal sealed class CancelamentoRepository(ContextoMongo contexto) : ICancelamentoRepository
{
    private readonly IMongoCollection<Cancelamento> _colecao = contexto.Colecao<Cancelamento>(Colecoes.Cancelamentos);

    public Task GravarAsync(Cancelamento cancelamento, CancellationToken ct) => _colecao.InsertOneAsync(cancelamento, cancellationToken: ct);

    public Task<IReadOnlyList<Cancelamento>> ListarAsync(FiltroConsulta filtro, CancellationToken ct) => ContextoMongo.ListarAsync(_colecao, filtro, ct);
}

internal sealed class InutilizacaoRepository(ContextoMongo contexto) : IInutilizacaoRepository
{
    private readonly IMongoCollection<Inutilizacao> _colecao = contexto.Colecao<Inutilizacao>(Colecoes.Inutilizacoes);

    public Task GravarAsync(Inutilizacao inutilizacao, CancellationToken ct) => _colecao.InsertOneAsync(inutilizacao, cancellationToken: ct);

    public Task<IReadOnlyList<Inutilizacao>> ListarAsync(FiltroConsulta filtro, CancellationToken ct) => ContextoMongo.ListarAsync(_colecao, filtro, ct);
}

internal sealed class CartaCorrecaoRepository(ContextoMongo contexto) : ICartaCorrecaoRepository
{
    private readonly IMongoCollection<CartaCorrecao> _colecao = contexto.Colecao<CartaCorrecao>(Colecoes.CartasCorrecao);

    public Task GravarAsync(CartaCorrecao carta, CancellationToken ct) => _colecao.InsertOneAsync(carta, cancellationToken: ct);

    public Task<IReadOnlyList<CartaCorrecao>> ListarAsync(FiltroConsulta filtro, CancellationToken ct) => ContextoMongo.ListarAsync(_colecao, filtro, ct);
}
