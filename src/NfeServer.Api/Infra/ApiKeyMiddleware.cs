using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using NfeServer.Infrastructure.Seguranca;

namespace NfeServer.Api.Infra;

/// <summary>
/// Exige X-Api-Key em /dfeapi e /api quando há chaves configuradas. O Delphi não tinha
/// nenhuma autenticação; sem chaves configuradas o comportamento antigo é mantido (com aviso no log).
/// </summary>
public sealed class ApiKeyMiddleware(RequestDelegate next, IOptions<OpcoesSeguranca> opcoes)
{
    public const string Cabecalho = "X-Api-Key";
    private readonly byte[][] _chaves = opcoes.Value.ApiKeys.Where(k => k.Length > 0).Select(Encoding.UTF8.GetBytes).ToArray();

    public bool Ativo => _chaves.Length > 0;

    public async Task InvokeAsync(HttpContext context)
    {
        var caminho = context.Request.Path;
        var protegido = caminho.StartsWithSegments("/dfeapi") || caminho.StartsWithSegments("/api");
        if (!Ativo || !protegido || HttpMethods.IsOptions(context.Request.Method) || Autorizado(context))
        {
            await next(context);
            return;
        }

        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
        await context.Response.WriteAsJsonAsync(new { codretorno = 401, msg = "Acesso negado: informe o cabeçalho X-Api-Key" });
    }

    private bool Autorizado(HttpContext context)
    {
        var informada = Encoding.UTF8.GetBytes(context.Request.Headers[Cabecalho].ToString());
        return _chaves.Any(chave => CryptographicOperations.FixedTimeEquals(chave, informada));
    }
}
