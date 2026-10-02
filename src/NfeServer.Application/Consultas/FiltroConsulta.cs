using System.Text.Json;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.Consultas;

/// <summary>
/// Filtro de igualdade com campos em lista branca. Substitui o repasse do JSON do cliente
/// direto para o MongoDB, que no Delphi permitia operadores arbitrários ($where, $ne...).
/// </summary>
public sealed class FiltroConsulta
{
    public const int LimitePadrao = 500;

    public static readonly FiltroConsulta Vazio = new(new Dictionary<string, object>(), LimitePadrao);

    public IReadOnlyDictionary<string, object> Condicoes { get; }
    public int Limite { get; }

    private FiltroConsulta(IReadOnlyDictionary<string, object> condicoes, int limite)
    {
        Condicoes = condicoes;
        Limite = limite;
    }

    public static FiltroConsulta DeJson(string? json, IReadOnlySet<string> camposPermitidos)
    {
        if (string.IsNullOrWhiteSpace(json))
            return Vazio;

        JsonDocument documento;
        try
        {
            documento = JsonDocument.Parse(json);
        }
        catch (JsonException)
        {
            throw new RegraNegocioException($"Conteúdo json inválido: {json}");
        }

        using (documento)
        {
            if (documento.RootElement.ValueKind != JsonValueKind.Object)
                throw new RegraNegocioException("O filtro deve ser um objeto JSON");

            return De(documento.RootElement.EnumerateObject().Select(p => KeyValuePair.Create(p.Name, ConverterJson(p.Value))),
                camposPermitidos);
        }
    }

    /// <summary>Campos fora da lista branca são ignorados (o cliente legado manda operacao, cdEmp...).</summary>
    public static FiltroConsulta De(IEnumerable<KeyValuePair<string, object?>> campos, IReadOnlySet<string> camposPermitidos)
    {
        var condicoes = new Dictionary<string, object>(StringComparer.Ordinal);
        foreach (var (nome, valor) in campos)
        {
            var campo = camposPermitidos.FirstOrDefault(c => c.Equals(nome, StringComparison.OrdinalIgnoreCase));
            if (campo is null || valor is null)
                continue;
            if (valor is not (string or long or int or double or bool))
                throw new RegraNegocioException($"Valor não permitido no filtro para o campo '{campo}'");

            condicoes[campo] = campo == CamposFiltro.Cnpj && valor is string cnpj ? Cnpj.Normalizar(cnpj) : valor;
        }
        return new FiltroConsulta(condicoes, LimitePadrao);
    }

    public static FiltroConsulta Por(string campo, object valor) =>
        new(new Dictionary<string, object> { [campo] = valor }, LimitePadrao);

    private static object? ConverterJson(JsonElement valor) =>
        valor.ValueKind switch
        {
            JsonValueKind.String => valor.GetString()!,
            JsonValueKind.Number when valor.TryGetInt64(out var inteiro) => inteiro,
            JsonValueKind.Number => valor.GetDouble(),
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            JsonValueKind.Null => null,
            _ => valor, // objeto/array (ex.: {"$ne": ...}): rejeitado em De se o campo for filtrável
        };
}

public static class CamposFiltro
{
    public const string Cnpj = "cnpj";

    public static readonly IReadOnlySet<string> Notas = new HashSet<string> { Cnpj, "numero", "serie", "modelo", "chave", "status", "protocolo", "cancelada" };
    public static readonly IReadOnlySet<string> Cancelamentos = new HashSet<string> { Cnpj, "numero", "serie", "chave", "cstat", "protocoloNota", "protocoloCancelamento" };
    public static readonly IReadOnlySet<string> Inutilizacoes = new HashSet<string> { Cnpj, "serie", "modelo", "ano", "numeroInicial", "numeroFinal", "cstat", "protocolo" };
    public static readonly IReadOnlySet<string> CartasCorrecao = new HashSet<string> { Cnpj, "chave", "sequencia", "cstat", "protocoloCCe" };
    public static readonly IReadOnlySet<string> Empresas = new HashSet<string> { Cnpj, "uf", "razaoSocial" };
}
