unit dfe.httphandler.dashboard;

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

  nfe.controller.nfe,

{$IFDEF MSWINDOWS}
  Winapi.Windows,
  Winapi.Messages,
  activex,
{$ENDIF MSWINDOWS}
  IdHTTP;

type
  TDashBoadHttpHandler = class(THttpServerBase)
  private

    FfilterPath: string;
    procedure processrequest; override;

  public
    function getInfo: string;

    constructor create; override;

  published
    property FilterPath: string read FfilterPath write FfilterPath;
  end;

implementation

{ ------------------------------------------------------------------------------ }
{ TDashBoadHttpHandler }
constructor TDashBoadHttpHandler.create;
begin
  OnProcessRequest := processrequest;
  FfilterPath := '/dfeapi/nfe/info';
end;

{ ------------------------------------------------------------------------------ }
function TDashBoadHttpHandler.getInfo: string;
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
        setResponse(200, 200, controller.getInfo);
      except
        on E: Exception do
        begin
          setResponse(10, 201, E.Message);
        end;
      end;
    finally
{$IFDEF MSWINDOWS}
      CoUninitialize;
{$ENDIF MSWINDOWS}
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }

procedure TDashBoadHttpHandler.processrequest;
begin
  if assigned(RequestInfo) then
  begin
    if UpperCase(RequestInfo.URI) = UpperCase(FfilterPath) then
    begin
      case Command of
        vrget:
          begin
            getInfo;
          end;
      end;
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
end.
