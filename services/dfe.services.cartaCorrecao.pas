unit dfe.services.cartaCorrecao;

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
  dfe.dao.cartaCorrecao,
  dfe.model.cartaCorrecao;

type
  TServicecartaCorrecao = class
  private
    Facbr: TACBrNFe;
    FcStat: integer;
    Fempresa: TEmpresa;
    FcartaCorrecao: TcartaCorrecao;
    Fmotivo: string;
  public
    constructor create(classcartaCorrecao: TcartaCorrecao);
    destructor destroy;
    procedure cartaCorrecao;
  end;

implementation

{ ----------------------------------------------------------------------------- }
procedure TServicecartaCorrecao.cartaCorrecao();
var
  duplicidade: boolean;
  dao: TDaocartaCorrecao;
begin
  FcStat := 5001;
  try
    Facbr.EventoNFe.Evento.Clear;
    with Facbr.EventoNFe.Evento.Add do
    begin
      infEvento.chNFe := FcartaCorrecao.chave;
      infEvento.cnpj := FcartaCorrecao.cnpj;
      infEvento.dhEvento := FcartaCorrecao.dataHora;
      infEvento.tpEvento := teCCe;
      infEvento.nSeqEvento := FcartaCorrecao.sequencia;
      infEvento.detEvento.xCorrecao := FcartaCorrecao.xCorrecao;

    end;
    try

      Facbr.EnviarEvento(1);
      FcStat := Facbr.WebServices.EnvEvento.cStat;
      Fmotivo := Facbr.WebServices.EnvEvento.xMotivo;

      if Assigned(Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0])
      then
      begin
        Fmotivo := Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.xMotivo;
        FcStat := Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.cStat;

        FcartaCorrecao.protocoloCce :=
          Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.nProt;

        FcartaCorrecao.xmlEvento :=
          Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.XML;
      end;
    except
      on e: exception do
      begin
        Fmotivo := e.Message;
      end;
    end;
  finally
    // GRAVAR SOMENTE SE NÃO FOR DUPLICIDADE
    FcartaCorrecao.cstat:=FcStat;
    FcartaCorrecao.xmotivo:=Fmotivo;
    if FcStat <> 573 then
    begin
      dao := TDaocartaCorrecao.create;
      try
        dao.gravarCartaCorrecao(FcartaCorrecao);
      finally
        FreeAndNil(dao);
      end;
    end;
  end;
end;
{ ----------------------------------------------------------------------------- }
constructor TServicecartaCorrecao.create(classcartaCorrecao: TcartaCorrecao);
begin
  try
    FcartaCorrecao := classcartaCorrecao;
    Fempresa := TEmpresa.create(classcartaCorrecao.cnpj);
    if Fempresa.cnpj = '' then
      raise exception.create('Nehuma empresa  cadastrada com o cnpj informado '
        + classcartaCorrecao.cnpj);
    Facbr := TACBrNFe.create(Nil);
    TAcbrConfig.SetAcbrObj(Facbr, Fempresa);
    cartaCorrecao;
  except
    on e: exception do
    begin
      gravalog('[Erro ao gerar cartaCorrecao ' + e.Message);
      FcartaCorrecao.cStat := 5001;
      FcartaCorrecao.xMotivo := e.Message;
    end;
  end;

end;

destructor TServicecartaCorrecao.destroy;
begin
  if Assigned(Facbr) then
    FreeAndNil(Facbr);
  if Assigned(Fempresa) then
    FreeAndNil(Fempresa);
end;

end.
