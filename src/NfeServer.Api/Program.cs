using System.Text;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.Extensions.Hosting.WindowsServices;
using NfeServer.Api.Infra;
using NfeServer.Api.Legado;
using NfeServer.Application;
using NfeServer.Domain.Comum;
using NfeServer.Infrastructure;
using NfeServer.Infrastructure.Seguranca;
using Serilog;

Encoding.RegisterProvider(CodePagesEncodingProvider.Instance); // iso-8859-1/windows-1252 de clientes legados

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    // Como serviço do Windows o diretório atual é System32.
    ContentRootPath = WindowsServiceHelpers.IsWindowsService() ? AppContext.BaseDirectory : null,
});

builder.Host.UseWindowsService(o => o.ServiceName = "NfeServer");
builder.Host.UseSerilog((contexto, log) => log.ReadFrom.Configuration(contexto.Configuration).Enrich.FromLogContext());

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.Configure<OpcoesApiLegada>(builder.Configuration.GetSection(OpcoesApiLegada.Secao));
builder.Services.AddScoped<FiltroErroLegado>();

builder.Services.AddControllers();
builder.Services.AddProblemDetails();
builder.Services.AddResponseCompression(o =>
{
    o.EnableForHttps = true;
    o.Providers.Add<GzipCompressionProvider>();
    o.Providers.Add<BrotliCompressionProvider>();
});

var origens = builder.Configuration.GetSection("Cors:Origens").Get<string[]>() ?? [];
builder.Services.AddCors(o => o.AddDefaultPolicy(p =>
{
    if (origens.Length > 0)
        p.WithOrigins(origens).AllowAnyHeader().AllowAnyMethod();
}));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(o =>
{
    o.SwaggerDoc("v2", new() { Title = "NfeServer API v2", Version = "v2" });
    o.SwaggerDoc("legado", new() { Title = "NfeServer API legada (/dfeapi)", Version = "legado" });
    o.DocInclusionPredicate((documento, api) => api.GroupName == documento);
});

var app = builder.Build();

app.UseSerilogRequestLogging();
app.UseExceptionHandler(erro => erro.Run(async contexto =>
{
    var excecao = contexto.Features.Get<IExceptionHandlerFeature>()?.Error;
    var regraNegocio = excecao is RegraNegocioException;
    contexto.Response.StatusCode = regraNegocio ? StatusCodes.Status400BadRequest : StatusCodes.Status500InternalServerError;
    await Results.Problem(
        title: regraNegocio ? "Requisição inválida" : "Erro interno",
        detail: regraNegocio || app.Environment.IsDevelopment() ? excecao?.Message : null,
        statusCode: contexto.Response.StatusCode).ExecuteAsync(contexto);
}));

app.UseResponseCompression();
app.UseDefaultFiles();
app.UseStaticFiles();
app.UseCors();
app.UseMiddleware<ApiKeyMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(o =>
    {
        o.SwaggerEndpoint("/swagger/v2/swagger.json", "v2");
        o.SwaggerEndpoint("/swagger/legado/swagger.json", "legado");
    });
}

app.MapControllers();
app.MapHealthChecks("/health");

if (builder.Configuration.GetSection(OpcoesSeguranca.Secao).Get<OpcoesSeguranca>()?.ApiKeys is not { Count: > 0 })
    app.Logger.LogWarning("Nenhuma ApiKey configurada (Seguranca:ApiKeys): a API está sem autenticação, como no servidor Delphi");

app.Run();

public partial class Program;
