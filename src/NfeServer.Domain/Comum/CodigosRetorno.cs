namespace NfeServer.Domain.Comum;

/// <summary>
/// Códigos de status (cStat) da SEFAZ usados nas regras do servidor, mais o código
/// interno 5001 herdado do servidor Delphi para erros locais.
/// </summary>
public static class CodigosRetorno
{
    public const int ErroInterno = 5001;

    public const int InutilizacaoHomologada = 102;
    public const int LoteRecebido = 103;
    public const int LoteProcessado = 104;
    public const int LoteEmProcessamento = 105;

    public const int Autorizada = 100;
    public const int Cancelada = 101;
    public const int AutorizadaForaPrazo = 150;
    public const int CanceladaForaPrazo = 151;

    public const int Duplicidade = 204;
    public const int DuplicidadeChaveDiferente = 539;
    public const int InutilizacaoDuplicada = 563;

    public const int EventoRegistrado = 135;
    public const int EventoRegistradoSemVinculo = 136;
    public const int CancelamentoForaPrazo = 155;
    public const int EventoDuplicado = 573;
    public const int DataHoraEventoRejeitada = 577;

    public static bool Autorizou(int cStat) => cStat is Autorizada or AutorizadaForaPrazo;

    /// <summary>Autorizadas e denegadas (110, 301, 302, 303) recebem protocolo.</summary>
    public static bool PossuiProtocolo(int cStat) => cStat is Autorizada or AutorizadaForaPrazo or 110 or 301 or 302 or 303;

    public static bool EventoAceito(int cStat) => cStat is EventoRegistrado or EventoRegistradoSemVinculo or CancelamentoForaPrazo;

    public static bool EhDuplicidade(int cStat) => cStat is Duplicidade or DuplicidadeChaveDiferente;
}
