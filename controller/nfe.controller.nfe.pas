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
  dfe.dao.inutilizacao,
  dfe.dao.cartaCorrecao,
  dfe.services.validar,
  dfe.dao.cancelamento,
  dfe.model.infonfe,
  dfe.dao.infonfe,
  dfe.model.validacaoRequest,
  dfe.model.validacaoResponse,
  dfe.model.cancelamento,
  dfe.model.inutilizacao,
  dfe.model.cartaCorrecao,
  dfe.model.cancelamentoRequest,
  dfe.model.cartaCorrecaoRequest,
  dfe.model.inutilizacaoRequest,
  dfe.services.cancelar,
  dfe.services.inutilizar,
  dfe.services.cartaCorrecao,
  dfe.model.empresa;

type
  TNnfeController = class
  private

  public
    function validarNfe(pjson: TJSONObject): string;
    function cancelarNfe(pjson: TJSONObject): string;
    function inutilizarNfe(pjson: TJSONObject): string;
    function cartaCorrecao(pjson: TJSONObject): string;
    function listarNfe(pjson: TJSONObject): string;
    function listarCancelamentos(pjson: TJSONObject): string;
    function listarCartaCorrecao(pjson: TJSONObject): string;
    function listarInutilizacoes(pjson: TJSONObject): string;
    function getInfo(): string;
  end;

implementation

{ TNnfeController }
{ ----------------------------------------------------------------------------- }
function TNnfeController.cancelarNfe(pjson: TJSONObject): string;
var
  cancelamento: TCancelamento;
  service: TServiceCancelar;
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
    response.danfe := cancelamento.danfe;
  end;

begin
  try
    request := tjson.JsonToObject<TCancelamentoRequest>(pjson.tostring);
    cancelamento := TCancelamento.create();
    cancelamento.Cnpj := request.Cnpj;
    cancelamento.Numero := request.Numero;
    cancelamento.Serie := request.Serie;
    cancelamento.chave := request.chave;
    cancelamento.protocoloNota := request.protocolo;
    cancelamento.data := request.data;
    cancelamento.justificativa := request.justificativa;
    service := TServiceCancelar.create(cancelamento);
    setResponsebyNota();
    result := tjson.ObjectToJsonString(response);
  finally
    FreeAndNil(service);
    if assigned(response) then
      FreeAndNil(response);
  end;
end;

{ ----------------------------------------------------------------------------- }
function TNnfeController.cartaCorrecao(pjson: TJSONObject): string;
var
  cartaCorrecao: TcartaCorrecao;
  service: TServicecartaCorrecao;
  request: TcartaCorrecaoRequest;
  response: TcartaCorrecao;
  procedure setResponsebycartaCorrecao();
  begin
    response := TcartaCorrecao.create;
    response.Cnpj := cartaCorrecao.Cnpj;
    response.chave := cartaCorrecao.chave;
    response.dataHora := request.dataHora;
    response.sequencia := request.sequencia;
    response.xcorrecao := request.xcorrecao;
    response.xmotivo := cartaCorrecao.xmotivo;
    response.cstat := cartaCorrecao.cstat;
    response.xmlEvento := TNetEncoding.base64.Encode(cartaCorrecao.xmlEvento);
    response.danfe := cartaCorrecao.danfe;
    response.cstat := cartaCorrecao.cstat;
    response.xmotivo := cartaCorrecao.xmotivo;
    response.protocoloCce := cartaCorrecao.protocoloCce;
  end;

begin
  try
    request := tjson.JsonToObject<TcartaCorrecaoRequest>(pjson.tostring);
    cartaCorrecao := TcartaCorrecao.create();
    cartaCorrecao.Cnpj := request.Cnpj;
    cartaCorrecao.chave := request.chave;
    cartaCorrecao.dataHora := request.dataHora;
    cartaCorrecao.sequencia := request.sequencia;
    cartaCorrecao.xcorrecao := request.xcorrecao;

    service := TServicecartaCorrecao.create(cartaCorrecao);
    setResponsebycartaCorrecao();
    result := tjson.ObjectToJsonString(response);
  finally
    FreeAndNil(service);
    if assigned(response) then
      FreeAndNil(response);
  end;

end;

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
var
  inutilizacao: Tinutilizacao;
  service: TServiceInutilizar;
  request: TinutilizacaoRequest;
  response: Tinutilizacao;
  procedure setResponsebyInutilizacao();
  begin
    response := Tinutilizacao.create;
    response.Cnpj := inutilizacao.Cnpj;
    response.numeroInicial := inutilizacao.numeroInicial;
    response.numeroFinal := inutilizacao.numeroFinal;
    response.Serie := request.Serie;
    response.xmotivo := inutilizacao.xmotivo;
    response.justificativa := request.justificativa;
    response.xmlEvento := TNetEncoding.base64.Encode(inutilizacao.xmlEvento);
    response.ano := request.ano;
    response.cstat := inutilizacao.cstat;
    response.xmotivo := inutilizacao.xmotivo;
    response.protocolo := inutilizacao.protocolo;
    response.danfe := inutilizacao.danfe;
  end;

begin
  try
    request := tjson.JsonToObject<TinutilizacaoRequest>(pjson.tostring);
    inutilizacao := Tinutilizacao.create();
    inutilizacao.Cnpj := request.Cnpj;
    inutilizacao.numeroInicial := request.numeroInicial;
    inutilizacao.numeroFinal := request.numeroFinal;
    inutilizacao.Serie := request.Serie;
    inutilizacao.ano := request.ano;
    inutilizacao.modelo := request.modelo;
    inutilizacao.justificativa := request.justificativa;
    service := TServiceInutilizar.create(inutilizacao);
    setResponsebyInutilizacao();
    result := tjson.ObjectToJsonString(response);
  finally
    FreeAndNil(service);
    if assigned(response) then
      FreeAndNil(response);
  end;
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
    if assigned(dao) then
      FreeAndNil(dao);
  end;
end;

{ ----------------------------------------------------------------------------- }
function TNnfeController.listarCartaCorrecao(pjson: TJSONObject): string;
var
  dao: TDaoCartaCorrecao;
  cartas: TcartasCorrecao;
begin
  dao := TDaoCartaCorrecao.create;
  try
    if assigned(pjson) then
      cartas := dao.listCartaCorrecaos(pjson)
    else
      cartas := dao.listCartaCorrecaos(Nil);
    result := tjson.ObjectToJsonString(cartas);
  finally
    if assigned(cartas) then
      FreeAndNil(cartas);
    FreeAndNil(dao);
  end;
end;
{ ----------------------------------------------------------------------------- }

function TNnfeController.listarInutilizacoes(pjson: TJSONObject): string;
var
  dao: TDaoInutilizacao;
  inutilizacoes: TInutilizacoes;
begin
  dao := TDaoInutilizacao.create;
  try
    if assigned(pjson) then
      inutilizacoes := dao.listInutilizacaos(pjson)
    else
      inutilizacoes := dao.listInutilizacaos(Nil);
    result := tjson.ObjectToJsonString(inutilizacoes);
  finally
    if assigned(inutilizacoes) then
      FreeAndNil(inutilizacoes);
    FreeAndNil(dao);
  end;
end;

{ ----------------------------------------------------------------------------- }
function TNnfeController.listarCancelamentos(pjson: TJSONObject): string;
var
  dao: TDaoCancelamento;
  cancelamentos: Tcancelamentos;
begin
  dao := TDaoCancelamento.create;
  try
    if assigned(pjson) then
      cancelamentos := dao.listCancelamentos(pjson)
    else
      cancelamentos := dao.listCancelamentos(Nil);
    result := tjson.ObjectToJsonString(cancelamentos);
  finally
    if assigned(cancelamentos) then
      FreeAndNil(cancelamentos);
    FreeAndNil(dao);
  end;
end;

{ ----------------------------------------------------------------------------- }
function TNnfeController.validarNfe(pjson: TJSONObject): string;
var
  nota: Tnota;
  servicevalidar: TNfeValidar;
  request: TValidacaoRequest;
  response: TValidacaoResponse;
  procedure setResponsebyNota();
  begin

    response.danfeBase64 := servicevalidar.danfeBase64;
    response.Cnpj := nota.Cnpj;
    response.Numero := nota.Numero;
    response.Serie := nota.Serie;
    response.modelo := request.modelo;
    if nota.dataProcessamento > 0 then
    begin
      response.xmlProcesado := TNetEncoding.base64.Encode(nota.Xml);
      response.xmlRetorno := TNetEncoding.base64.Encode(nota.xmlRetorno);

    end;
    response.chave := nota.chave;
    response.xmotivo := nota.motivo;
    response.cstat := nota.status;
    response.protocolo := nota.protocolo;
    response.dataProcesamemento := nota.dataProcessamento;
    response.dataValidacao := nota.dataValidacao;
    response.digito := nota.digitoval;

  end;

begin
  request := tjson.JsonToObject<TValidacaoRequest>(pjson.tostring);
  response := TValidacaoResponse.create;
  nota := Tnota.create('');
  try
    nota.Cnpj := request.Cnpj;
    nota.Numero := request.Numero;
    nota.Serie := request.Serie;
    nota.Xml := TNetEncoding.base64.Decode(request.Xml);
    nota.Txt := request.Txt;
    servicevalidar := TNfeValidar.create(nota);
    setResponsebyNota();
    result := tjson.ObjectToJsonString(response);
  finally
    FreeAndNil(nota);
    FreeAndNil(response);
    if assigned(servicevalidar) then
      FreeAndNil(servicevalidar);

  end;
end;

{ ----------------------------------------------------------------------------- }
end.
