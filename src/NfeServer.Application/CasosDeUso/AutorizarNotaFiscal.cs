using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NfeServer.Application.Abstracoes;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.CasosDeUso;

/// <param name="Xml">XML da NF-e/NFC-e já decodificado do base64.</param>
/// <param name="Txt">Formato INI do ACBr; mantido só para devolver erro explícito.</param>
public sealed record SolicitacaoAutorizacao(string Cnpj, long Numero, int Serie, int Modelo, string? Xml, string? Txt);

/// <summary>
/// Porta de TNfeValidar (Delphi): reaproveita nota já autorizada, envia à SEFAZ, trata
/// duplicidade (204/539) consultando o protocolo e monta o nfeProc + DANFE.
/// Erros locais voltam como cStat 5001 no corpo, igual ao contrato legado.
/// </summary>
public sealed class AutorizarNotaFiscal(
    IEmpresaRepository empresas,
    INotaFiscalRepository notas,
    ISefazNFeGateway sefaz,
    IDanfeService danfe,
    IOptions<OpcoesEmissao> opcoes,
    TimeProvider relogio,
    ILogger<AutorizarNotaFiscal> logger)
{
    public async Task<NotaFiscal> ExecutarAsync(SolicitacaoAutorizacao solicitacao, CancellationToken ct)
    {
        var nota = new NotaFiscal
        {
            Cnpj = Cnpj.Normalizar(solicitacao.Cnpj),
            Numero = solicitacao.Numero,
            Serie = solicitacao.Serie,
            Modelo = solicitacao.Modelo,
            Txt = solicitacao.Txt ?? string.Empty,
        };
        var enviado = false;

        try
        {
            var empresa = await EmpresaEmissora.ObterAsync(empresas, solicitacao.Cnpj, ct);
            var documento = sefaz.Preparar(empresa, ObterXml(solicitacao), ContingenciaSvc.Para(empresa.Uf, empresa.ContingenciaAtiva));
            PreencherIdentificacao(nota, documento);

            var existente = await notas.ObterPorChaveAsync(documento.Chave, ct);
            if (existente is { PossuiProtocolo: true })
            {
                logger.LogInformation("Nota {Chave} já possui protocolo {Protocolo}; devolvendo o registro gravado",
                    existente.Chave, existente.Protocolo);
                return existente;
            }

            nota.DataProcessamento = relogio.GetLocalNow().DateTime;
            nota.Xml = documento.XmlAssinado;
            var assincrono = opcoes.Value.UfsEnvioAssincrono.Contains(empresa.Uf, StringComparer.OrdinalIgnoreCase);

            enviado = true;
            var retorno = sefaz.Autorizar(empresa, documento, assincrono);
            nota.Status = retorno.CStat;
            nota.Motivo = retorno.XMotivo;
            nota.XmlRetorno = retorno.XmlRetorno;

            var protocolo = CodigosRetorno.EhDuplicidade(retorno.CStat) && retorno.Protocolo is not { NumeroProtocolo.Length: > 0 }
                ? ResolverDuplicidade(empresa, nota, documento, retorno)
                : retorno.Protocolo;

            if (protocolo is { NumeroProtocolo.Length: > 0 })
                RegistrarProtocolo(nota, documento, protocolo);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogError(ex, "Erro ao autorizar nota {Cnpj} {Serie}/{Numero}", nota.Cnpj, nota.Serie, nota.Numero);
            nota.Status = CodigosRetorno.ErroInterno;
            nota.Motivo = ex.Message;
        }

        // Um reenvio após falha de gravação cai na duplicidade e se recupera pela consulta de protocolo.
        if (enviado)
            await Persistencia.GravarComSegurancaAsync(() => notas.GravarAsync(nota, ct), logger, nota.Chave, ct);
        return nota;
    }

    private static string ObterXml(SolicitacaoAutorizacao solicitacao)
    {
        if (!string.IsNullOrWhiteSpace(solicitacao.Xml))
            return solicitacao.Xml;
        if (!string.IsNullOrWhiteSpace(solicitacao.Txt))
            throw new RegraNegocioException(
                "Envio em TXT/INI (formato ACBr) não é suportado; envie o XML da nota em base64 no campo 'xml'");
        throw new RegraNegocioException("Nota fiscal não pode ser gerada com os dados informados");
    }

    private static void PreencherIdentificacao(NotaFiscal nota, DocumentoPreparado documento)
    {
        nota.Chave = documento.Chave;
        nota.Numero = documento.Numero;
        nota.Serie = documento.Serie;
        nota.Modelo = (int)documento.Modelo;
        nota.Ambiente = (int)documento.Ambiente;
        nota.DataEmissao = documento.DataEmissao.DateTime;
    }

    private ProtocoloAutorizacao? ResolverDuplicidade(Empresa empresa, NotaFiscal nota, DocumentoPreparado documento, RetornoAutorizacao retorno)
    {
        var chaveConsulta = ChaveAcesso.ExtrairDeTexto(retorno.XMotivo)?.Valor ?? documento.Chave;
        logger.LogWarning("Duplicidade {CStat} para {Chave}; consultando protocolo da chave {ChaveConsulta}",
            retorno.CStat, documento.Chave, chaveConsulta);

        var consulta = sefaz.ConsultarProtocolo(empresa, chaveConsulta);
        nota.Cancelada = consulta.Cancelada;

        if (consulta.Protocolo is not { NumeroProtocolo.Length: > 0 } protocolo)
        {
            nota.Motivo = $"{retorno.XMotivo} | Consulta: {consulta.CStat} - {consulta.XMotivo}";
            return null;
        }

        if (protocolo.Chave != documento.Chave)
        {
            // Autorizada com outro cNF: o XML local não é o autorizado, então não dá para montar o nfeProc.
            nota.Motivo = $"{retorno.XMotivo} | NF-e já autorizada com a chave {protocolo.Chave}, protocolo {protocolo.NumeroProtocolo}";
            return null;
        }

        return protocolo;
    }

    private void RegistrarProtocolo(NotaFiscal nota, DocumentoPreparado documento, ProtocoloAutorizacao protocolo)
    {
        nota.Status = protocolo.CStat;
        nota.Motivo = protocolo.XMotivo;
        nota.Protocolo = protocolo.NumeroProtocolo;
        nota.DataValidacao = protocolo.DataRecebimento.DateTime;
        nota.DigitoVal = protocolo.DigestValue;
        nota.Xml = sefaz.MontarXmlProcessado(documento.XmlAssinado, protocolo.ProtocoloXml);

        if (CodigosRetorno.Autorizou(protocolo.CStat) && !nota.Cancelada)
            nota.Danfe = EmpresaEmissora.Base64(danfe.GerarDanfe(nota.Xml, documento.Modelo));
    }
}
