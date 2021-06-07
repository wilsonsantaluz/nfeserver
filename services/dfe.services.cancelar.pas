unit dfe.services.cancelar;

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
  dfe.model.cancelamentoRequest,
  dfe.model.empresa,
  dfe.lib.acbr.config,
  dfe.dao.cancelamento,
  dfe.model.cancelamento;

type
  TServiceCancelar = class
  private
    Facbr: TACBrNFe;
    FcStat: integer;
    Fempresa: TEmpresa;
    Fcancelamento: Tcancelamento;
    Fmotivo: string;
  public
    constructor create(nota: Tcancelamento);
    procedure cancelar;
  end;

implementation

procedure TServiceCancelar.cancelar();
var
  duplicidade: boolean;
  ochave: string;
  dao: TDaoCancelamento;
begin
  FcStat := 5001;
  try
    try
      ochave := Fcancelamento.chave;
      Facbr.EventoNFe.Evento.Clear;
      with Facbr.EventoNFe.Evento.Add do
      begin
        infEvento.chNFe := ochave;
        infEvento.cnpj := Fcancelamento.cnpj;

        infEvento.dhEvento := Fcancelamento.data;
        infEvento.tpEvento := teCancelamento;
        infEvento.detEvento.xJust := Fcancelamento.Justificativa;
        infEvento.detEvento.nProt := Fcancelamento.protocoloNota;
      end;
      try
        Facbr.EnviarEvento(1);
      except
        on e: exception do
        begin
          Fmotivo := e.Message;
        end;
      end;
      if Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Count > 0 then
      begin
        FcStat := Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.cstat;
        Fmotivo := Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.xmotivo;
      end;
      If (FcStat = 577) then
      begin
        try
          Facbr.EventoNFe.Evento[0].infEvento.dhEvento := now;
          Facbr.EnviarEvento(1);
        except
          on e: exception do
          begin
            Fmotivo := e.Message;
          end;
        end;
        FcStat := Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.cstat;
        Fmotivo := Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.xmotivo;

      end;
      If (FcStat = 135) or (FcStat = 155) then
      begin

        Fcancelamento.xmlRetorno := '<nfeCanc>' +
          Facbr.WebServices.EnvEvento.DadosMsg + #13#10 +
          Facbr.WebServices.EnvEvento.RetWS + '</nfeCanc>';

        if Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.nProt = '' Then
          Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
            .RetInfEvento.nProt := FormatDateTime('yymmddhhmmsszz', now);

        Fcancelamento.protocoloCancelamento :=
          Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.nProt;
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
    Fcancelamento.cstat := FcStat;
    Fcancelamento.xmotivo := Fmotivo;
    // GRAVAR SOMENTE SE NÃO FOR DUPLICIDADE
    if FcStat <> 573 then
    begin
      dao := TDaoCancelamento.create;
      try
        dao.gravarCancelamento(Fcancelamento);
      finally
        FreeAndNil(dao);
      end;
    end;
  end;
end;

constructor TServiceCancelar.create(nota: Tcancelamento);
begin
  try
    Fcancelamento := nota;

    Fempresa := TEmpresa.create(nota.cnpj);
    if Fempresa.cnpj = '' then
      raise exception.create('Nehuma empresa  cadastrada com o cnpj informado '
        + nota.cnpj);
    Facbr := TACBrNFe.create(Nil);
    TAcbrConfig.SetAcbrObj(Facbr, Fempresa);
    cancelar;
  except
    on e: exception do
    begin
      gravalog('[Erro ao cancelar ' + e.Message);
      Fcancelamento.cstat := 5001;
      Fcancelamento.xmotivo := e.Message;
    end;
  end;

end;

end.
