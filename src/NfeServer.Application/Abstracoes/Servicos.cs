using NfeServer.Domain.Fiscal;

namespace NfeServer.Application.Abstracoes;

/// <summary>Geração de PDFs. Retorna null em caso de falha (o documento fiscal não depende do PDF).</summary>
public interface IDanfeService
{
    byte[]? GerarDanfe(string xmlProcessado, ModeloDocumento modelo);
    byte[]? GerarEvento(string xmlNfe, string xmlEvento);
}

public interface ICertificadoInspector
{
    /// <exception cref="Domain.Comum.RegraNegocioException">PFX inválido ou senha incorreta.</exception>
    InformacoesCertificado Inspecionar(string pfxBase64, string senha);
}

public sealed record InformacoesCertificado(string Titular, DateTime ValidoAte);
