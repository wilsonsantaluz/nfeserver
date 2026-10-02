using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using NfeServer.Application.CasosDeUso;

namespace NfeServer.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.TryAddSingleton(TimeProvider.System);
        services.AddScoped<AutorizarNotaFiscal>();
        services.AddScoped<CancelarNotaFiscal>();
        services.AddScoped<EmitirCartaCorrecao>();
        services.AddScoped<InutilizarNumeracao>();
        services.AddScoped<GerenciarEmpresas>();
        services.AddScoped<ConsultarDocumentos>();
        return services;
    }
}
