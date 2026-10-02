using Microsoft.AspNetCore.Mvc;
using NfeServer.Application.CasosDeUso;
using NfeServer.Application.Consultas;
using NfeServer.Domain.Comum;
using NfeServer.Domain.Entidades;

namespace NfeServer.Api.V2;

/// <summary>
/// API REST nova. Rejeições da SEFAZ voltam 200 com o cStat no corpo (o documento foi
/// processado); erros locais (cStat 5001) voltam 422 com ProblemDetails.
/// </summary>
[ApiController]
[ApiExplorerSettings(GroupName = "v2")]
public abstract class ControllerV2Base : ControllerBase
{
    protected IActionResult Resultado<T>(int cStat, string motivo, T corpo) =>
        cStat == CodigosRetorno.ErroInterno
            ? Problem(title: "Não foi possível processar o documento", detail: motivo, statusCode: StatusCodes.Status422UnprocessableEntity)
            : Ok(corpo);

    protected static FiltroConsulta FiltroDaQuery(IQueryCollection query, IReadOnlySet<string> campos) =>
        FiltroConsulta.De(query.Select(q => KeyValuePair.Create<string, object?>(q.Key, ConverterValor(q.Value.ToString()))), campos);

    private static object ConverterValor(string valor) =>
        long.TryParse(valor, out var numero) ? numero
        : bool.TryParse(valor, out var booleano) ? booleano
        : valor;
}

[Route("api/v2/notas")]
public sealed class NotasController(
    AutorizarNotaFiscal autorizar,
    CancelarNotaFiscal cancelar,
    EmitirCartaCorrecao cartaCorrecao,
    ConsultarDocumentos consultas) : ControllerV2Base
{
    [HttpPost]
    [ProducesResponseType<NotaResponse>(StatusCodes.Status200OK)]
    public async Task<IActionResult> Emitir(EmitirNotaRequest request, CancellationToken ct)
    {
        var nota = await autorizar.ExecutarAsync(new SolicitacaoAutorizacao(request.Cnpj, 0, 0, 0, request.Xml, null), ct);
        return Resultado(nota.Status, nota.Motivo, NotaResponse.De(nota));
    }

    /// <summary>Filtros por igualdade: cnpj, numero, serie, modelo, status, protocolo, cancelada.</summary>
    [HttpGet]
    public async Task<IEnumerable<NotaResumoResponse>> Listar(CancellationToken ct) =>
        (await consultas.ListarNotasAsync(FiltroDaQuery(Request.Query, CamposFiltro.Notas), ct)).Select(NotaResumoResponse.De);

    [HttpGet("{chave}")]
    public async Task<NotaResponse> Obter(string chave, CancellationToken ct) =>
        NotaResponse.De(await consultas.ObterNotaAsync(chave, ct));

    [HttpGet("{chave}/danfe")]
    [Produces("application/pdf")]
    public async Task<IActionResult> Danfe(string chave, CancellationToken ct) =>
        File(Convert.FromBase64String(await consultas.ObterDanfeAsync(chave, ct)), "application/pdf", $"{chave}.pdf");

    [HttpPost("{chave}/cancelamento")]
    public async Task<IActionResult> Cancelar(string chave, CancelarNotaRequest request, CancellationToken ct)
    {
        var c = await cancelar.ExecutarAsync(new SolicitacaoCancelamento(request.Cnpj, chave, request.Protocolo, request.Justificativa, null, 0, 0, 0), ct);
        return Resultado(c.CStat, c.XMotivo, new EventoResponse(c.Chave, c.CStat, c.XMotivo, c.ProtocoloCancelamento, c.XmlRetorno));
    }

    [HttpPost("{chave}/cartas-correcao")]
    public async Task<IActionResult> CartaCorrecao(string chave, CartaCorrecaoRequest request, CancellationToken ct)
    {
        var c = await cartaCorrecao.ExecutarAsync(new SolicitacaoCartaCorrecao(request.Cnpj, chave, request.Sequencia, request.Correcao, null), ct);
        return Resultado(c.CStat, c.XMotivo, new EventoResponse(c.Chave, c.CStat, c.XMotivo, c.ProtocoloCce, c.XmlEvento));
    }
}

[Route("api/v2/inutilizacoes")]
public sealed class InutilizacoesController(InutilizarNumeracao inutilizar, ConsultarDocumentos consultas) : ControllerV2Base
{
    [HttpPost]
    public async Task<IActionResult> Inutilizar(InutilizarRequest r, CancellationToken ct)
    {
        var i = await inutilizar.ExecutarAsync(new SolicitacaoInutilizacao(r.Cnpj, r.Modelo, r.Ano, r.Serie, r.NumeroInicial, r.NumeroFinal, r.Justificativa), ct);
        return Resultado(i.CStat, i.XMotivo, new InutilizacaoResponse(i.CStat, i.XMotivo, i.Protocolo, i.DhRecbto == default ? null : i.DhRecbto, i.XmlEvento));
    }

    [HttpGet]
    public async Task<IEnumerable<InutilizacaoResponse>> Listar(CancellationToken ct) =>
        (await consultas.ListarInutilizacoesAsync(FiltroDaQuery(Request.Query, CamposFiltro.Inutilizacoes), ct))
        .Select(i => new InutilizacaoResponse(i.CStat, i.XMotivo, i.Protocolo, i.DhRecbto == default ? null : i.DhRecbto, i.XmlEvento));
}

[Route("api/v2/empresas")]
public sealed class EmpresasController(GerenciarEmpresas empresas) : ControllerV2Base
{
    [HttpGet]
    public async Task<IEnumerable<EmpresaResponse>> Listar(CancellationToken ct) =>
        (await empresas.ListarAsync(FiltroDaQuery(Request.Query, CamposFiltro.Empresas), ct)).Select(EmpresaResponse.De);

    [HttpGet("{cnpj}")]
    public async Task<IActionResult> Obter(string cnpj, CancellationToken ct)
    {
        var lista = await empresas.ListarAsync(FiltroConsulta.Por(CamposFiltro.Cnpj, Domain.Fiscal.Cnpj.Normalizar(cnpj)), ct);
        return lista.Count == 0 ? NotFound() : Ok(EmpresaResponse.De(lista[0]));
    }

    /// <summary>Campos de certificado, senha e CSC vazios mantêm os valores já gravados.</summary>
    [HttpPut("{cnpj}")]
    public async Task<IActionResult> Gravar(string cnpj, EmpresaRequest r, CancellationToken ct)
    {
        var mensagem = await empresas.GravarAsync(new Empresa
        {
            Cnpj = cnpj,
            RazaoSocial = r.RazaoSocial,
            Uf = r.Uf,
            Ambiente = r.Ambiente,
            Contigencia = r.Contingencia ? 1 : 0,
            Endereco = r.Endereco ?? string.Empty,
            Numero = r.Numero ?? string.Empty,
            Complemento = r.Complemento ?? string.Empty,
            Bairro = r.Bairro ?? string.Empty,
            Cidade = r.Cidade ?? string.Empty,
            CodMunicipio = r.CodMunicipio ?? string.Empty,
            Telefone = r.Telefone ?? string.Empty,
            InscricaoEstadual = r.InscricaoEstadual ?? string.Empty,
            InscricaoMunicipal = r.InscricaoMunicipal ?? string.Empty,
            NomeCertificadoPfx = r.NomeCertificadoPfx ?? string.Empty,
            CertificadoPfx = r.CertificadoPfxBase64 ?? string.Empty,
            SenhaPfx = r.SenhaPfx ?? string.Empty,
            Csc = r.Csc ?? string.Empty,
            IdCsc = r.IdCsc ?? string.Empty,
        }, ct);
        return Ok(new { mensagem });
    }

    [HttpDelete("{cnpj}")]
    public async Task<IActionResult> Excluir(string cnpj, CancellationToken ct)
    {
        await empresas.ExcluirAsync(cnpj, ct);
        return NoContent();
    }
}

[Route("api/v2/dashboard")]
public sealed class DashboardController(ConsultarDocumentos consultas) : ControllerV2Base
{
    [HttpGet]
    public Task<ResumoDashboard> Obter(CancellationToken ct) => consultas.ObterResumoAsync(ct);
}
