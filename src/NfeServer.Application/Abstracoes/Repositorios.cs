using NfeServer.Application.Consultas;
using NfeServer.Domain.Entidades;

namespace NfeServer.Application.Abstracoes;

public interface IEmpresaRepository
{
    Task<Empresa?> ObterPorCnpjAsync(string cnpj, CancellationToken ct);
    Task<IReadOnlyList<Empresa>> ListarAsync(FiltroConsulta filtro, CancellationToken ct);
    /// <summary>Insere ou substitui pela chave CNPJ.</summary>
    Task GravarAsync(Empresa empresa, CancellationToken ct);
    Task<bool> ExcluirAsync(string cnpj, CancellationToken ct);
}

public interface INotaFiscalRepository
{
    /// <summary>Prefere o registro com protocolo quando houver duplicatas legadas.</summary>
    Task<NotaFiscal?> ObterPorChaveAsync(string chave, CancellationToken ct);
    Task<IReadOnlyList<NotaFiscal>> ListarAsync(FiltroConsulta filtro, CancellationToken ct);
    /// <summary>Insere ou substitui pela chave de acesso.</summary>
    Task GravarAsync(NotaFiscal nota, CancellationToken ct);
    Task MarcarCanceladaAsync(string chave, CancellationToken ct);
}

public interface ICancelamentoRepository
{
    Task GravarAsync(Cancelamento cancelamento, CancellationToken ct);
    Task<IReadOnlyList<Cancelamento>> ListarAsync(FiltroConsulta filtro, CancellationToken ct);
}

public interface IInutilizacaoRepository
{
    Task GravarAsync(Inutilizacao inutilizacao, CancellationToken ct);
    Task<IReadOnlyList<Inutilizacao>> ListarAsync(FiltroConsulta filtro, CancellationToken ct);
}

public interface ICartaCorrecaoRepository
{
    Task GravarAsync(CartaCorrecao carta, CancellationToken ct);
    Task<IReadOnlyList<CartaCorrecao>> ListarAsync(FiltroConsulta filtro, CancellationToken ct);
}

public interface IDashboardConsultas
{
    Task<ResumoDashboard> ObterResumoAsync(CancellationToken ct);
}
