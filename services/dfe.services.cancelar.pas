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
  dfe.model.nfe;

type
  TnfeCancelar = class
  private
    Facbr: TACBrNFe;
    FcStat: integer;
    Fnota: Tnota;
    Fmotivo: string;
  public
    constructor create(nota: Tnota);
    function cancelar: string;
  end;

implementation

function TnfeCancelar.cancelar(): string;

var

  Justificativa: string;
  str: string;
  ochave: string;
begin
  FcStat := 5001;

  result := '';
  try
    Justificativa := 'ERRO NA GERAÇÃO DO CUPON';
    // 1- PRODUCAO
    // 2-HOMOLOGACAO
    Facbr := TACBrNFe.create(Nil);
    Facbr.NotasFiscais.LoadFromFile(Fnota.xml);
    if (Facbr.NotasFiscais.Count > 0) then
    begin
      // TAcbrConfig.SetAcbrObj(Facbr, FCnpjFilial);
      ochave := Facbr.NotasFiscais[0].nfe.procNFe.chNFe;
      Facbr.Configuracoes.Geral.ModeloDF := moNFCe;
      Facbr.Configuracoes.WebServices.Ambiente := taProducao;
      Facbr.Configuracoes.WebServices.UF :=
        cuftouf(Facbr.NotasFiscais[0].nfe.Ide.cUF);
      Facbr.EventoNFe.Evento.Clear;
      with Facbr.EventoNFe.Evento.Add do
      begin
        infEvento.chNFe := Fnota.Chave;
        infEvento.cnpj := Fnota.cnpj;
        if Facbr.NotasFiscais.Count > 0 then
          infEvento.dhEvento := Facbr.NotasFiscais[0].nfe.Ide.dEmi
        Else
          infEvento.dhEvento := now;
        infEvento.tpEvento := teCancelamento;
        infEvento.detEvento.xJust := Justificativa;
        infEvento.detEvento.nProt := Fnota.Protocolo;
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

        result := '<nfeCanc>' + Facbr.WebServices.EnvEvento.DadosMsg + #13#10 +
          Facbr.WebServices.EnvEvento.RetWS + '</nfeCanc>';

        if Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.nProt = '' Then
          Facbr.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
            .RetInfEvento.nProt := FormatDateTime('yymmddhhmmsszz', now);

      end;
    end;
  except
    on exception do
    begin

    end;
  end;
end;

constructor TnfeCancelar.create(nota: Tnota);
begin
  Fnota := nota;
end;

end.
