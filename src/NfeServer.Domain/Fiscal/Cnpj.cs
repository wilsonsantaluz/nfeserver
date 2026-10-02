namespace NfeServer.Domain.Fiscal;

/// <summary>
/// Normalização e validação de CNPJ, incluindo o CNPJ alfanumérico (IN RFB 2.229/2024):
/// cada caractere vale (código ASCII - 48) no cálculo do dígito verificador.
/// </summary>
public static class Cnpj
{
    private static readonly int[] PesosPrimeiroDigito = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    private static readonly int[] PesosSegundoDigito = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    /// <summary>Remove máscara e espaços; mantém dígitos e letras em maiúsculas.</summary>
    public static string Normalizar(string? valor) =>
        valor is null
            ? string.Empty
            : new string(valor.Where(char.IsAsciiLetterOrDigit).Select(char.ToUpperInvariant).ToArray());

    public static bool EhValido(string? valor)
    {
        var cnpj = Normalizar(valor);
        if (cnpj.Length != 14 || !char.IsAsciiDigit(cnpj[12]) || !char.IsAsciiDigit(cnpj[13]))
            return false;
        if (cnpj.Distinct().Count() == 1)
            return false;

        var primeiro = CalcularDigito(cnpj.AsSpan(0, 12), PesosPrimeiroDigito);
        var segundo = CalcularDigito(cnpj.AsSpan(0, 13), PesosSegundoDigito);
        return cnpj[12] - '0' == primeiro && cnpj[13] - '0' == segundo;
    }

    private static int CalcularDigito(ReadOnlySpan<char> corpo, int[] pesos)
    {
        var soma = 0;
        for (var i = 0; i < corpo.Length; i++)
            soma += (corpo[i] - '0') * pesos[i];
        var resto = soma % 11;
        return resto < 2 ? 0 : 11 - resto;
    }
}
