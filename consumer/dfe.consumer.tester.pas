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

  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,

  acbrNfeNotasFiscais,
  PcnNfe,
  ACBrIntegrador,
  ACBrBase,
  ACBrDFe,
  ACBrNFe,
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
  dfe.model.validacaoResponse;

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
    ACBrNFe1: TACBrNFe;
    tabgerarXml: TTabSheet;
    procedure bt_xmltojsonClick(Sender: TObject);
    procedure bt_jsontoxmlClick(Sender: TObject);
    procedure cboperacaoChange(Sender: TObject);
    procedure btgerarJsonClick(Sender: TObject);
    procedure btenviarClick(Sender: TObject);
  private
    { Private declarations }
    procedure processarRetorno(Sender: TObject);
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

  dfe.lib.XmltoJson, dfe.lib.jsontoXml;
{$R *.dfm}

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

{ ----------------------------------------------------------------------------- }
procedure Tfconsumer.cboperacaoChange(Sender: TObject);
begin
  memoresponse.lines.Clear;
  memorequest.lines.Clear;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfconsumer.processarRetorno(Sender: TObject);
var
  sresult: string;
  Fclient: ThttpClient;
  responseValidacao: TValidacaoResponse;
  responseCancel: TCancelamento;
  responseInutilizacao: TInutilizacao;
  responseCartaCorrecao: TcartaCorrecao;
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
            ShowMessage(IntToStr(responseValidacao.cstat) + ' - ' +
              responseValidacao.xmotivo);
          except
            on e: exception do
              // TODO
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
          except
            on e: exception do
              // TODO
          end;
        end;
      2: // INUTILIZACAO
        begin
          try
            // RETORNARA A CLASSE TInutilizacao
            responseInutilizacao := Tjson.JsonToObject<TInutilizacao>
              (Fclient.response);

            memoviewxml.lines.Text := TNetEncoding.base64.Decode
              (responseInutilizacao.xmlEvento);
            ShowMessage(IntToStr(responseInutilizacao.cstat) + ' - ' +
              responseInutilizacao.xmotivo);
          except
            on e: exception do
              // TODO
          end;
        end;

      3: // CARTA CORRECAO
        begin
          try
            // RETORNARA A CLASSE TCartaCorrecao
            responseCartaCorrecao := Tjson.JsonToObject<TcartaCorrecao>
              (Fclient.response);
            memoviewxml.lines.Text := TNetEncoding.base64.Decode
              (responseCartaCorrecao.xmlEvento);
            ShowMessage(IntToStr(responseCartaCorrecao.cstat) + ' - ' +
              responseCartaCorrecao.xmotivo);
          except
            on e: exception do
              // TODO
          end;
        end;
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfconsumer.btenviarClick(Sender: TObject);
var
  operacao: string;
  Client: ThttpClient;
begin
  // EXEMPLO DE REQUISIÇÃO USANDO THREAD
  if memorequest.lines.Text = '' then
    raise exception.Create('request não informado');

  operacao := cboperacao.Text;
  Client := ThttpClient.Create(true);
  try

    Client.host := edtendereco.Text;
    Client.Param := memorequest.lines.Text;
    Client.TipoRequest := vpost;
    Client.Paht := '/dfeapi/nfe/';
    Client.OnTerminate := processarRetorno;
    Client.FreeOnTerminate := true;
    Client.resume
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
        base64 := TBase64Encoding.Create;
        reqValidar := TValidacaoRequest.Create;
        try
          // PARA TESTES CPJ DEVE SER CADASTRO NO CADASTRO DE EMPRESAS
          reqValidar.cnpj := '03075319000174';
          reqValidar.numero := 111;
          reqValidar.serie := 1;

          reqValidar.Xml := base64.Encode(memoxml.lines.Text);
          reqValidar.lote := '10';
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
          reqCancelar.cnpj := '03075319000174';
          reqCancelar.chave := '41210603075319000174550060006762371639684850';
          reqCancelar.numero := 1;
          reqCancelar.serie := 1;
          reqCancelar.protocolo := '141210000408196';
          reqCancelar.justificativa := 'EMISSAO COM ERRO';
          reqCancelar.Data := now;
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
          reqInutilizar.cnpj := '03075319000174';
          reqInutilizar.numeroInicial := 666;
          reqInutilizar.numeroFinal := 667;
          reqInutilizar.serie := 1;
          reqInutilizar.modelo := 55;
          reqInutilizar.justificativa := 'EMISSAO COM ERRO';
          reqInutilizar.ano := 2021;
          reqInutilizar.modelo := 55;
          memorequest.lines.Text := Tjson.ObjectToJsonString(reqInutilizar);
        finally
          FreeAndNil(reqInutilizar);

        end;
      end;

    3: // EVENTO CARTA DE CORRECAO
      begin
        reqCartaCorrecao := TcartaCorrecaoRequest.Create;
        try
          reqCartaCorrecao.cnpj := '03075319000174';
          reqCartaCorrecao.chave :=
            '41210603075319000174550060006762371639684850';
          reqCartaCorrecao.dataHora := now;
          reqCartaCorrecao.sequencia := 1;
          reqCartaCorrecao.xcorrecao := 'LOGRADOURO DO DESTINATARIO INVALIDO';
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
