unit dfe.httphandler.inutilizacoes;

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
  TInutilizacoesHttpHandler = class(THttpServerBase)
  private

    FfilterPath: string;
    procedure processRequest; override;

  public

    procedure listaInutilizacoes;

    constructor create; override;

  published
    property FilterPath: string read FfilterPath write FfilterPath;
  end;

implementation

uses
  nfe.controller.nfe;
{ ------------------------------------------------------------------------------ }
{ TInutilizacoesHttpHandler}



constructor  TInutilizacoesHttpHandler.create;
begin
  OnProcessRequest := processrequest;
  FfilterPath := '/dfeapi/inutilizacoes';
end;
{ ------------------------------------------------------------------------------ }


procedure  TInutilizacoesHttpHandler.listaInutilizacoes;
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

{ ------------------------------------------------------------------------------ }

procedure  TInutilizacoesHttpHandler.processRequest;
begin
  if assigned(RequestInfo) then
  begin
    if   UpperCase(FfilterPath) =  UpperCase(RequestInfo.URI) then
    begin
      case Command of
        vrget:
          begin
            listaInutilizacoes();
          end;
        vrPut:
          begin
           {TODO}
          end;
       vrPost:
          begin
             {TODO}
          end;


      end;
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
end.
