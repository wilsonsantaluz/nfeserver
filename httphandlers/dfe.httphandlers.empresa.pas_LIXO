unit dfe.httphandlers.empresa;

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
  TEmpresaHttpHandler = class(THttpServerBase)
  private

    FfilterPath: string;
    procedure processrequest; override;
    procedure handlePostRequest;

  public
    procedure getEmpresa;
    procedure gravar;
    procedure excluir;

    constructor create; override;

  published
    property FilterPath: string read FfilterPath write FfilterPath;
  end;

implementation

uses
  nfe.controller.empresa;
{ ------------------------------------------------------------------------------ }
{ TEmpresaHttpHandler }

constructor TEmpresaHttpHandler.create;
begin
  OnProcessRequest := processrequest;
  FfilterPath := '/dfeapi/nfe/empresa';
end;

{ ------------------------------------------------------------------------------ }
procedure TEmpresaHttpHandler.getEmpresa ;
var
  controller: TEmpresaController;
begin
  if assigned(ResponseInfo) then
  begin
    controller := TEmpresaController.create;
    try
{$IFDEF MSWINDOWS}
      CoInitialize(nil);
{$ENDIF MSWINDOWS}
      try
         ResponseInfo.ContentText := controller.getEmpresa(jValue);

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
procedure TEmpresaHttpHandler.excluir;
var
  controller: TEmpresaController;
begin
  if assigned(ResponseInfo) then
  begin
    controller := TEmpresaController.create;
    try
{$IFDEF MSWINDOWS}
      CoInitialize(nil);
{$ENDIF MSWINDOWS}
      try
         setResponse(200, 200, controller.apagarEmpresa(jValue));

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
procedure TEmpresaHttpHandler.gravar;
var
  controller: TEmpresaController;
begin
  if assigned(ResponseInfo) then
  begin
    controller := TEmpresaController.create;
    try
{$IFDEF MSWINDOWS}
      CoInitialize(nil);
{$ENDIF MSWINDOWS}
      try
         setResponse(200, 200, controller.gravarEmpresa(jValue));

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
{ -------------------------------------------------------------------------- }

procedure TEmpresaHttpHandler.handlePostRequest;

begin
//todo
end;

procedure TEmpresaHttpHandler.processrequest;
begin
  if assigned(RequestInfo) then
  begin
    if UpperCase(RequestInfo.URI) = UpperCase(FfilterPath) then
    begin
      case Command of
        vrget:
          begin
            getEmpresa();
          end;
        vrPut:
          begin
            gravar();
          end;

         vrPost:
          begin
            gravar();
          end;


           vrDelete:
          begin
            excluir();
          end;

      end;
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
end.
