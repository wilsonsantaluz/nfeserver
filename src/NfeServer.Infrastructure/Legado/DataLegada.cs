using System.Globalization;

namespace NfeServer.Infrastructure.Legado;

/// <summary>
/// Formato de data do REST.Json do Delphi (joDateIsUTC): a hora local é escrita com sufixo
/// "Z" sem conversão, e TDateTime zero vira 1899-12-30. Usado no Mongo e na API legada para
/// conviver com o servidor Delphi durante a migração.
/// </summary>
public static class DataLegada
{
    public const string Formato = "yyyy-MM-dd'T'HH:mm:ss.fff'Z'";
    public static readonly DateTime ZeroDelphi = new(1899, 12, 30);

    private static readonly string[] FormatosAceitos =
    [
        "yyyy-MM-dd'T'HH:mm:ss.FFFFFFF",
        "yyyy-MM-dd'T'HH:mm:ss",
        "yyyy-MM-dd'T'HH:mm",
        "yyyy-MM-dd",
        "dd/MM/yyyy HH:mm:ss",
        "dd/MM/yyyy",
    ];

    public static string Formatar(DateTime valor) =>
        (valor == default ? ZeroDelphi : valor).ToString(Formato, CultureInfo.InvariantCulture);

    public static DateTime Converter(string? texto)
    {
        if (string.IsNullOrWhiteSpace(texto))
            return default;

        var limpo = texto.Trim();
        if (limpo.EndsWith('Z'))
            limpo = limpo[..^1];

        if (DateTime.TryParseExact(limpo, FormatosAceitos, CultureInfo.InvariantCulture, DateTimeStyles.None, out var data))
            return data == ZeroDelphi ? default : data;

        // ISO com offset explícito (ex.: dhEmi "2024-05-01T10:00:00-03:00")
        if (DateTimeOffset.TryParse(texto, CultureInfo.InvariantCulture, DateTimeStyles.None, out var comOffset))
            return comOffset.LocalDateTime;

        throw new FormatException($"Data inválida: '{texto}'");
    }
}
