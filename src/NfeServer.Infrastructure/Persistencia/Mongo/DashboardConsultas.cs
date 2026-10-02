using System.Globalization;
using MongoDB.Bson;
using MongoDB.Driver;
using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Infrastructure.Legado;

namespace NfeServer.Infrastructure.Persistencia.Mongo;

/// <summary>
/// Resumo do dashboard. Correções em relação ao Delphi: agrupa por dia (o Delphi agrupava pela
/// data/hora exata, um ponto por nota), conta canceladas pela coleção de cancelamentos aceitos
/// (a flag "cancelada" nunca era gravada) e conta erros pelas notas sem protocolo (a coleção
/// "erros" nunca era populada).
/// </summary>
internal sealed class DashboardConsultas(ContextoMongo contexto, TimeProvider relogio) : IDashboardConsultas
{
    private const int DiasAnalise = 365;

    public async Task<ResumoDashboard> ObterResumoAsync(CancellationToken ct)
    {
        var notas = contexto.Colecao<BsonDocument>(Colecoes.Notas);
        var cancelamentos = contexto.Colecao<BsonDocument>(Colecoes.Cancelamentos);
        var inutilizacoes = contexto.Colecao<BsonDocument>(Colecoes.Inutilizacoes);

        var comProtocolo = new BsonDocument("protocolo", new BsonDocument("$gt", ""));
        var semProtocolo = new BsonDocument("$or", new BsonArray
        {
            new BsonDocument("protocolo", ""),
            new BsonDocument("protocolo", new BsonDocument("$exists", false)),
        });
        var cancelamentoAceito = new BsonDocument("cstat", new BsonDocument("$in",
            new BsonArray { CodigosRetorno.EventoRegistrado, CodigosRetorno.EventoRegistradoSemVinculo, CodigosRetorno.CancelamentoForaPrazo }));
        var inutilizacaoHomologada = new BsonDocument("cstat", CodigosRetorno.InutilizacaoHomologada);

        var inicio = relogio.GetLocalNow().Date.AddDays(-DiasAnalise).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

        var resumo = new ResumoDashboard
        {
            NotasEmitidas = (int)await notas.CountDocumentsAsync(comProtocolo, cancellationToken: ct),
            NotasCanceladas = (int)await cancelamentos.CountDocumentsAsync(cancelamentoAceito, cancellationToken: ct),
            NotasInutilizadas = (int)await inutilizacoes.CountDocumentsAsync(inutilizacaoHomologada, cancellationToken: ct),
            ErrosEmissao = (int)await notas.CountDocumentsAsync(semProtocolo, cancellationToken: ct),
            DataUpdate = relogio.GetLocalNow().DateTime,
        };

        resumo.Analises.AddRange(await AgruparPorDiaAsync(notas, comProtocolo, "dataEmissao", inicio, "VALIDADAS", ct));
        resumo.Analises.AddRange(await AgruparPorDiaAsync(cancelamentos, cancelamentoAceito, "data", inicio, "CANCELADAS", ct));
        return resumo;
    }

    private static async Task<IEnumerable<PontoAnalise>> AgruparPorDiaAsync(IMongoCollection<BsonDocument> colecao,
        BsonDocument filtro, string campoData, string inicio, string tipo, CancellationToken ct)
    {
        // Datas gravadas como string ISO (formato Delphi); os 10 primeiros caracteres são o dia.
        var dia = new BsonDocument("$substrCP", new BsonArray { "$" + campoData, 0, 10 });
        var pipeline = new[]
        {
            new BsonDocument("$match", new BsonDocument(filtro).Add(campoData, new BsonDocument { { "$type", "string" }, { "$gte", inicio } })),
            new BsonDocument("$group", new BsonDocument { { "_id", dia }, { "count", new BsonDocument("$sum", 1) } }),
            new BsonDocument("$sort", new BsonDocument("_id", 1)),
        };

        var grupos = await colecao.Aggregate<BsonDocument>(pipeline, cancellationToken: ct).ToListAsync(ct);
        return grupos.Select(g => new PontoAnalise(tipo, g["count"].ToDouble(), DataLegada.Converter(g["_id"].AsString)));
    }
}
