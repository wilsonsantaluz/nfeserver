namespace NfeServer.Domain.Fiscal;

public enum ModeloDocumento
{
    NFe = 55,
    NFCe = 65,
}

public enum Ambiente
{
    Producao = 1,
    Homologacao = 2,
}

public enum TipoContingencia
{
    Nenhuma,
    SvcAn,
    SvcRs,
}
