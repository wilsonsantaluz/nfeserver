unit dfe.lib.acbr.config;

interface

uses
  syncobjs,
  windows,
  sysutils,
  ACBrCAPICOM_TLB,
  System.NetEncoding,
  Classes,
  ACBrNFe,
  db,
  ACBrEAD,
  pcnConversao,
  pcnConversaoNFe,
  ACBrUtil,
  pcnNFeW,
  pcnNFeRTXT,
  pcnAuxiliar,
  ACBrDFeUtil,
  ACBrDFeSSL,
  XMLIntf,
  ACBrNFeWebServices,
  dfe.model.empresa,
  dfe.lib.util,
  Inifiles,
  Datasnap.DBClient,
  XMLDoc;

type
  TAcbrConfig = class
  Public
    Class procedure setAcbrObj(var emissor: TACBrNFe; empresa: Tempresa);
  end;

implementation

class procedure TAcbrConfig.setAcbrObj(var emissor: TACBrNFe;
  empresa: Tempresa);
var

  ilatencia: Integer;
  base64: TBase64Encoding;
  stm: TstringStream;
  outfile: TFileStream;
  ofile: string;
  odir: string;
begin
  try
    if empresa.certificadoPfx = '' then
      raise Exception.Create('Arquivo de certificados não informado');
    if empresa.senhaPfx = '' then
      raise Exception.Create('Senha do arquivo de certificado não informada');
    if empresa.uf = '' then
      raise Exception.Create('A uf da empresa não foi informada');
    emissor.Configuracoes.WebServices.IntervaloTentativas := 8 * 1000; //
    emissor.Configuracoes.WebServices.AguardarConsultaRet := 8 * 1000;
    ilatencia :=60 * 1000;
    emissor.Configuracoes.WebServices.Tentativas := 10;
    emissor.Configuracoes.WebServices.TimeOut := ilatencia;
    emissor.Configuracoes.Geral.IdentarXML := false;
    emissor.Configuracoes.Geral.RetirarAcentos := True;
    emissor.Configuracoes.Geral.RetirarEspacos := True;
    emissor.SSL.DescarregarCertificado;
    try
      odir := ExtractFilePath(GetModuleName(HInstance)) + 'certficados\';
      ofile := odir + empresa.nomecertificadoPfx;
      ForceDirectories(odir);
      if FileExists(ofile) then
        DeleteFile(ofile);
      stm := TstringStream.Create(empresa.certificadoPfx);
      outfile := TFileStream.Create(ofile, fmCreate);
      TNetEncoding.base64.Decode(stm, outfile);

      FreeAndNil(outfile);
      emissor.Configuracoes.Certificados.ArquivoPFX := ofile;
    except
      on e: Exception do
        raise Exception.Create('O certificado não pode ser decodificado ' +
          e.Message);

    end;
    emissor.Configuracoes.Certificados.Senha := empresa.senhaPfx;
    emissor.Configuracoes.Geral.SSLLib := libOpenSSL;
    emissor.Configuracoes.Geral.SSLHttpLib := httpOpenSSL;
    try
      emissor.SSL.CarregarCertificado;
    except
      on e: Exception do
        raise Exception.Create('O certificado não pode ser carregado ' +
          e.Message);

    end;
    if emissor.SSL.DadosCertificado.DataVenc <date then
      raise Exception.Create('O Cetificado esta vencido '+datetostr( emissor.SSL.DadosCertificado.DataVenc) );
    emissor.Configuracoes.WebServices.uf := empresa.uf;
    emissor.Configuracoes.Geral.Salvar := false;
    emissor.Configuracoes.Arquivos.SalvarEvento := false;
    emissor.Configuracoes.Arquivos.Salvar := false;
    emissor.Configuracoes.Arquivos.SepararPorDia := True;
    emissor.Configuracoes.Geral.ModeloDF := moNFe;
    emissor.Configuracoes.Geral.VersaoDF := ve400;
    if empresa.ambiente = 1 then
      emissor.Configuracoes.WebServices.ambiente := taProducao
    else
      emissor.Configuracoes.WebServices.ambiente := taHomologacao;

    emissor.Configuracoes.Arquivos.PathSalvar :=
      ExtractFilePath(GetModuleName(HInstance)) + 'XML_NFCE2\';

    emissor.Configuracoes.Arquivos.PathSchemas :=
      ExtractFilePath(GetModuleName(HInstance)) + 'Schemas\';

    if not DirectoryExists(emissor.Configuracoes.Arquivos.PathSchemas) then
    begin
      raise Exception.Create
        ('path de schemas para emissão de notas não definido ' +
        emissor.Configuracoes.Arquivos.PathSchemas);
    end;

    emissor.Configuracoes.Geral.ValidarDigest := false;
  finally

  end;
end;

end.
