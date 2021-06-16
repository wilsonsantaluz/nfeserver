unit dfe.httphandler.nfe;

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
    procedure processRequest; override;
    procedure handlePostRequest;
  public
    procedure getInfo;
    procedure validar;
    procedure cancelar;
    procedure inutilizar;
    procedure cartaCorrecao;
    procedure imprimir;
    procedure listarNfe;
    procedure listaInutilizacoes;
    procedure listarCartaCorrecao;
    procedure listarCancelamentos;
    constructor create; override;

  published
    property FilterPath: string read FfilterPath write FfilterPath;
  end;

implementation

uses
  nfe.controller.nfe;
{ ------------------------------------------------------------------------------ }
{ TNfeHttpHandler }

procedure TNfeHttpHandler.cartaCorrecao;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
    ResponseInfo.ContentText :=controller.cartaCorrecao(jValue);
  finally
    FreeAndNil(controller);
  end;

end;

constructor TNfeHttpHandler.create;
begin
  OnProcessRequest := processrequest;
  FfilterPath := '/dfeapi/nfe';
end;

{ ------------------------------------------------------------------------------ }
procedure TNfeHttpHandler.getInfo ;
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
         ResponseInfo.ContentText :=  controller.GetInfo;
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
procedure TNfeHttpHandler.cancelar();
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
   ResponseInfo.ContentText := controller.cancelarNfe(jValue);
  finally
    FreeAndNil(controller);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TNfeHttpHandler.imprimir;
begin
  // todo
end;

procedure TNfeHttpHandler.inutilizar();
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
    ResponseInfo.ContentText :=controller.inutilizarNfe(jValue);
  finally
    FreeAndNil(controller);
  end;
end;

procedure TNfeHttpHandler.listaInutilizacoes;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
{$IFDEF MSWINDOWS}
    CoInitialize(nil);
{$ENDIF MSWINDOWS}
    try
      ResponseInfo.ContentText := controller.listarInutilizacoes(jValue);
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

procedure TNfeHttpHandler.listarCancelamentos;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
{$IFDEF MSWINDOWS}
    CoInitialize(nil);
{$ENDIF MSWINDOWS}
    try
      ResponseInfo.ContentText := controller.listarCancelamentos(jValue);
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

procedure TNfeHttpHandler.listarCartaCorrecao;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
{$IFDEF MSWINDOWS}
    CoInitialize(nil);
{$ENDIF MSWINDOWS}
    try
      ResponseInfo.ContentText := controller.listarCartaCorrecao(jValue);
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
procedure TNfeHttpHandler.listarNfe;
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
{$IFDEF MSWINDOWS}
    CoInitialize(nil);
{$ENDIF MSWINDOWS}
    try
      ResponseInfo.ContentText := controller.listarNfe(jValue);
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
procedure TNfeHttpHandler.validar();
var
  controller: TNnfeController;
begin
  controller := TNnfeController.create;
  try
{$IFDEF MSWINDOWS}
    CoInitialize(nil);
{$ENDIF MSWINDOWS}
    try
     ResponseInfo.ContentText := controller.validarNfe(jValue);
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
  s:string;
begin
  s:=jValue.ToString;
  s:='';
  try
    if (isjason) and (assigned(jValue)) and (assigned(jValue.Get('operacao')))
    then
    begin
      jv := jValue.Get('operacao').JsonValue;
      if jv.Value = 'validacao' then
        validar
      else if jv.Value = 'cancelamento' then
        cancelar
      else if jv.Value = 'inutilizacao' then
        inutilizar
       else if jv.Value = 'cartacorrecao' then
        cartaCorrecao
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
procedure TNfeHttpHandler.processRequest;
begin
  if assigned(RequestInfo) then
  begin
    if   UpperCase(FfilterPath) =  UpperCase(RequestInfo.URI) then
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
       vrPost:
          begin
            handlePostRequest();
          end;


      end;
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
end.
