using Microsoft.Extensions.Logging;

namespace NfeServer.Application.CasosDeUso;

internal static class Persistencia
{
    /// <summary>
    /// Depois de falar com a SEFAZ, uma falha de banco não pode esconder o retorno do cliente:
    /// registra em log crítico e segue.
    /// </summary>
    public static async Task GravarComSegurancaAsync(Func<Task> gravar, ILogger logger, string referencia, CancellationToken ct)
    {
        try
        {
            await gravar();
        }
        catch (Exception ex) when (ex is not OperationCanceledException || !ct.IsCancellationRequested)
        {
            logger.LogCritical(ex, "Falha ao gravar o resultado de {Referencia}", referencia);
        }
    }
}
