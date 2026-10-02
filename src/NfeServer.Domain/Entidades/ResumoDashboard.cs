namespace NfeServer.Domain.Entidades;

public sealed class ResumoDashboard
{
    public int NotasEmitidas { get; set; }
    public int NotasCanceladas { get; set; }
    public int NotasInutilizadas { get; set; }
    public int ErrosEmissao { get; set; }
    public DateTime DataUpdate { get; set; }
    public List<PontoAnalise> Analises { get; set; } = [];
}

/// <param name="Tipo">"VALIDADAS" ou "CANCELADAS" (valores esperados pelo front-end).</param>
public sealed record PontoAnalise(string Tipo, double Valor, DateTime Data);
