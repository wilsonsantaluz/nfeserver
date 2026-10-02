using System.Net;
using System.Security.Cryptography.X509Certificates;
using DFe.Classes.Entidades;
using DFe.Classes.Flags;
using DFe.Utils;
using NFe.Classes.Informacoes.Identificacao.Tipos;
using NFe.Utils;
using NfeServer.Domain.Entidades;
using NfeServer.Domain.Fiscal;
using ModeloDocumento = NfeServer.Domain.Fiscal.ModeloDocumento;
using ModeloZeus = DFe.Classes.Flags.ModeloDocumento;

namespace NfeServer.Infrastructure.Fiscal;

/// <summary>
/// Uma ConfiguracaoServico por chamada (nunca o singleton Instancia do Zeus), para que
/// requisições de empresas diferentes não compartilhem estado.
/// </summary>
internal static class ConfiguracaoZeus
{
    public static ConfiguracaoServico Criar(Empresa empresa, OpcoesSefaz opcoes, ModeloDocumento modelo, TipoEmissao tipoEmissao)
    {
        var validarSchemas = !string.IsNullOrWhiteSpace(opcoes.DiretorioSchemas) && Directory.Exists(opcoes.DiretorioSchemas);

        return new ConfiguracaoServico
        {
            Certificado = new ConfiguracaoCertificado
            {
                TipoCertificado = TipoCertificado.A1ByteArray,
                ArrayBytesArquivo = Convert.FromBase64String(empresa.CertificadoPfx),
                Senha = empresa.SenhaPfx,
                ManterDadosEmCache = true,
                CacheId = empresa.Cnpj,
                KeyStorageFlags = OperatingSystem.IsWindows() ? X509KeyStorageFlags.MachineKeySet : X509KeyStorageFlags.EphemeralKeySet,
            },
            TimeOut = opcoes.TimeoutMs,
            cUF = (Estado)Uf.Codigo(empresa.Uf),
            tpAmb = empresa.AmbienteSefaz == Ambiente.Producao ? TipoAmbiente.Producao : TipoAmbiente.Homologacao,
            tpEmis = tipoEmissao,
            ModeloDocumento = ParaZeus(modelo),
            VersaoLayout = VersaoServico.Versao400,
            // Com DefineVersaoServicosAutomaticamente as versões ficaram zeradas nos testes; definidas explicitamente.
            VersaoNFeAutorizacao = VersaoServico.Versao400,
            VersaoNFeRetAutorizacao = VersaoServico.Versao400,
            VersaoNfeConsultaProtocolo = VersaoServico.Versao400,
            VersaoNfeInutilizacao = VersaoServico.Versao400,
            VersaoNfeStatusServico = VersaoServico.Versao400,
            VersaoRecepcaoEventoCceCancelamento = VersaoServico.Versao100,
            ProtocoloDeSeguranca = SecurityProtocolType.Tls12,
            // Remover acentos depois da assinatura invalidaria o digest; o XML vai como o cliente gerou.
            RemoverAcentos = false,
            SalvarXmlServicos = false,
            ValidarSchemas = validarSchemas,
            DiretorioSchemas = validarSchemas ? opcoes.DiretorioSchemas : string.Empty,
            ValidarCertificadoDoServidor = opcoes.ValidarCertificadoServidor,
            UnZip = true,
        };
    }

    public static ModeloZeus ParaZeus(ModeloDocumento modelo) => modelo == ModeloDocumento.NFCe ? ModeloZeus.NFCe : ModeloZeus.NFe;
}
