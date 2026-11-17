namespace NfeServer.Domain.Fiscal;

/// <summary>
/// Autorizador de contingência SVC por UF do emitente (somente NF-e modelo 55;
/// NFC-e não tem SVC). Mesma tabela do servidor Delphi, corrigida: lá GO estava nas
/// duas listas (caía em SVC-AN) e DF em nenhuma. Conferir no Portal da NF-e a cada NT.
/// </summary>
public static class ContingenciaSvc
{
    private static readonly HashSet<string> UfsSvcRs = new(StringComparer.OrdinalIgnoreCase)
    {
        "AM", "BA", "CE", "GO", "MA", "MS", "MT", "PA", "PE", "PI", "PR",
    };

    public static TipoContingencia Para(string uf, bool contingenciaAtiva) =>
        !contingenciaAtiva ? TipoContingencia.Nenhuma
        : UfsSvcRs.Contains(uf.Trim()) ? TipoContingencia.SvcRs
        : TipoContingencia.SvcAn;

    public static bool Aplicavel(ModeloDocumento modelo) => modelo == ModeloDocumento.NFe;
}
