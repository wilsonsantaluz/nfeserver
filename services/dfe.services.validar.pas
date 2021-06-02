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
    procedure mydebug(msg: string);
  public

    FdadosConsulta: TdadosConsulta;
    function consultaChave(ochave: string): string;
    procedure validar();
    constructor create(Nota: Tnota);
  published
    property NfeCancelada: Boolean read FnfeCancelada write FnfeCancelada;
  end;

implementation

{ TNfeValidar }

constructor TNfeValidar.create(Nota: Tnota);
begin
  Fnota := Nota;
end;

procedure TNfeValidar.mydebug(msg: string);
begin
  // */
end;

procedure TNfeValidar.validar;
begin
  // TAcbrConfig.SetAcbrObj(FACBrNFe, FACBrNFe.NotasFiscais[0].nfe.Emit.CNPJCPF);
  if Facbr.NotasFiscais[0].nfe.Ide.tpAmb = taProducao then
  begin
    Facbr.Configuracoes.WebServices.Ambiente := taProducao;
  end
  else
  begin
    Facbr.Configuracoes.WebServices.Ambiente := taHomologacao;
    Facbr.NotasFiscais[0].nfe.infNFeSupl.qrCode := '';
  end;
  Facbr.Configuracoes.WebServices.UF :=
    CodigoParaUF(Facbr.NotasFiscais[0].nfe.Ide.cUF);
  Facbr.Configuracoes.Geral.VersaoDF := ve400;
  Try
    try
      Facbr.NotasFiscais[0].nfe.signature.Clear;

    except
    end;
    try
      Facbr.NotasFiscais[0].Assinar;
    except
    end;
    try
      Facbr.NotasFiscais[0].validar;
    except
    end;
    Facbr.WebServices.Envia(1, true);
  except
    on e: exception do
    begin
      FcStat := 5001;
      sMsg := e.Message;
    end;
  end;
  Fnota.Protocolo := Facbr.NotasFiscais.Items[0].nfe.procNFe.nProt;
  if Facbr.WebServices.Retorno.msg <> '' then
    sMsg := Facbr.WebServices.Enviar.msg;
  if Facbr.WebServices.Retorno.cstat > 0 then
    FcStat := Facbr.WebServices.Retorno.cstat;
  Facbr.NotasFiscais[0].GerarXML;

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
  // TAcbrConfig.SetAcbrObj(ocomp, FCnpjFilial);
  FnfeCancelada := false;
  try
    ocomp.WebServices.Consulta.NFeChave := ochave;
    Try
      ocomp.WebServices.Consulta.Executar;

      if ocomp.WebServices.Consulta.msg <> '' then
        sMsg := ocomp.WebServices.Consulta.msg;
      if Pos(ansiUpperCase('Código numérico'), ansiUpperCase(sMsg)) > 0 then
      begin
        mydebug('    [CONSULTA CHAVE] CHAVE GERADA COM CODIGO NUMERICO DIFERENTE'
          + 'TENTANDO ENCONTAR CHAVE NA MENSAGEM ' + sMsg);
        j := 0;
        j := Pos('[', sMsg);
        if j > 0 then
        begin
          ox := Copy(sMsg, j + 1, Length(sMsg));
          ox := Copy(ox, 0, Pos(']', ox) - 1);
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
      Fnota.Status := ocomp.WebServices.Consulta.cstat;
      Fnota.Motivo := ocomp.WebServices.Consulta.xmotivo;
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
        (Pos('<tpEvento>110111</tpEvento>',
        ocomp.WebServices.Consulta.RetWS) > 0) then
      begin

        FnfeCancelada := true;
        FdadosConsulta.nProt := ocomp.WebServices.Consulta.Protocolo;
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
