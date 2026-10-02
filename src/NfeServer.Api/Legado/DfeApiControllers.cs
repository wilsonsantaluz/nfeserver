using Microsoft.AspNetCore.Mvc;
using NfeServer.Application.CasosDeUso;
using NfeServer.Application.Consultas;
using NfeServer.Domain.Comum;

namespace NfeServer.Api.Legado;

/// <summary>
/// /dfeapi/nfe: GET lista notas; POST/PUT despacham pelo campo "operacao" (validacao,
/// cancelamento, inutilizacao, cartacorrecao, imprimir), como o TNfeHttpHandler.
/// </summary>
[Route("dfeapi/nfe")]
public sealed class NfeLegadoController(
    AutorizarNotaFiscal autorizar,
    CancelarNotaFiscal cancelar,
    InutilizarNumeracao inutilizar,
    EmitirCartaCorrecao cartaCorrecao,
    ConsultarDocumentos consultas) : ControllerLegadoBase
{
    [HttpGet]
    public async Task<IActionResult> Listar(CancellationToken ct)
    {
        var filtro = FiltroConsulta.DeJson(await LerJsonAsync(), CamposFiltro.Notas);
        var notas = await consultas.ListarNotasAsync(filtro, ct);
        return JsonLegadoResult(new ListaLegada<NotaLegado>(notas.Select(MapeamentoLegado.ParaLegado).ToList()));
    }

    [HttpPost, HttpPut]
    public async Task<IActionResult> Executar(CancellationToken ct)
    {
        var json = await LerJsonAsync() ?? throw new RegraNegocioException("Requisição sem conteúdo json");
        var operacao = JsonLegado.Desserializar<RequisicaoLegada>(json).Operacao?.Trim().ToLowerInvariant();

        return operacao switch
        {
            "validacao" => await Validar(json, ct),
            "cancelamento" => await Cancelar(json, ct),
            "inutilizacao" => await Inutilizar(json, ct),
            "cartacorrecao" => await CartaCorrecao(json, ct),
            "imprimir" => await Imprimir(json, ct),
            _ => throw new RegraNegocioException($"operacao desconhecida {operacao}"),
        };
    }

    [HttpDelete]
    public IActionResult Excluir() =>
        Mensagem(CodigoErro, "Exclusão de notas não é suportada", StatusCodes.Status405MethodNotAllowed);

    private async Task<IActionResult> Validar(string json, CancellationToken ct)
    {
        var r = JsonLegado.Desserializar<ValidacaoRequestLegado>(json);
        var nota = await autorizar.ExecutarAsync(
            new SolicitacaoAutorizacao(r.Cnpj, r.Numero, r.Serie, r.Modelo, MapeamentoLegado.DeBase64(r.Xml), r.Txt), ct);
        return JsonLegadoResult(MapeamentoLegado.ParaValidacao(nota, r.Modelo));
    }

    private async Task<IActionResult> Cancelar(string json, CancellationToken ct)
    {
        var r = JsonLegado.Desserializar<CancelamentoRequestLegado>(json);
        var cancelamento = await cancelar.ExecutarAsync(new SolicitacaoCancelamento(
            r.Cnpj, r.Chave, r.Protocolo, r.Justificativa, r.Data == default ? null : r.Data, r.Numero, r.Serie, r.Ambiente), ct);
        return JsonLegadoResult(MapeamentoLegado.ParaLegado(cancelamento, xmlEmBase64: true));
    }

    private async Task<IActionResult> Inutilizar(string json, CancellationToken ct)
    {
        var r = JsonLegado.Desserializar<InutilizacaoRequestLegado>(json);
        var inutilizacao = await inutilizar.ExecutarAsync(new SolicitacaoInutilizacao(
            r.Cnpj, r.Modelo, r.Ano, r.Serie, r.NumeroInicial, r.NumeroFinal, r.Justificativa), ct);
        return JsonLegadoResult(MapeamentoLegado.ParaLegado(inutilizacao, xmlEmBase64: true));
    }

    private async Task<IActionResult> CartaCorrecao(string json, CancellationToken ct)
    {
        var r = JsonLegado.Desserializar<CartaCorrecaoRequestLegado>(json);
        var carta = await cartaCorrecao.ExecutarAsync(new SolicitacaoCartaCorrecao(
            r.Cnpj, r.Chave, r.Sequencia, r.XCorrecao, r.DataHora == default ? null : r.DataHora), ct);
        return JsonLegadoResult(MapeamentoLegado.ParaLegado(carta, xmlEmBase64: true));
    }

    /// <summary>Era um TODO no Delphi. Devolve {"codretorno":1,"msg":..,"arquivo":base64 do PDF}.</summary>
    private async Task<IActionResult> Imprimir(string json, CancellationToken ct)
    {
        var chave = JsonLegado.Desserializar<ChaveRequestLegado>(json).Chave;
        var danfe = await consultas.ObterDanfeAsync(chave, ct);
        return JsonLegadoResult(new { codretorno = 1, msg = "DANFE gerado", arquivo = danfe });
    }
}

[Route("dfeapi/nfe/info")]
public sealed class InfoLegadoController(ConsultarDocumentos consultas) : ControllerLegadoBase
{
    [HttpGet]
    public async Task<IActionResult> Obter(CancellationToken ct) =>
        JsonLegadoResult(MapeamentoLegado.ParaLegado(await consultas.ObterResumoAsync(ct)));
}

[Route("dfeapi/nfe/empresa")]
public sealed class EmpresaLegadoController(GerenciarEmpresas empresas) : ControllerLegadoBase
{
    private const int CodigoSucesso = 200; // o front compara codretorno == 200

    [HttpGet]
    public async Task<IActionResult> Listar(CancellationToken ct)
    {
        var filtro = FiltroConsulta.DeJson(await LerJsonAsync(), CamposFiltro.Empresas);
        var lista = await empresas.ListarAsync(filtro, ct);
        return JsonLegadoResult(new ListaLegada<EmpresaLegado>(lista.Select(MapeamentoLegado.ParaLegado).ToList()));
    }

    [HttpPost, HttpPut]
    public async Task<IActionResult> Gravar(CancellationToken ct)
    {
        var json = await LerJsonAsync() ?? throw new RegraNegocioException("Requisição sem conteúdo json");
        var mensagem = await empresas.GravarAsync(MapeamentoLegado.ParaDominio(JsonLegado.Desserializar<EmpresaLegado>(json)), ct);
        return Mensagem(CodigoSucesso, mensagem);
    }

    /// <summary>O Delphi devolvia texto puro aqui, e o front esperava JSON.</summary>
    [HttpDelete]
    public async Task<IActionResult> Excluir(CancellationToken ct)
    {
        var json = await LerJsonAsync() ?? throw new RegraNegocioException("Cnpj não informado");
        var mensagem = await empresas.ExcluirAsync(JsonLegado.Desserializar<EmpresaLegado>(json).Cnpj, ct);
        return Mensagem(CodigoSucesso, mensagem);
    }
}

[Route("dfeapi/cancelamentos")]
public sealed class CancelamentosLegadoController(ConsultarDocumentos consultas) : ControllerLegadoBase
{
    [HttpGet]
    public async Task<IActionResult> Listar(CancellationToken ct)
    {
        var lista = await consultas.ListarCancelamentosAsync(FiltroConsulta.DeJson(await LerJsonAsync(), CamposFiltro.Cancelamentos), ct);
        return JsonLegadoResult(new ListaLegada<CancelamentoLegado>(lista.Select(c => MapeamentoLegado.ParaLegado(c, xmlEmBase64: false)).ToList()));
    }
}

[Route("dfeapi/inutilizacoes")]
public sealed class InutilizacoesLegadoController(ConsultarDocumentos consultas) : ControllerLegadoBase
{
    [HttpGet]
    public async Task<IActionResult> Listar(CancellationToken ct)
    {
        var lista = await consultas.ListarInutilizacoesAsync(FiltroConsulta.DeJson(await LerJsonAsync(), CamposFiltro.Inutilizacoes), ct);
        return JsonLegadoResult(new ListaLegada<InutilizacaoLegado>(lista.Select(i => MapeamentoLegado.ParaLegado(i, xmlEmBase64: false)).ToList()));
    }
}

[Route("dfeapi/cartaCorrecao")]
public sealed class CartasCorrecaoLegadoController(ConsultarDocumentos consultas) : ControllerLegadoBase
{
    [HttpGet]
    public async Task<IActionResult> Listar(CancellationToken ct)
    {
        var lista = await consultas.ListarCartasCorrecaoAsync(FiltroConsulta.DeJson(await LerJsonAsync(), CamposFiltro.CartasCorrecao), ct);
        return JsonLegadoResult(new ListaLegada<CartaCorrecaoLegado>(lista.Select(c => MapeamentoLegado.ParaLegado(c, xmlEmBase64: false)).ToList()));
    }
}
