using System.Globalization;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;
using NfeServer.Infrastructure.Legado;

namespace NfeServer.Api.Legado;

/// <summary>Serialização no formato que o REST.Json do Delphi produzia e aceitava.</summary>
public static class JsonLegado
{
    public static readonly JsonSerializerOptions Opcoes = new()
    {
        PropertyNameCaseInsensitive = true, // o front envia "Ambiente" com A maiúsculo
        NumberHandling = JsonNumberHandling.AllowReadingFromString,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
        Converters = { new DataLegadaJsonConverter(), new InteiroFlexivelConverter() },
    };

    public static string Serializar<T>(T valor) => JsonSerializer.Serialize(valor, Opcoes);

    public static T Desserializar<T>(string json) where T : new() =>
        string.IsNullOrWhiteSpace(json) ? new T() : JsonSerializer.Deserialize<T>(json, Opcoes) ?? new T();
}

/// <summary>TObjectList&lt;T&gt; do Delphi vira {"ownsObjects":true,"listHelper":[...]} e o front lê listHelper.</summary>
public sealed record ListaLegada<T>(
    [property: JsonPropertyName("listHelper")] IReadOnlyList<T> ListHelper)
{
    [JsonPropertyName("ownsObjects")]
    public bool OwnsObjects => true;
}

/// <summary>Resposta de setResponse() do Delphi.</summary>
public sealed record MensagemLegada(
    [property: JsonPropertyName("codretorno")] int CodRetorno,
    [property: JsonPropertyName("msg")] string Msg);

internal sealed class DataLegadaJsonConverter : JsonConverter<DateTime>
{
    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options) =>
        reader.TokenType switch
        {
            JsonTokenType.String => DataLegada.Converter(reader.GetString()),
            JsonTokenType.Number => reader.GetDouble() is var oa && oa == 0 ? default : DateTime.FromOADate(oa),
            JsonTokenType.Null => default,
            _ => throw new JsonException($"Data inválida ({reader.TokenType})"),
        };

    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options) =>
        writer.WriteStringValue(DataLegada.Formatar(value));
}

/// <summary>O front manda números como string ou vazio (ex.: "numero": "").</summary>
internal sealed class InteiroFlexivelConverter : JsonConverter<int>
{
    public override int Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Number)
            return reader.TryGetInt32(out var inteiro) ? inteiro : (int)reader.GetDouble();
        if (reader.TokenType == JsonTokenType.String)
        {
            var texto = reader.GetString();
            return string.IsNullOrWhiteSpace(texto) ? 0 : int.Parse(texto, NumberStyles.Integer, CultureInfo.InvariantCulture);
        }
        if (reader.TokenType is JsonTokenType.True or JsonTokenType.False)
            return reader.GetBoolean() ? 1 : 0;
        return reader.TokenType == JsonTokenType.Null ? 0 : throw new JsonException($"Número inválido ({reader.TokenType})");
    }

    public override void Write(Utf8JsonWriter writer, int value, JsonSerializerOptions options) => writer.WriteNumberValue(value);
}
