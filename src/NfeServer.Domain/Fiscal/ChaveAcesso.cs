using System.Globalization;
using System.Text.RegularExpressions;
using NfeServer.Domain.Comum;

namespace NfeServer.Domain.Fiscal;

/// <summary>
/// Chave de acesso de 44 posições:
/// cUF(2) AAMM(4) CNPJ(14) mod(2) serie(3) nNF(9) tpEmis(1) cNF(8) cDV(1).
/// O CNPJ pode ser alfanumérico; o DV usa (ASCII - 48) por caractere, módulo 11.
/// </summary>
public readonly partial record struct ChaveAcesso
{
    public string Valor { get; }

    private ChaveAcesso(string valor) => Valor = valor;

    public int CodigoUf => int.Parse(Valor.AsSpan(0, 2), CultureInfo.InvariantCulture);
    public string Cnpj => Valor.Substring(6, 14);
    public ModeloDocumento Modelo => (ModeloDocumento)int.Parse(Valor.AsSpan(20, 2), CultureInfo.InvariantCulture);
    public int Serie => int.Parse(Valor.AsSpan(22, 3), CultureInfo.InvariantCulture);
    public long Numero => long.Parse(Valor.AsSpan(25, 9), CultureInfo.InvariantCulture);
    public int TipoEmissao => Valor[34] - '0';

    public override string ToString() => Valor;

    public static ChaveAcesso Parse(string? valor) =>
        TryParse(valor, out var chave)
            ? chave
            : throw new RegraNegocioException($"Chave de acesso inválida: '{valor}'");

    public static bool TryParse(string? valor, out ChaveAcesso chave)
    {
        chave = default;
        if (valor is null)
            return false;

        var normalizada = valor.Trim().ToUpperInvariant();
        if (normalizada.StartsWith("NFE", StringComparison.Ordinal))
            normalizada = normalizada[3..];

        if (normalizada.Length != 44 || !normalizada.All(char.IsAsciiLetterOrDigit))
            return false;
        if (!normalizada[..6].All(char.IsAsciiDigit) || !normalizada[20..].All(char.IsAsciiDigit))
            return false;
        if (CalcularDigito(normalizada.AsSpan(0, 43)) != normalizada[43] - '0')
            return false;

        chave = new ChaveAcesso(normalizada);
        return true;
    }

    public static ChaveAcesso Gerar(int codigoUf, DateTimeOffset dataEmissao, string cnpj, ModeloDocumento modelo,
        int serie, long numero, int tipoEmissao, string codigoNumerico)
    {
        var corpo = string.Concat(
            codigoUf.ToString("D2", CultureInfo.InvariantCulture),
            dataEmissao.ToString("yyMM", CultureInfo.InvariantCulture),
            Fiscal.Cnpj.Normalizar(cnpj).PadLeft(14, '0'),
            ((int)modelo).ToString("D2", CultureInfo.InvariantCulture),
            serie.ToString("D3", CultureInfo.InvariantCulture),
            numero.ToString("D9", CultureInfo.InvariantCulture),
            tipoEmissao.ToString(CultureInfo.InvariantCulture),
            codigoNumerico.PadLeft(8, '0'));

        if (corpo.Length != 43)
            throw new RegraNegocioException("Dados insuficientes para compor a chave de acesso");

        return new ChaveAcesso(corpo + CalcularDigito(corpo).ToString(CultureInfo.InvariantCulture));
    }

    /// <summary>
    /// Extrai a primeira chave válida de um texto, como o xMotivo das rejeições 204/539
    /// ("Duplicidade de NF-e [chNFe:3521...]").
    /// </summary>
    public static ChaveAcesso? ExtrairDeTexto(string? texto)
    {
        if (string.IsNullOrEmpty(texto))
            return null;
        foreach (Match m in CandidataRegex().Matches(texto.ToUpperInvariant()))
        {
            if (TryParse(m.Value, out var chave))
                return chave;
        }
        return null;
    }

    public static int CalcularDigito(ReadOnlySpan<char> corpo)
    {
        var soma = 0;
        var peso = 2;
        for (var i = corpo.Length - 1; i >= 0; i--)
        {
            soma += (corpo[i] - '0') * peso;
            peso = peso == 9 ? 2 : peso + 1;
        }
        var resto = soma % 11;
        return resto < 2 ? 0 : 11 - resto;
    }

    [GeneratedRegex("[0-9A-Z]{44}")]
    private static partial Regex CandidataRegex();
}
