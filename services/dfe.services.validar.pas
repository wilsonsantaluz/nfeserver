unit dfe.services.validar;

interface

uses
  classes,
  windows,
  pcnEventoNFe,
  dateUtils,
  SysUtils,
  inifiles,
  math,
  json,
  XSBuiltIns,
  Variants,
  activex,
  ACBrNFe,
  pcnConversao,
  pcnConversaoNFe,
  ACBrUtil,
  pcnNFeW,
  pcnNFeRTXT,
  pcnAuxiliar,
  ACBrDFeUtil,
  XMLIntf,
  syncobjs,
  ACBrCAPICOM_TLB,
  XMLDoc,
  dfe.lib.util,
  dfe.model.empresa,
  dfe.dao.log,
  dfe.dao.nfe,
  dfe.model.nfe;

type
  TdadosConsulta = record
    nProt: string;
    chave: string;
    versao: string;
    digito: string;
    data: tdatetime;
    xmotivo: string;
    cstat: Integer;
    xml: string;
  end;

type
  TNfeValidar = class
  private
    FcStat: Integer;
    sMsg: string;
    Fnota: Tnota;
    Facbr: TACBrNFe;
    FAutorizado: Boolean;
    FnfeCancelada: Boolean;
    Fempresa: Tempresa;
    procedure mydebug(msg: string);
    procedure prepararNfe();
    procedure setnotaByConsulta(source: Tnota);
  public

    FdadosConsulta: TdadosConsulta;
    function consultaChave(ochave: string): string;
    procedure validar();
    constructor create(var Nota: Tnota);
  published
    property NfeCancelada: Boolean read FnfeCancelada write FnfeCancelada;
  end;

implementation

uses
  dfe.lib.acbr.config;

{ TNfeValidar }
{ ----------------------------------------------------------------------------- }
constructor TNfeValidar.create(var Nota: Tnota);
var
  dao: TDaoNfe;
  opesquisa: tjsonObject;
  tmpNota: Tnota;
begin
  Fnota := Nota;
  try
    Fnota.dataProcessamento := 0;
    Fempresa := Tempresa.create(Nota.Cnpj);
    if Fempresa.Cnpj = '' then
      raise exception.create('Nehuma empresa  cadastrada com o cnpj informado '
        + Nota.Cnpj);
    Facbr := TACBrNFe.create(Nil);
    TAcbrConfig.setAcbrObj(Facbr, Fempresa);
    if Nota.xml <> '' then
    begin
      if pos('<infNFe>', Nota.xml) > 0 then
      begin
        Nota.xml := StringReplace(Nota.xml, '<infNFe>',
          '<infNFe versao="4.00" Id="NFe62210605651966001184550060006762371639684850">',
          [rfIgnoreCase]);
      end;

      Facbr.NotasFiscais.LoadFromString(Nota.xml);
    end
    else if Nota.txt <> '' then
    begin
      Facbr.NotasFiscais.LoadFromIni(Nota.txt)
    end;
    if Facbr.NotasFiscais.Count = 0 then
      raise exception.create
        ('Nota fiscal não pode ser gerada com os dados informados');
    Fnota.xml := Facbr.NotasFiscais[0].GerarXML;
    opesquisa := tjsonObject.create;
    opesquisa.AddPair('numero', TJSONNumber.create(Fnota.numero));
    opesquisa.AddPair('serie', TJSONNumber.create(Fnota.serie));
    opesquisa.AddPair('cnpj', Fnota.Cnpj);
    opesquisa.AddPair('ambiente', TJSONNumber.create(2));
    if Facbr.NotasFiscais[0].nfe.Ide.tpAmb = taProducao then
      opesquisa.AddPair('ambiente', TJSONNumber.create(1));
    dao := TDaoNfe.create();
    try
      tmpNota := dao.getNota(opesquisa);

      if tmpNota.protocolo <> '' then
      begin
        setnotaByConsulta(tmpNota);

      end
      else
        validar();
    finally
      FreeAndNil(dao);
      FreeAndNil(tmpNota);
    end;
  except
    on e: exception do
    begin
      mydebug('[Erro ao validar ' + e.Message);
      Fnota.status := 5001;
      Fnota.motivo := e.Message;
    end;
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TNfeValidar.mydebug(msg: string);
begin
  OutputDebugString(pchar(msg));
end;

procedure TNfeValidar.prepararNfe;
begin
  Facbr.NotasFiscais[0].nfe.Ide.dEmi := now;
  Facbr.NotasFiscais[0].nfe.Ide.hSaiEnt := now;
  try
    Facbr.NotasFiscais[0].nfe.signature.Clear;
  except
    on e: exception do
    begin
      mydebug('[Erro assinatura] ' + e.Message);
    end;
  end;
  try
    Facbr.NotasFiscais[0].Assinar;
  except
    on e: exception do
    begin
      mydebug('[Erro assinatura] ' + e.Message);
    end;
  end;

end;

procedure TNfeValidar.setnotaByConsulta(source: Tnota);
begin

  Fnota.chave := source.chave;
  Fnota.dataEmissao := source.dataEmissao;
  Fnota.xml := source.xml;
  Fnota.xmlRetorno := source.xmlRetorno;
  Fnota.status := source.status;
  Fnota.motivo := source.motivo;
  Fnota.dataValidacao := source.dataValidacao;
  Fnota.dataProcessamento := source.dataProcessamento;
  Fnota.protocolo := source.protocolo;
  Fnota.digitoval := source.digitoval;
end;

{ ------------------------------------------------------------------------------ }
procedure TNfeValidar.validar;
var
  schave: string;
  dao: TDaoNfe;
begin
  try
    schave := Facbr.NotasFiscais[0].nfe.infNFe.ID;
    Try
      Fnota.dataProcessamento := now;
      prepararNfe();
      Facbr.WebServices.Envia(1, true);
    except
      on e: exception do
      begin
        mydebug('[Erro validacao] ' + e.Message);
        FcStat := 5001;
        sMsg := e.Message;
      end;
    end;
    if Facbr.WebServices.Enviar.cstat = 204 then
    begin
      consultaChave(schave);
      if FdadosConsulta.nProt <> '' then
      begin
        FcStat := FdadosConsulta.cstat;
        Facbr.NotasFiscais[0].nfe.Ide.dEmi := FdadosConsulta.data;
        Facbr.NotasFiscais[0].nfe.Ide.hSaiEnt := FdadosConsulta.data;
        Facbr.NotasFiscais.Items[0].nfe.procNFe.nProt := FdadosConsulta.nProt;
        Facbr.NotasFiscais.Items[0].nfe.procNFe.cstat := FdadosConsulta.cstat;
        Facbr.NotasFiscais.Items[0].nfe.procNFe.xmotivo :=
          FdadosConsulta.xmotivo;
        Facbr.NotasFiscais.Items[0].nfe.procNFe.digVal := FdadosConsulta.digito;
        Facbr.NotasFiscais.Items[0].nfe.procNFe.dhRecbto := FdadosConsulta.data;
        Fnota.xml := Facbr.NotasFiscais[0].GerarXML;

      end;
    end
    else
    begin
      if Facbr.NotasFiscais.Items[0].nfe.procNFe.nProt <> '' then
      begin
        Fnota.protocolo := Facbr.NotasFiscais.Items[0].nfe.procNFe.nProt;
        Fnota.dataValidacao := Facbr.NotasFiscais.Items[0].nfe.procNFe.dhRecbto;
        Fnota.xml := Facbr.NotasFiscais[0].GerarXML;
      end;
      FcStat := Facbr.WebServices.Enviar.cstat;
      if Facbr.WebServices.Retorno.msg <> '' then
        sMsg := Facbr.WebServices.Enviar.msg;
      if Facbr.WebServices.Retorno.cstat > 0 then
        FcStat := Facbr.WebServices.Retorno.cstat;

      Fnota.xmlRetorno := Facbr.WebServices.Enviar.RetWS;
      if Facbr.WebServices.Retorno.RetornoWS <> '' then
        Fnota.xmlRetorno := Facbr.WebServices.Retorno.RetornoWS;
      Fnota.dataValidacao := Facbr.NotasFiscais.Items[0].nfe.procNFe.dhRecbto;
      Fnota.digitoval := Facbr.NotasFiscais.Items[0].nfe.procNFe.digVal;
    end;
  finally
    Fnota.status := FcStat;
    Fnota.motivo := sMsg;
    Fnota.chave := schave;
    Fnota.dataEmissao := Facbr.NotasFiscais[0].nfe.Ide.dEmi;
    // GRAVAR SOMENTE SE NÃO FOR DUPLICIDADE
    if Facbr.WebServices.Enviar.cstat <> 204 then
    begin
      dao := TDaoNfe.create;
      try
        dao.gravarNota(Fnota);
      finally
        FreeAndNil(dao);
      end;
    end;
  end;
end;

{ -------------------------------------------------------------------------------- }
function TNfeValidar.consultaChave(ochave: string): string;
var
  ocomp: TACBrNFe;
  ox: string;
  j, l: Integer;
  ievento: TRetInfEvento;
  sMsg: string;
begin
  result := '';
  ocomp := TACBrNFe.create(Nil);
  FdadosConsulta.nProt := '';
  FdadosConsulta.chave := '';
  FdadosConsulta.versao := '';
  FdadosConsulta.data := 0;
  FdadosConsulta.digito := '';
  FdadosConsulta.xmotivo := '';
  FdadosConsulta.cstat := -1;
  FdadosConsulta.xml := '';
  TAcbrConfig.setAcbrObj(ocomp, Fempresa);
  FnfeCancelada := false;
  try
    ocomp.WebServices.Consulta.NFeChave := ochave;
    Try
      ocomp.WebServices.Consulta.Executar;

      if ocomp.WebServices.Consulta.msg <> '' then
        sMsg := ocomp.WebServices.Consulta.msg;
      if pos(ansiUpperCase('Código numérico'), ansiUpperCase(sMsg)) > 0 then
      begin
        mydebug('    [CONSULTA CHAVE] CHAVE GERADA COM CODIGO NUMERICO DIFERENTE'
          + 'TENTANDO ENCONTAR CHAVE NA MENSAGEM ' + sMsg);
        j := 0;
        j := pos('[', sMsg);
        if j > 0 then
        begin
          ox := Copy(sMsg, j + 1, Length(sMsg));
          ox := Copy(ox, 0, pos(']', ox) - 1);
          if Length(Sonumeros(ox)) > 40 then
          begin
            mydebug('    [CONSULTA CHAVE] CHAVE DIVERGENTE ENCONTRADA ' + ox);
            ochave := Sonumeros(ox);
            ocomp.WebServices.Consulta.NFeChave := ochave;
            ocomp.WebServices.Consulta.Executar;
          end;
        end;
      end;

      FdadosConsulta.xmotivo := ocomp.WebServices.Consulta.xmotivo;
      FdadosConsulta.cstat := ocomp.WebServices.Consulta.cstat;
      Fnota.status := ocomp.WebServices.Consulta.cstat;
      Fnota.motivo := ocomp.WebServices.Consulta.xmotivo;
      if FdadosConsulta.cstat = 100 then
        FAutorizado := true;
      if ocomp.WebServices.Consulta.protNFe.nProt <> '' then
      begin

        FdadosConsulta.nProt := ocomp.WebServices.Consulta.protNFe.nProt;
        FdadosConsulta.chave := ocomp.WebServices.Consulta.protNFe.chNFe;
        FdadosConsulta.versao := ocomp.WebServices.Consulta.protNFe.verAplic;

        FdadosConsulta.data := ocomp.WebServices.Consulta.protNFe.dhRecbto;
        mydebug('    [CONSULTA CHAVE] CONSULTA CHAVE ' +
          ocomp.WebServices.Consulta.protNFe.chNFe + '  DataRetornada ' +
          datetimetostr(FdadosConsulta.data) + ' EVENTOS RETORNADOS ' +
          inttostr(ocomp.WebServices.Consulta.procEventoNFe.Count));
        FdadosConsulta.xmotivo := ocomp.WebServices.Consulta.protNFe.xmotivo;
        FdadosConsulta.cstat := ocomp.WebServices.Consulta.protNFe.cstat;
        FdadosConsulta.digito := ocomp.WebServices.Consulta.protNFe.digVal;
        FdadosConsulta.xml := ocomp.WebServices.Consulta.protNFe.XML_NFe;
      end;

      if (ocomp.WebServices.Consulta.procEventoNFe.Count > 0) and
        (ocomp.WebServices.Consulta.procEventoNFe[0]
        .RetEventoNFe.retEvento.Count > 0) then
      begin
        with ocomp.WebServices.Consulta.procEventoNFe[0].RetEventoNFe.retEvento
          [0].RetInfEvento do
        begin
          mydebug('    [CONSULTA CHAVE] EVENTO  [0] INFORMADO  ' +
            TpEventoToStr(tpEvento));
          FnfeCancelada := TpEventoToStr(tpEvento) = '110111';
          FdadosConsulta.nProt := nProt;
          FdadosConsulta.chave := chNFe;
          FdadosConsulta.versao := verAplic;
          FdadosConsulta.data := dhRegEvento;
          FdadosConsulta.digito := '';
          FdadosConsulta.xmotivo := xmotivo;
          FdadosConsulta.cstat := cstat;
          FdadosConsulta.xml := xml;
          if FnfeCancelada then
            mydebug('    [CONSULTA CHAVE 592] A NFCE ESTA CANCELADA PROTOCOLO  '
              + nProt);
        end;
      end;
      if ocomp.WebServices.Consulta.retCancNFe.nProt <> '' then
      begin
        FnfeCancelada := true;
        FdadosConsulta.nProt := ocomp.WebServices.Consulta.retCancNFe.nProt;
        FdadosConsulta.chave := ocomp.WebServices.Consulta.retCancNFe.chNFe;
        FdadosConsulta.versao := ocomp.WebServices.Consulta.retCancNFe.versao;
        FdadosConsulta.data := ocomp.WebServices.Consulta.retCancNFe.dhRecbto;
        FdadosConsulta.digito := '';
        FdadosConsulta.xmotivo := ocomp.WebServices.Consulta.retCancNFe.xmotivo;
        FdadosConsulta.cstat := ocomp.WebServices.Consulta.retCancNFe.cstat;
        FdadosConsulta.xml := ocomp.WebServices.Consulta.RetWS;
        if FnfeCancelada then
          mydebug('    [CONSULTA CHAVE 609] A NFCE ESTA CANCELADA PROTOCOLO  ' +
            ocomp.WebServices.Consulta.retCancNFe.nProt + ' - ' +
            ocomp.WebServices.Consulta.RetNFeDFe);
        sMsg := ocomp.WebServices.Consulta.retCancNFe.xmotivo;

      end;
      if (FnfeCancelada = false) and
        (pos('<tpEvento>110111</tpEvento>',
        ocomp.WebServices.Consulta.RetWS) > 0) then
      begin

        FnfeCancelada := true;
        FdadosConsulta.nProt := ocomp.WebServices.Consulta.protocolo;
        FdadosConsulta.chave := ocomp.WebServices.Consulta.NFeChave;
        FdadosConsulta.versao := ocomp.WebServices.Consulta.versao;
        FdadosConsulta.data := ocomp.WebServices.Consulta.dhRecbto;
        FdadosConsulta.digito := '';
        FdadosConsulta.xmotivo := ocomp.WebServices.Consulta.xmotivo;
        FdadosConsulta.cstat := ocomp.WebServices.Consulta.cstat;
        FdadosConsulta.xml := ocomp.WebServices.Consulta.RetWS;
        if FnfeCancelada then
          mydebug('    [CONSULTA CHAVE 630] A NFCE ESTA CANCELADA PROTOCOLO  ' +
            ocomp.WebServices.Consulta.retCancNFe.nProt);
        sMsg := ocomp.WebServices.Consulta.xmotivo;
      end;

      if (FnfeCancelada = false) and
        (ocomp.WebServices.Consulta.procEventoNFe.Count > 0) and
        (ocomp.WebServices.Consulta.procEventoNFe[0]
        .RetEventoNFe.retEvento.Count > 0) then
      begin
        ievento := ocomp.WebServices.Consulta.procEventoNFe[0]
          .RetEventoNFe.retEvento[0].RetInfEvento;

        FnfeCancelada := TpEventoToStr(ievento.tpEvento) = '110111';

        FdadosConsulta.nProt := ievento.nProt;
        FdadosConsulta.chave := ievento.chNFe;
        FdadosConsulta.versao := ievento.verAplic;
        FdadosConsulta.data := ievento.dhRegEvento;
        FdadosConsulta.digito := '';
        FdadosConsulta.xmotivo := ievento.xmotivo;
        FdadosConsulta.cstat := ievento.cstat;
        FdadosConsulta.xml := ievento.xml;
        if FnfeCancelada then
          mydebug('    [CONSULTA CHAVE 654] A NFCE ESTA CANCELADA PROTOCOLO  ' +
            ievento.nProt);

      end;

    except
      on e: exception do
      begin
        sMsg := e.Message;

      end;
    End;
  Finally
    FreeAndNil(ocomp);
    mydebug('     [CONSULTA CHAVE] RESULTADO CONSULTA ' + sMsg);
    result := sMsg
  end;
end;

end.
