using NfeServer.Domain.Comum;
using NfeServer.Domain.Fiscal;

namespace NfeServer.Domain.Entidades;

public sealed class Empresa
{
    public string Cnpj { get; set; } = string.Empty;
    public string RazaoSocial { get; set; } = string.Empty;
    public string Endereco { get; set; } = string.Empty;
    public string Bairro { get; set; } = string.Empty;
    public string Cidade { get; set; } = string.Empty;
    public string CodMunicipio { get; set; } = string.Empty;
    public string Complemento { get; set; } = string.Empty;
    public string Numero { get; set; } = string.Empty;
    public string Uf { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public string InscricaoMunicipal { get; set; } = string.Empty;
    public string InscricaoEstadual { get; set; } = string.Empty;

    public string NomeCertificadoPfx { get; set; } = string.Empty;
    /// <summary>Arquivo PFX em base64.</summary>
    public string CertificadoPfx { get; set; } = string.Empty;
    /// <summary>Senha do PFX em texto puro (a proteção em repouso é feita pelo repositório).</summary>
    public string SenhaPfx { get; set; } = string.Empty;
    public DateTime Validade { get; set; }

    /// <summary>1 = produção; qualquer outro valor = homologação (contrato legado).</summary>
    public int Ambiente { get; set; }
    /// <summary>1 = contingência SVC manual ativada.</summary>
    public int Contigencia { get; set; }

    /// <summary>Código de Segurança do Contribuinte, obrigatório para NFC-e.</summary>
    public string Csc { get; set; } = string.Empty;
    public string IdCsc { get; set; } = string.Empty;

    public Ambiente AmbienteSefaz => Ambiente == 1 ? Fiscal.Ambiente.Producao : Fiscal.Ambiente.Homologacao;
    public bool ContingenciaAtiva => Contigencia == 1;
    public bool PossuiCertificado => !string.IsNullOrEmpty(CertificadoPfx) && !string.IsNullOrEmpty(SenhaPfx);
    public bool PossuiCsc => !string.IsNullOrWhiteSpace(Csc) && !string.IsNullOrWhiteSpace(IdCsc);

    public void Validar()
    {
        Cnpj = Fiscal.Cnpj.Normalizar(Cnpj);
        Uf = Uf.Trim().ToUpperInvariant();

        if (!Fiscal.Cnpj.EhValido(Cnpj))
            throw new RegraNegocioException($"Cnpj não informado ou inválido -> {Cnpj}");
        if (string.IsNullOrWhiteSpace(RazaoSocial))
            throw new RegraNegocioException("Razão social não informada");
        if (!Fiscal.Uf.EhValida(Uf))
            throw new RegraNegocioException("A UF da empresa não foi informada ou é inválida");
        if (string.IsNullOrEmpty(CertificadoPfx))
            throw new RegraNegocioException("Arquivo pfx não informado");
        if (string.IsNullOrEmpty(SenhaPfx))
            throw new RegraNegocioException("Senha do arquivo pfx não informada");
    }

    /// <summary>Mantém certificado, senha e CSC já gravados quando a atualização não os reenviar.</summary>
    public void PreservarSegredosDe(Empresa existente)
    {
        if (string.IsNullOrEmpty(CertificadoPfx))
        {
            CertificadoPfx = existente.CertificadoPfx;
            NomeCertificadoPfx = string.IsNullOrEmpty(NomeCertificadoPfx) ? existente.NomeCertificadoPfx : NomeCertificadoPfx;
        }
        if (string.IsNullOrEmpty(SenhaPfx))
            SenhaPfx = existente.SenhaPfx;
        if (string.IsNullOrEmpty(Csc))
            Csc = existente.Csc;
        if (string.IsNullOrEmpty(IdCsc))
            IdCsc = existente.IdCsc;
    }
}
