unit dfe.consumer.tester;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Xml.XmlTransform,
  Xml.XMLIntf,
  Xml.xmldom,
  System.JSON,
  Xml.XMLDoc,
  System.NetEncoding,
  dfe.databinding.nfe_v400,
  ShellApi,
  dfe.lib.util,
  System.DateUtils,

  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,
  // SEM ACBR
  {ACBrNFe,
    pcnConversao,
    pcnConversaoNFe,
    ACBrUtil,
    pcnNFeW,
    pcnNFeRTXT,
    pcnAuxiliar,
    ACBrDFeUtil,}

  Vcl.ComCtrls,
  rest.JSON,
  dfe.lib.http.Client,
  dfe.model.validacaoRequest,
  dfe.model.cancelamentoRequest,
  dfe.model.inutilizacaoRequest,
  dfe.model.inutilizacao,
  dfe.model.cancelamento,
  dfe.model.cartaCorrecao,
  dfe.model.cartaCorrecaoRequest,

  dfe.model.validacaoResponse

    ;

type
  Tfconsumer = class(TForm)
    Panel2: TPanel;
    pagutils: TPageControl;
    tabclass: TTabSheet;
    tabtransformer: TTabSheet;
    bt_xmltojson: TButton;
    bt_jsontoxml: TButton;
    memoxml: TMemo;
    memojson: TMemo;
    grouprequest: TGroupBox;
    memorequest: TMemo;
    Panel3: TPanel;
    btenviar: TButton;
    Panel4: TPanel;
    edtendereco: TEdit;
    Label1: TLabel;
    pnlcomands: TPanel;
    btgerarJson: TButton;
    memoviewxml: TMemo;
    Splitter1: TSplitter;
    Panel5: TPanel;
    cboperacao: TComboBox;
    Label2: TLabel;
    Splitter2: TSplitter;
    memoresponse: TMemo;
    tabgerarXml: TTabSheet;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    edtcnpj: TEdit;
    edtCodNumerico: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    edtnumeronota: TEdit;
    Label6: TLabel;
    edtserienota: TEdit;
    edtie: TEdit;
    Label7: TLabel;
    btgerarNfeTeste: TButton;
    edtim: TEdit;
    Label8: TLabel;
    GroupBox2: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    edtChave: TEdit;
    edtnumerocancelar: TEdit;
    edtsereriecancelar: TEdit;
    edtProtocolocancelamento: TEdit;
    edtJustificativa: TEdit;
    Label11: TLabel;
    edtcorrecao: TEdit;
    Label15: TLabel;
    edtsequencia: TEdit;
    GroupBox3: TGroupBox;
    Label17: TLabel;
    edtnuninicial: TEdit;
    Label16: TLabel;
    Edit1: TEdit;
    Label18: TLabel;
    edtnunfinal: TEdit;
    Label19: TLabel;
    edtjustinu: TEdit;
    Label20: TLabel;
    edtserieinu: TEdit;
    Label21: TLabel;
    edtanoinu: TEdit;
    GroupBox4: TGroupBox;
    edtconsultaChave: TEdit;
    Label22: TLabel;
    btconsultar: TButton;
    memoxmlRetornado: TMemo;
    Label23: TLabel;
    procedure bt_xmltojsonClick(Sender: TObject);
    procedure bt_jsontoxmlClick(Sender: TObject);
    procedure cboperacaoChange(Sender: TObject);
    procedure btgerarJsonClick(Sender: TObject);
    procedure btenviarClick(Sender: TObject);
    procedure btgerarNfeTesteClick(Sender: TObject);
    procedure getXmlDanfe(chave: string);
    procedure btconsultarClick(Sender: TObject);

  private
    { Private declarations }
    // VARIAVEIS QUE SERÃO USADAS PARA RETORNO NA THREAD DE CONSULTA

    FxmlNotaConsulta: string;

    procedure processarRetorno(Sender: TObject);
    procedure processarRetornoConsulta(Sender: TObject);

    procedure ImprimirDanfeRetornado(danfeBase64, name: string);
  public
    { Public declarations }
  end;

const
  DB_NAME = 'nfedb';
  COLLECTION_NAME = 'config';

var
  fconsumer: Tfconsumer;

implementation

uses

  dfe.lib.XmltoJson,
  consumer.model.nfe,
  dfe.lib.jsontoXml;
{$R *.dfm}

procedure Tfconsumer.getXmlDanfe(chave: string);
var
  Client: ThttpClient;
begin
  // REALIZA A CONSULTA EM FORMA DE THREAD

  Client := ThttpClient.Create(true);
  Client.host := edtendereco.Text;
  Client.Param := '{"chave":"' + chave + '"}';
  Client.TipoRequest := vget;
  Client.Paht := '/dfeapi/nfe';
  Client.OnTerminate := processarRetornoConsulta;
  Client.FreeOnTerminate := false;
  Client.resume;
  edtnumeronota.Text := '';

end;

{ ----------------------------------------------------------------------------- }
procedure Tfconsumer.bt_xmltojsonClick(Sender: TObject);
var
  Xml: iXMLDocument;
  list: TStringList;
  JSON: TJSONObject;
  XmltoJson: TXMLtoJSON;
begin
  Xml := XmltoJson.normalizeOrigin(memoxml.Text);
  list := XmltoJson.normalizeOrigin(Xml);
  JSON := XmltoJson.originTypeToReturnType(Xml);
  list := XmltoJson.normalizeReturn(JSON);
  memojson.lines := list;
end;

procedure Tfconsumer.btgerarNfeTesteClick(Sender: TObject);
var
  nota: iXMLTNFe;
  schave: string;
  dataEmiss: TDateTime;
begin
  dataEmiss := Now;
  if (edtnumeronota.Text = '') or (edtnumeronota.Text = '0') then
  begin
    edtnumeronota.Text := FormatDateTime('DDHHmmss', Now)
  end;

  if soNumeros(edtcnpj.Text) = '' then
    raise Exception.Create('Cnpj deve ser informado');
  if soNumeros(edtserienota.Text) = '' then
    raise Exception.Create('Serie da nota deve ser informado');
  if soNumeros(edtCodNumerico.Text) = '' then
    raise Exception.Create('Código numerico da nota deve ser informado');
  // SAO PAULO
  schave := MontaChaveAcessoNFe(35, dataEmiss, edtcnpj.Text, 55,
    strtoint(edtserienota.Text), strtoint(edtnumeronota.Text),
    strtoint(edtCodNumerico.Text), 2);
  // Criar o objeto com o databinding mapeado
  // na unit dfe.databinding.nfe_v400

  edtChave.Text := schave;
  edtnumerocancelar.Text := edtnumeronota.Text;
  edtsereriecancelar.Text := edtserienota.Text;

  nota := NewXMLDocument.GetDocBinding('NFe', TXMLTNFe, '') as iXMLTNFe;
  nota.InfNFe.Id := 'NFe' + schave;
  nota.InfNFe.Versao := '4.00';
  with nota.InfNFe.Ide do
  begin
    cUF := '41';
    cNF := edtCodNumerico.Text;
    natOp := 'VENDA PRODUTO';
    Mod_ := '55';
    serie := edtserienota.Text;
    nNF := edtnumeronota.Text;
    dhEmi := DateToISO8601(dataEmiss, false);
    dhSaiEnt := DateToISO8601(dataEmiss, false);
    tpNF := '1';
    idDest := '1';
    cMunFG := '4104808';
    tpImp := '1';
    tpEmis := '1'; // NORMAL
    cDV := '0';
    tpAmb := '2'; // HOMOLOGACAO
    finNFe := '1';
    indFinal := '0';
    indPres := '0';
    procEmi := '0';
    verProc := 'Nfeserver';
  end;
  with nota.InfNFe.Emit do
  begin
    CNPJ := edtcnpj.Text;
    xNome := 'EMPARE - EMPRESA PAULISTA DE REFRIGERANTES LTDA';
    xFant := 'EMPARE MATRIZ';
    enderEmit.xLgr := 'AV ANDROMEDA';
    enderEmit.nro := '885';
    enderEmit.xBairro := 'GREEN VALLEY ALPHAVILLE';
    enderEmit.cMun := '4104808';
    enderEmit.xMun := 'CASCAVEL';
    enderEmit.UF := 'PR';
    enderEmit.CEP := '85801040';
    enderEmit.cPais := '1058';
    enderEmit.xPais := 'BRASIL';
    IE := edtie.Text;
    IM := edtim.Text;
    CNAE := '0000000';
    CRT := '3';
  end;
  with nota.InfNFe.Dest do
  begin
    CNPJ := '09085717/0012-00';
    xNome := 'FILIAL 2 FLACER';
    enderDest.xLgr := 'AV LUIS STAMATIS';
    enderDest.nro := '41';
    enderDest.xBairro := 'VILA CONSTANCIA';
    enderDest.cMun := '4104808';
    enderDest.xMun := 'PARANA';
    enderDest.UF := 'PR';
    enderDest.CEP := '02260000';
    enderDest.cPais := '1058';
    enderDest.xPais := 'BRASIL';
    indIEDest := '1';
    IE := '9075777598';
    email := '';
  end;
  // ADOCIONAR OS PRODUTOS
  with nota.InfNFe.Det.Add do
  begin
    NItem := '1';
    prod.cProd := '49420';
    prod.cEAN := '7896261020269';
    prod.xProd := 'THERMO REATOR DE URANIO 235';
    prod.NCM := '30049049';
    prod.CEST := '1300401';
    prod.CFOP := '5403';
    prod.uCom := 'UN';
    prod.qCom := '2';
    prod.vUnCom := '123.4300';
    prod.vProd := '246.86';
    prod.cEANTrib := '7896261020269';
    prod.uTrib := 'UN';
    prod.qTrib := '2.0000';
    prod.vUnTrib := '123.4300';
    prod.vDesc := '69.96';
    prod.indTot := '1';
    prod.xPed := 'PBM';
    with imposto.ICMS do
    begin
      ICMS10.orig := '2';
      ICMS10.CST := '10';
      ICMS10.modBC := '3';
      ICMS10.vBC := '176.90';
      ICMS10.pICMS := '12.00';
      ICMS10.vICMS := '21.23';
      ICMS10.modBCST := '1';
      ICMS10.pRedBCST := '16.00';
      ICMS10.vBCST := '275.79';
      ICMS10.pICMSST := '18.00';
      ICMS10.vICMSST := '28.41';
    end;
    with imposto.ipi do
    begin
      cEnq := '999';
      IPINT.CST := '53';

    end;
    with imposto.PIS do
    begin
      PISNT.CST := '04';

    end;
    with imposto.COFINS do
    begin
      COFINSNT.CST := '04';
    end;

  end;
  with nota.InfNFe.Total do
  begin
    ICMSTot.vBC := '176.90';
    ICMSTot.vICMS := '21.23';
    ICMSTot.vICMSDeson := '0.00';
    ICMSTot.vFCPUFDest := '0.00';
    ICMSTot.vICMSUFDest := '0.00';
    ICMSTot.vICMSUFRemet := '0.00';
    ICMSTot.vFCP := '0.00';
    ICMSTot.vBCST := '275.79';
    ICMSTot.vST := '28.41';
    ICMSTot.vFCPST := '0.00';
    ICMSTot.vFCPSTRet := '0.00';
    ICMSTot.vProd := '246.86';
    ICMSTot.vFrete := '0.00';
    ICMSTot.vSeg := '0.00';
    ICMSTot.vDesc := '69.96';
    ICMSTot.vII := '0.00';
    ICMSTot.vIPI := '0.00';
    ICMSTot.vIPIDevol := '0.00';
    ICMSTot.vPIS := '0.00';
    ICMSTot.vCOFINS := '0.00';
    ICMSTot.vOutro := '0.00';
    ICMSTot.vNF := '205.31';
    ICMSTot.vTotTrib := '0.00';
  end;
  with nota.InfNFe.transp do
  begin
    modFrete := '0';
    transporta.CNPJ := '15488297000315';
    transporta.xNome := 'SAO GABRIEL TRANSPORTES EIRELI';
    transporta.IE := 'ISENTO';
    transporta.xEnder := 'R ITALIA, 663';
    transporta.xMun := 'IBAITI';
    transporta.UF := 'PR';

    with vol.Add do
    begin
      qVol := '1';
      esp := 'X';
      pesoL := '0.200';
      pesoB := '0.000';
    end;

  end;
  with nota.InfNFe.Cobr do
  begin
    Fat.NFat := '67623706';
    Fat.vOrig := '205.31';
    Fat.vDesc := '0.00';
    Fat.VLiq := '205.31';
    with dup.Add do
    begin
      nDup := '001';
      dVenc := '2021-08-03';
      vDup := '205.31';
    end;
  end;
  with nota.InfNFe.Pag.DetPag.Add do
  begin
    indPag := '1';
    tPag := '15';
    vPag := '205.31';
  end;
  with nota.InfNFe.infAdic do
  begin
    infAdFisco := 'Valor FCP: 0.00/ Valor FCPST: 0.00';
    infCpl := 'info cpl nota';
  end;

  with nota.InfNFe.compra do
  begin
    xPed := 'compra 0001';
  end;
  with nota.InfNFe.infRespTec do
  begin
    CNPJ := '11395536000170';
    xContato := 'wilson santa luz';
    email := '>wsinformatica@hotmail.com';
    fone := '5562993981242';
  end;
  // O PROPIO OBJETO RETORNA UM XML JA MONTADO
  memoxml.lines.Clear;
  memoresponse.lines.Clear;
  memorequest.lines.Clear;
  memoviewxml.lines.Clear;
  memoxml.lines.Text := nota.Xml;
end;

{ ----------------------------------------------------------------------------- }
procedure Tfconsumer.cboperacaoChange(Sender: TObject);
begin
  memoresponse.lines.Clear;
  memorequest.lines.Clear;
  memoviewxml.lines.Clear;
end;

procedure Tfconsumer.ImprimirDanfeRetornado(danfeBase64, name: string);
var
  outfile: TFileStream;
  strfile: TStringStream;
  sfile: string;
  astrean: TStringStream;
begin
  if danfeBase64 <> '' then
  begin
    sfile := ExtractFilePath(GetModuleName(HInstance)) + name;
    astrean := TStringStream.Create(danfeBase64);
    outfile := TFileStream.Create(sfile, fmCreate or fmOpenRead);
    try
      TNetEncoding.base64.Decode(astrean, outfile);
      FreeAndNil(outfile);
      ShellExecute(Handle, nil, PChar(sfile), nil, nil, SW_SHOWNORMAL);
    finally
      FreeAndNil(outfile);
      FreeAndNil(astrean);
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfconsumer.processarRetorno(Sender: TObject);
var
  sresult: string;
  Fclient: ThttpClient;
  responseValidacao: TValidacaoResponse;
  responseCancel: TCancelamento;
  responseInutilizacao: TInutilizacao;
  responseCartaCorrecao: dfe.model.cartaCorrecao.TcartaCorrecao;
begin
  Fclient := ThttpClient(Sender);
  if assigned(Fclient) then
  begin
    sresult := Fclient.response;
    memoresponse.lines.Text := sresult;
    case cboperacao.ItemIndex of
      0: // VALIDAÇÃO
        begin
          try
            // CASO CONSIGA COMUNICAR COM O SERVER RETORNARA A CLASSE TValidacaoResponse
            responseValidacao := Tjson.JsonToObject<TValidacaoResponse>
              (Fclient.response);
            memoviewxml.lines.Text := TNetEncoding.base64.Decode
              (responseValidacao.xmlRetorno);
            // ja prepara o cancelamento da nota validada
            edtProtocolocancelamento.Text := responseValidacao.protocolo;
            edtChave.Text := responseValidacao.chave;
            ShowMessage(IntToStr(responseValidacao.cstat) + ' - ' +
              responseValidacao.xmotivo);
            ImprimirDanfeRetornado(responseValidacao.danfeBase64,
              'Nfe-' + responseValidacao.chave + '.pdf');
          except
            on e: Exception do
              gravalog(e.Message);
          end;
        end;
      1: // CANCELAMENTO
        begin
          try
            // RETORNARA A CLASSE TCancelameto
            responseCancel := Tjson.JsonToObject<TCancelamento>
              (Fclient.response);
            memoviewxml.lines.Text := TNetEncoding.base64.Decode
              (responseCancel.xmlRetorno);
            ShowMessage(IntToStr(responseCancel.cstat) + ' - ' +
              responseCancel.xmotivo);

            ImprimirDanfeRetornado(responseCancel.danfe,
              'EventoCancel-' + responseCancel.chave + '.pdf');
          except
            on e: Exception do
              // TODO
          end;
        end;
      2: // INUTILIZACAO
        begin
          try
            // RETORNARA A CLASSE TInutilizacao
            responseInutilizacao := Tjson.JsonToObject<TInutilizacao>
              (Fclient.response);
            try
              memoviewxml.lines.Text := TNetEncoding.base64.Decode
                (responseInutilizacao.xmlEvento);
            except
              memoviewxml.lines.Text := responseInutilizacao.xmlEvento;
            end;
            ShowMessage(IntToStr(responseInutilizacao.cstat) + ' - ' +
              responseInutilizacao.xmotivo);

            ImprimirDanfeRetornado(responseInutilizacao.danfe,
              'Inutilizacao-' + IntToStr(responseInutilizacao.numeroInicial) +
              '_' + IntToStr(responseInutilizacao.numeroFinal) + '.pdf');
          except
            on e: Exception do
              // TODO
          end;
        end;

      3: // CARTA CORRECAO
        begin
          try
            // RETORNARA A CLASSE TCartaCorrecao
            responseCartaCorrecao :=
              Tjson.JsonToObject<dfe.model.cartaCorrecao.TcartaCorrecao>
              (Fclient.response);
            memoviewxml.lines.Text := TNetEncoding.base64.Decode
              (responseCartaCorrecao.xmlEvento);
            ShowMessage(IntToStr(responseCartaCorrecao.cstat) + ' - ' +
              responseCartaCorrecao.xmotivo);
            ImprimirDanfeRetornado(responseCartaCorrecao.danfe,
              'EventoCarta-' + responseCartaCorrecao.chave + '.pdf');
          except
            on e: Exception do
              // TODO
          end;
        end;
    end;
  end;
end;

procedure Tfconsumer.processarRetornoConsulta(Sender: TObject);
var
  Fnotas: Tnotas;
  Fclient: ThttpClient;
  outfile: TFileStream;
  strfile: TStringStream;
  sfile: string;
  astrean: TStringStream;

begin
  try
    Fclient := ThttpClient(Sender);
    if assigned(Fclient) then
    begin
      FxmlNotaConsulta := '';
      // SERIALIZAR A CLASSE DE NOTAS
      Fnotas := Tjson.JsonToObject<Tnotas>(Fclient.response);
      if Fnotas.Count > 0 then
      begin

        FxmlNotaConsulta := Fnotas.Items[0].Xml;
        memoxmlRetornado.lines.Text := FxmlNotaConsulta;
        if Fnotas.Items[0].danfe <> '' then
        begin
          sfile := ExtractFilePath(GetModuleName(HInstance)) + Fnotas.Items[0]
            .chave + '.pdf';
          astrean := TStringStream.Create(Fnotas.Items[0].danfe);
          outfile := TFileStream.Create(sfile, fmCreate or fmOpenRead);
          try
            TNetEncoding.base64.Decode(astrean, outfile);
            FreeAndNil(outfile);
            ShellExecute(Handle, nil, PChar(sfile), nil, nil, SW_SHOWNORMAL);
          finally
            FreeAndNil(outfile);
            FreeAndNil(astrean);
          end;
        end
        else
          ShowMessage('nota sem danfe armazenado !');
      end
      else
        ShowMessage('nota não localizada  !');
    end;
  except
    { TODO }

  end;

end;

{ ------------------------------------------------------------------------------ }
procedure Tfconsumer.btconsultarClick(Sender: TObject);
begin
  memoxmlRetornado.lines.Clear;
  getXmlDanfe(edtconsultaChave.Text)
end;

procedure Tfconsumer.btenviarClick(Sender: TObject);
var
  operacao: string;
  Client: ThttpClient;
begin
  //ALTERADO PARA REALIZAR O ENVIO DE FORMA SINCRONA
  if memorequest.lines.Text = '' then
    raise Exception.Create('request não informado');

  operacao := cboperacao.Text;
  Client := ThttpClient.Create(true);
  try
    Client.host := edtendereco.Text;
    Client.Param := memorequest.lines.Text;
    Client.TipoRequest := vpost;
    Client.Paht := '/dfeapi/nfe';
    //Client.OnTerminate := processarRetorno;
    Client.FreeOnTerminate := true;
    //CHAMAR O EXECUTE PARA PROCESSAMENTO SINCRONO
    Client.Execute;
    processarRetorno(Client);
    edtnumeronota.Text := '';
  finally
    { todo }
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfconsumer.btgerarJsonClick(Sender: TObject);
var
  reqValidar: TValidacaoRequest;
  reqCancelar: TCancelamentoRequest;
  reqInutilizar: TInutilizacaoRequest;
  reqCartaCorrecao: TcartaCorrecaoRequest;
  base64: TBase64Encoding;
begin

  case cboperacao.ItemIndex of
    0: // VALIDACAO
      begin

        btgerarNfeTeste.Click;
        base64 := TBase64Encoding.Create;
        reqValidar := TValidacaoRequest.Create;
        try
          // PARA TESTES CPJ DEVE SER CADASTRO NO CADASTRO DE EMPRESAS
          reqValidar.CNPJ := edtcnpj.Text;
          reqValidar.numero := strtoint(edtnumeronota.Text);
          reqValidar.serie := strtoint(edtserienota.Text);
          reqValidar.Xml := base64.Encode(memoxml.lines.Text);
          reqValidar.lote := '1';
          reqValidar.modelo := 55;
          memorequest.lines.Text := Tjson.ObjectToJsonString(reqValidar);
        finally
          FreeAndNil(reqValidar);
          FreeAndNil(base64);
        end;
      end;
    1: // EVENTO CANCELAMENTO
      begin
        reqCancelar := TCancelamentoRequest.Create;
        try
          reqCancelar.CNPJ := edtcnpj.Text;
          reqCancelar.chave := edtChave.Text;
          reqCancelar.numero := strtoint(edtnumerocancelar.Text);
          reqCancelar.serie := strtoint(edtsereriecancelar.Text);
          reqCancelar.protocolo := edtProtocolocancelamento.Text;
          reqCancelar.justificativa := edtJustificativa.Text;
          reqCancelar.Data := Now;
          reqCancelar.modelo := 55;
          memorequest.lines.Text := Tjson.ObjectToJsonString(reqCancelar);
        finally
          FreeAndNil(reqCancelar);

        end;
      end;

    2: // EVENTO INUTILIZACAO
      begin
        reqInutilizar := TInutilizacaoRequest.Create;
        try
          reqInutilizar.CNPJ := edtcnpj.Text;
          reqInutilizar.numeroInicial := strtoint(edtnuninicial.Text);
          reqInutilizar.numeroFinal := strtoint(edtnunfinal.Text);
          reqInutilizar.serie := strtoint(edtserieinu.Text);
          reqInutilizar.modelo := 55;
          reqInutilizar.justificativa := edtjustinu.Text;
          reqInutilizar.ano := strtoint(edtanoinu.Text);
          memorequest.lines.Text := Tjson.ObjectToJsonString(reqInutilizar);
        finally
          FreeAndNil(reqInutilizar);

        end;
      end;

    3: // EVENTO CARTA DE CORRECAO
      begin
        reqCartaCorrecao := TcartaCorrecaoRequest.Create;
        try
          reqCartaCorrecao.CNPJ := edtcnpj.Text;
          reqCartaCorrecao.chave := edtChave.Text;
          reqCartaCorrecao.dataHora := Now;
          reqCartaCorrecao.sequencia := strtoint(edtsequencia.Text);
          reqCartaCorrecao.xcorrecao := edtcorrecao.Text;
          memorequest.lines.Text := Tjson.ObjectToJsonString(reqCartaCorrecao);
        finally
          FreeAndNil(reqCartaCorrecao);

        end;
      end;
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfconsumer.bt_jsontoxmlClick(Sender: TObject);
var
  Xml: iXMLDocument;
  list: TStringList;
  JSON: TJSONObject;
  jsontoXml: TJSONtoXML;
begin
  JSON := jsontoXml.normalizeOrigin(memojson.Text);
  list := jsontoXml.normalizeOrigin(JSON);
  Xml := jsontoXml.originTypeToReturnType(JSON);
  list := jsontoXml.normalizeReturn(Xml);
  memoxml.lines.Text := list.Text
end;

{ ----------------------------------------------------------------------------- }
end.
