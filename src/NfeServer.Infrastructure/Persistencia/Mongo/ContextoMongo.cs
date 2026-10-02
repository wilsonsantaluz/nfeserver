using Microsoft.Extensions.Options;
using MongoDB.Bson;
using MongoDB.Driver;
using NfeServer.Application.Consultas;

namespace NfeServer.Infrastructure.Persistencia.Mongo;

public sealed class OpcoesMongo
{
    public const string Secao = "Mongo";

    /// <summary>O FireDAC do Delphi usava o padrão localhost:27017.</summary>
    public string ConnectionString { get; set; } = "mongodb://localhost:27017";
    public string Database { get; set; } = "nfeDb";
}

/// <summary>Nomes das coleções do servidor Delphi (dfe.dao.base.pas).</summary>
internal static class Colecoes
{
    public const string Notas = "notas";
    public const string Empresas = "empresas";
    public const string Cancelamentos = "cancelamentos";
    public const string Inutilizacoes = "inutilizacoes";
    public const string CartasCorrecao = "cartacorrecao";
}

/// <summary>Singleton: o MongoClient já mantém o pool de conexões (o Delphi abria uma por DAO).</summary>
internal sealed class ContextoMongo
{
    public IMongoDatabase Database { get; }

    public ContextoMongo(IOptions<OpcoesMongo> opcoes)
    {
        MapeamentoMongo.Registrar();
        var cliente = new MongoClient(opcoes.Value.ConnectionString);
        Database = cliente.GetDatabase(opcoes.Value.Database);
    }

    public IMongoCollection<T> Colecao<T>(string nome) => Database.GetCollection<T>(nome);

    public static FilterDefinition<T> Filtro<T>(FiltroConsulta filtro)
    {
        var documento = new BsonDocument();
        foreach (var (campo, valor) in filtro.Condicoes)
            documento[campo] = BsonValue.Create(valor);
        return new BsonDocumentFilterDefinition<T>(documento);
    }

    public static async Task<IReadOnlyList<T>> ListarAsync<T>(IMongoCollection<T> colecao, FiltroConsulta filtro, CancellationToken ct) =>
        await colecao.Find(Filtro<T>(filtro))
            .Sort(Builders<T>.Sort.Descending("_id"))
            .Limit(filtro.Limite)
            .ToListAsync(ct);
}
