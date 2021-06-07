unit nfe.controller.nfe;

interface

uses
  classes,
  Xml.XmlTransform,
  Xml.XMLIntf,
  Xml.xmldom,
  System.JSON,
  Xml.XMLDoc,
  REST.JSON.Types,
  REST.JSON,
  sysutils,
  dfe.lib.XmltoJson,
  dfe.lib.jsontoXml,
  System.NetEncoding,
  dfe.model.nfe,
  dfe.model.config,
  dfe.dao.nfe,
  dfe.services.validar,
  dfe.model.infonfe,
  dfe.dao.infonfe,
  dfe.model.validacaoRequest,
  dfe.model.validacaoResponse,
  dfe.model.cancelamento,
  dfe.model.cancelamentoRequest,
  dfe.services.cancelar,
  dfe.model.empresa;

type
  TNnfeController = class
  private
    Fmodel: Tnota;
  public
    function validarNfe(pjson: TJSONObject): string;
    function cancelarNfe(pjson: TJSONObject): string;
    function inutilizarNfe(pjson: TJSONObject): string;
    function listarNfe(pjson: TJSONObject): string;
    function getInfo(): string;
  end;

implementation

{ TNnfeController }
{ ----------------------------------------------------------------------------- }
function TNnfeController.cancelarNfe(pjson: TJSONObject): string;
var
  cancelamento: TCancelamento;
  dao: TDaoNfe;
  validador: TServiceCancelar;
  valxml: iXMLDocument;
  list: TStringList;
  ojson: TJSONObject;
  XmltoJson: TXMLtoJSON;
  request: TCancelamentoRequest;
  response: TCancelamento;
  procedure setResponsebyNota();
  begin
    response := TCancelamento.create;
    response.Cnpj := cancelamento.Cnpj;
    response.Numero := cancelamento.Numero;
    response.Serie := cancelamento.Serie;
    response.chave := request.chave;
    response.ambiente := request.ambiente;
    response.protocoloNota := request.protocolo;
    response.justificativa := request.justificativa;

    response.xmlRetorno := TNetEncoding.base64.Encode(cancelamento.xmlRetorno);
    response.data := request.data;
    response.cstat := cancelamento.cstat;
    response.xmotivo := cancelamento.xmotivo;
    response.protocoloCancelamento := cancelamento.protocoloCancelamento;

  end;

begin
  try
    request := tjson.JsonToObject<TCancelamentoRequest>(pjson.tostring);
    cancelamento := TCancelamento.create();
    cancelamento.Cnpj := request.Cnpj;
    cancelamento.Numero := request.Numero;
    cancelamento.Serie := request.Serie;
    cancelamento.chave := request.chave;
    cancelamento.protocoloNota:=request.protocolo;
    cancelamento.data:=request.data;
    cancelamento.justificativa:=request.justificativa;

    validador :=  TServiceCancelar.create(cancelamento);
    setResponsebyNota();
    result := tjson.ObjectToJsonString(response);
  finally
    FreeAndNil(validador);
  end;

end;

{ ----------------------------------------------------------------------------- }
function TNnfeController.getInfo: string;
var
  dao: TDaoInfoNfe;
  model: TinfoNfe;
begin
  dao := TDaoInfoNfe.create;
  model := dao.getInfoNfe();
  result := tjson.ObjectToJsonString(model);
end;

{ ----------------------------------------------------------------------------- }
function TNnfeController.inutilizarNfe(pjson: TJSONObject): string;
begin
  /// ***
end;

{ ----------------------------------------------------------------------------- }
function TNnfeController.listarNfe(pjson: TJSONObject): string;
var
  dao: TDaoNfe;
  notas: Tnotas;
begin
  dao := TDaoNfe.create;
  try
    if assigned(pjson) then
      notas := dao.listNotas(pjson)
    else
      notas := dao.listNotas(Nil);
    result := tjson.ObjectToJsonString(notas);
  finally
    if assigned(notas) then
      FreeAndNil(notas);
    FreeAndNil(dao);
  end;
end;

{ ----------------------------------------------------------------------------- }
function TNnfeController.validarNfe(pjson: TJSONObject): string;
var
  nota: Tnota;
  dao: TDaoNfe;
  validador: TNfeValidar;
  valxml: iXMLDocument;
  list: TStringList;
  ojson: TJSONObject;
  XmltoJson: TXMLtoJSON;
  request: TValidacaoRequest;
  response: TValidacaoResponse;
  procedure setResponsebyNota();
  begin
    response := TValidacaoResponse.create;
    response.Cnpj := nota.Cnpj;
    response.Numero := nota.Numero;
    response.Serie := nota.Serie;
    response.modelo := request.modelo;
    if nota.dataProcessamento > 0 then
    begin
      response.xmlProcesado := TNetEncoding.base64.Encode(nota.Xml);
      response.xmlRetorno := TNetEncoding.base64.Encode(nota.xmlRetorno);
    end;

    response.xmotivo := nota.motivo;
    response.cstat := nota.status;
    response.protocolo := nota.protocolo;
    response.dataProcesamemento := nota.dataProcessamento;
    response.dataValidacao := nota.dataValidacao;
    response.digito := nota.digitoval;
  end;

begin
  try
    request := tjson.JsonToObject<TValidacaoRequest>(pjson.tostring);
    nota := Tnota.create('');
    nota.Cnpj := request.Cnpj;
    nota.Numero := request.Numero;
    nota.Serie := request.Serie;
    nota.Xml := TNetEncoding.base64.Decode(request.Xml);
    nota.Txt := request.Txt;
    validador := TNfeValidar.create(nota);
    setResponsebyNota();
    result := tjson.ObjectToJsonString(response);
  finally
    FreeAndNil(validador);
  end;
end;

{ ----------------------------------------------------------------------------- }
end.
