using NfeServer.Domain.Comum;

namespace NfeServer.Domain.Fiscal;

public static class Justificativa
{
    /// <summary>Cancelamento e inutilização: 15 a 255 caracteres (leiaute NF-e 4.00).</summary>
    public static string Validar(string? texto, string campo = "Justificativa") =>
        ValidarTamanho(texto, campo, 15, 255);

    /// <summary>Carta de correção: 15 a 1000 caracteres.</summary>
    public static string ValidarCorrecao(string? texto) =>
        ValidarTamanho(texto, "Texto da correção", 15, 1000);

    private static string ValidarTamanho(string? texto, string campo, int minimo, int maximo)
    {
        var valor = texto?.Trim() ?? string.Empty;
        if (valor.Length < minimo || valor.Length > maximo)
            throw new RegraNegocioException($"{campo} deve ter entre {minimo} e {maximo} caracteres (informado: {valor.Length})");
        return valor;
    }
}
