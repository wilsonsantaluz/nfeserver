using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Options;
using NfeServer.Domain.Comum;

namespace NfeServer.Api.Legado;

public sealed class OpcoesApiLegada
{
    public const string Secao = "ApiLegada";

    /// <summary>
    /// Charset das respostas. O Indy do Delphi respondia em iso-8859-1; troque para
    /// "iso-8859-1" se algum PDV exibir acentos quebrados.
    /// </summary>
    public string Charset { get; set; } = "utf-8";
}

/// <summary>
/// Base dos endpoints /dfeapi/* (contrato do servidor Delphi). Erros saem no corpo
/// {"codretorno":10,"msg":...}, como antes, mas com HTTP 400/500 em vez de 201.
/// </summary>
[ApiController]
[ApiExplorerSettings(GroupName = "legado")]
[ServiceFilter(typeof(FiltroErroLegado))]
public abstract class ControllerLegadoBase : ControllerBase
{
    protected const int CodigoErro = 10;

    protected ContentResult JsonLegadoResult<T>(T valor, int status = StatusCodes.Status200OK) =>
        new()
        {
            Content = JsonLegado.Serializar(valor),
            ContentType = $"application/json; charset={HttpContext.RequestServices.GetRequiredService<IOptions<OpcoesApiLegada>>().Value.Charset}",
            StatusCode = status,
        };

    protected ContentResult Mensagem(int codRetorno, string msg, int status = StatusCodes.Status200OK) =>
        JsonLegadoResult(new MensagemLegada(codRetorno, msg), status);

    /// <summary>
    /// O cliente legado manda o JSON no corpo (POST/PUT) ou cru na query string
    /// (GET/DELETE: /dfeapi/nfe?{"chave":"..."}).
    /// </summary>
    protected async Task<string?> LerJsonAsync()
    {
        string corpo;
        using (var leitor = new StreamReader(Request.Body, ObterEncoding(), detectEncodingFromByteOrderMarks: true))
            corpo = await leitor.ReadToEndAsync(HttpContext.RequestAborted);
        if (corpo.TrimStart().StartsWith('{'))
            return corpo;

        var query = Request.QueryString.HasValue ? Uri.UnescapeDataString(Request.QueryString.Value![1..]) : string.Empty;
        return query.TrimStart().StartsWith('{') ? query : null;
    }

    private Encoding ObterEncoding()
    {
        var charset = Request.GetTypedHeaders().ContentType?.Charset.Value;
        try
        {
            return string.IsNullOrEmpty(charset) ? Encoding.UTF8 : Encoding.GetEncoding(charset.Trim('"'));
        }
        catch (ArgumentException)
        {
            return Encoding.UTF8;
        }
    }
}

public sealed class FiltroErroLegado(ILogger<FiltroErroLegado> logger) : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        var (status, mensagem) = context.Exception switch
        {
            RegraNegocioException e => (StatusCodes.Status400BadRequest, e.Message),
            System.Text.Json.JsonException e => (StatusCodes.Status400BadRequest, $"Conteúdo json inválido: {e.Message}"),
            _ => (StatusCodes.Status500InternalServerError, $"Erro interno: {context.Exception.Message}"),
        };
        if (status >= 500)
            logger.LogError(context.Exception, "Erro na API legada {Metodo} {Caminho}", context.HttpContext.Request.Method, context.HttpContext.Request.Path);

        context.Result = new ContentResult
        {
            Content = JsonLegado.Serializar(new MensagemLegada(10, mensagem)),
            ContentType = "application/json; charset=utf-8",
            StatusCode = status,
        };
        context.ExceptionHandled = true;
    }
}
