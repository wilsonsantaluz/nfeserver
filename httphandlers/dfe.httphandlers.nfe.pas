unit dfe.httphandlers.nfe;

interface

uses
  math,
  System.SysUtils,
  IdCoder3to4,
  System.JSON,
  Variants,
  Classes,
  IdCustomHTTPServer,
  IdContext,
  dfe.httpserver.base,
  dfe.lib.util,

{$IFDEF MSWINDOWS}
  Winapi.Windows,
  Winapi.Messages,
  activex,
{$ENDIF MSWINDOWS}
  IdHTTP;

type
  TNfeHttpHandler = class(THttpServerBase)
  private

    FfilterPath: string;
    procedure processrequest; override;
    procedure handlePostRequest;

  public
    function getInfo: string;
    function validar: string;
    function cancelar: string;
    function inutilizar: string;
    function imprimir: string;
    function listarNfe: string;

    constructor create; override;

  published
    property FilterPath: string read FfilterPath write FfilterPath;
  end;

implementation

uses
  nfe.controller.nfe;
{ ------------------------------------------------------------------------------ }
{ TNfeHttpHandler }

constructor TNfeHttpHandler.create;
begin
  OnProcessRequest := processrequest;
  FfilterPath := '/dfeapi/nfe/';
end;

{ ------------------------------------------------------------------------------ }
function TNfeHttpHandler.getInfo: string;
var
  controller: TNnfeController;
begin
  if assigned(ResponseInfo) then
  begin
    controller := TNnfeController.create;
    try
{$IFDEF MSWINDOWS}
      CoInitialize(nil);
{$ENDIF MSWINDOWS}
      try
         setResponse(200, 200, controller.GetInfo);

      except
        on E: Exception do
        begin
          setResponse(10, 201, E.Message);
        end;
      end;
    finally
      FreeAndNil(controller) ;
{$IFDEF MSWINDOWS}
      CoUninitialize;
{$ENDIF MSWINDOWS}
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
function TNfeHttpHandler.cancelar(): string;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
    result := controller.cancelarNfe(jValue);
  finally
    FreeAndNil(controller);
  end;
end;

{ ------------------------------------------------------------------------------ }
function TNfeHttpHandler.imprimir: string;
begin
  // todo
end;

function TNfeHttpHandler.inutilizar(): string;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
    result := controller.inutilizarNfe(jValue);
  finally
    FreeAndNil(controller);
  end;
end;

function TNfeHttpHandler.listarNfe: string;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
{$IFDEF MSWINDOWS}
    CoInitialize(nil);
{$ENDIF MSWINDOWS}
    try
      setResponse(200, 200, controller.listarNfe(jValue));
    except
      on E: Exception do
      begin
        setResponse(10, 201, E.Message);
      end;
    end;
  finally
    FreeAndNil(controller);
{$IFDEF MSWINDOWS}
    CoUninitialize;
{$ENDIF MSWINDOWS}
  end;
end;

{ ------------------------------------------------------------------------------ }
function TNfeHttpHandler.validar(): string;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
{$IFDEF MSWINDOWS}
    CoInitialize(nil);
{$ENDIF MSWINDOWS}
    try
      setResponse(200, 200, controller.validarNfe(jValue));
    except
      on E: Exception do
      begin
        setResponse(10, 201, E.Message);
      end;
    end;
  finally
    FreeAndNil(controller);
{$IFDEF MSWINDOWS}
    CoUninitialize;
{$ENDIF MSWINDOWS}
  end;
end;

{ ------------------------------------------------------------------------------ }

procedure TNfeHttpHandler.handlePostRequest;

var
  jv: TJSONValue;
begin
  try
    if (isjason) and (assigned(jValue)) and (assigned(jValue.Get('operacao')))
    then
    begin
      jv := jValue.Get('operacao').JsonValue;
      if jv.Value = 'validacao' then
        validar
      else if jv.Value = 'cancelamento' then
        cancelar
      else if jv.Value = 'imprimir' then
        imprimir
      else
        raise Exception.create('operacao desconhecida ' + jv.Value);

    end
    else
      raise Exception.create('Parametros de operação não informados');
  except
    on E: Exception do
    begin
      setResponse(10, 201, E.Message);
    end;

  end;
end;

procedure TNfeHttpHandler.processrequest;
begin
  if assigned(RequestInfo) then
  begin
    if UpperCase(RequestInfo.URI) = UpperCase(FfilterPath) then
    begin
      case Command of
        vrget:
          begin
            listarNfe();
          end;
        vrPut:
          begin
            handlePostRequest();
          end;

      end;
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
end.
