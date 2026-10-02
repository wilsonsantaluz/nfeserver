using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using MongoDB.Bson;
using NfeServer.Application;
using NfeServer.Application.Abstracoes;
using NfeServer.Infrastructure.Certificados;
using NfeServer.Infrastructure.Fiscal;
using NfeServer.Infrastructure.Pdf;
using NfeServer.Infrastructure.Persistencia.Mongo;
using NfeServer.Infrastructure.Seguranca;

namespace NfeServer.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<OpcoesEmissao>(configuration.GetSection(OpcoesEmissao.Secao));
        services.Configure<OpcoesMongo>(configuration.GetSection(OpcoesMongo.Secao));
        services.Configure<OpcoesSefaz>(configuration.GetSection(OpcoesSefaz.Secao));
        services.Configure<OpcoesDanfe>(configuration.GetSection(OpcoesDanfe.Secao));
        services.Configure<OpcoesSeguranca>(configuration.GetSection(OpcoesSeguranca.Secao));

        var seguranca = configuration.GetSection(OpcoesSeguranca.Secao).Get<OpcoesSeguranca>() ?? new OpcoesSeguranca();
        var dataProtection = services.AddDataProtection()
            .SetApplicationName("NfeServer")
            .PersistKeysToFileSystem(new DirectoryInfo(seguranca.DiretorioChaves));
        if (OperatingSystem.IsWindows())
            dataProtection.ProtectKeysWithDpapi(protectToLocalMachine: true);

        services.AddMemoryCache();
        services.AddSingleton<ContextoMongo>();
        services.AddSingleton<INotaFiscalRepository, NotaFiscalRepository>();
        services.AddSingleton<IEmpresaRepository, EmpresaRepository>();
        services.AddSingleton<ICancelamentoRepository, CancelamentoRepository>();
        services.AddSingleton<IInutilizacaoRepository, InutilizacaoRepository>();
        services.AddSingleton<ICartaCorrecaoRepository, CartaCorrecaoRepository>();
        services.AddSingleton<IDashboardConsultas, DashboardConsultas>();

        services.AddSingleton<IProtetorSegredos, ProtetorSegredos>();
        services.AddSingleton<ProvedorCertificados>();
        services.AddSingleton<ICertificadoInspector, InspetorCertificado>();
        services.AddSingleton<ISefazNFeGateway, ZeusSefazNFeGateway>();
        services.AddSingleton<IDanfeService, DanfeService>();

        services.AddHealthChecks().AddCheck<MongoHealthCheck>("mongo");
        return services;
    }
}

internal sealed class MongoHealthCheck(ContextoMongo contexto) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            await contexto.Database.RunCommandAsync<BsonDocument>(new BsonDocument("ping", 1), cancellationToken: cancellationToken);
            return HealthCheckResult.Healthy();
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("MongoDB indisponível", ex);
        }
    }
}
