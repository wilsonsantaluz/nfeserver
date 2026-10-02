using NfeServer.Domain.Comum;

namespace NfeServer.Domain.Fiscal;

/// <summary>Conversão entre sigla da UF e código IBGE.</summary>
public static class Uf
{
    private static readonly IReadOnlyDictionary<string, int> Codigos = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
    {
        ["RO"] = 11, ["AC"] = 12, ["AM"] = 13, ["RR"] = 14, ["PA"] = 15, ["AP"] = 16, ["TO"] = 17,
        ["MA"] = 21, ["PI"] = 22, ["CE"] = 23, ["RN"] = 24, ["PB"] = 25, ["PE"] = 26, ["AL"] = 27,
        ["SE"] = 28, ["BA"] = 29, ["MG"] = 31, ["ES"] = 32, ["RJ"] = 33, ["SP"] = 35, ["PR"] = 41,
        ["SC"] = 42, ["RS"] = 43, ["MS"] = 50, ["MT"] = 51, ["GO"] = 52, ["DF"] = 53,
    };

    public static bool EhValida(string? sigla) => sigla is not null && Codigos.ContainsKey(sigla.Trim());

    public static int Codigo(string sigla) =>
        Codigos.TryGetValue(sigla.Trim(), out var codigo)
            ? codigo
            : throw new RegraNegocioException($"UF inválida: '{sigla}'");

    public static string Sigla(int codigo) =>
        Codigos.FirstOrDefault(p => p.Value == codigo).Key
        ?? throw new RegraNegocioException($"Código de UF inválido: {codigo}");
}
