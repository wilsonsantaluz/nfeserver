unit dfe.services.inutilizar;

interface

uses

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
  ACBrEAD,
  pcnConversao,
  pcnConversaoNFe,
  ACBrUtil,
  pcnNFeW,
  pcnNFeRTXT,
  pcnAuxiliar,
  ACBrDFeUtil,
  XMLIntf,
  syncobjs,
  dfe.lib.util,
  dfe.model.inutilizacaoRequest,
  dfe.model.empresa,
  dfe.lib.acbr.config,
  dfe.dao.inutilizacao,
  dfe.model.inutilizacao;

type
  TServiceInutilizar = class
  private
    Facbr: TACBrNFe;
    FcStat: integer;
    Fempresa: TEmpresa;
    FInutilizacao: TInutilizacao;
    Fmotivo: string;
  public
    constructor create(classInutilizacao: TInutilizacao);
    destructor destroy;
    procedure inutilizar;
  end;

implementation

{ ----------------------------------------------------------------------------- }
destructor TServiceInutilizar.destroy;
begin
  if Assigned(Facbr) then
    FreeAndNil(Facbr);
  if Assigned(Fempresa) then
    FreeAndNil(Fempresa);
end;
{------------------------------------------------------------------------------}
procedure TServiceInutilizar.inutilizar();
var
  duplicidade: boolean;

  dao: TDaoInutilizacao;
begin
  FcStat := 5001;
  try
    try
      Facbr.EventoNFe.Evento.Clear;

      Facbr.WebServices.Inutiliza(FInutilizacao.cnpj,
        FInutilizacao.justificativa, FInutilizacao.ano, FInutilizacao.modelo,
        FInutilizacao.serie, FInutilizacao.numeroInicial,
        FInutilizacao.numeroFinal

        );

      if Facbr.WebServices.inutilizacao.Msg <> '' then
        Fmotivo := Facbr.WebServices.inutilizacao.Msg;
      FInutilizacao.xmlEvento :=
        UTF8Encode(Facbr.WebServices.inutilizacao.RetornoWS);
      FcStat := Facbr.WebServices.inutilizacao.cStat;
      if (FcStat = 102) or (FcStat = 563) then
      begin
        FInutilizacao.protocolo := Facbr.WebServices.inutilizacao.protocolo;
      end;

    except
      on e: exception do
      begin
        Fmotivo := e.Message;
        FcStat := 5001;
        gravalog(e.Message);
      end;
    end;
  finally
    FInutilizacao.cStat := FcStat;
    FInutilizacao.xmotivo := Fmotivo;
    // GRAVAR SOMENTE SE NÃO FOR DUPLICIDADE
    if FcStat <> 563 then
    begin
      dao := TDaoInutilizacao.create;
      try
        dao.gravarInutilizacao(FInutilizacao);
      finally
        FreeAndNil(dao);
      end;
    end;
  end;
end;

{ ----------------------------------------------------------------------------- }
constructor TServiceInutilizar.create(classInutilizacao: TInutilizacao);
begin
  try
    FInutilizacao := classInutilizacao;

    Fempresa := TEmpresa.create(classInutilizacao.cnpj);
    if Fempresa.cnpj = '' then
      raise exception.create('Nehuma empresa  cadastrada com o cnpj informado '
        + classInutilizacao.cnpj);
    Facbr := TACBrNFe.create(Nil);
    TAcbrConfig.SetAcbrObj(Facbr, Fempresa);
    inutilizar;
  except
    on e: exception do
    begin
      gravalog('[Erro ao Inutilizar ' + e.Message);
      FInutilizacao.cStat := 5001;
      FInutilizacao.xmotivo := e.Message;
    end;
  end;

end;

end.
