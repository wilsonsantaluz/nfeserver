unit dfe.httpserver;

interface

uses
  math,
  System.SysUtils,
  IdCoder3to4,
  System.JSON,
  Variants,
  Classes,
  dfe.httphandler.dashboard,
  dfe.httphandler.empresa,
  dfe.httphandler.cancelamentos,
  dfe.httphandler.inutilizacoes,
  dfe.httphandler.cartaCorrecao,
  dfe.httphandler.nfe,
  dfe.httpserver.base,

{$IFDEF MSWINDOWS}
  Winapi.Windows,
  Winapi.Messages,
  activex,
{$ENDIF MSWINDOWS}
  dfe.lib.util;

type
  THttpHandlerBase = class(THttpServerBase)
  private
    FDashBoadHttpHandler: TDashBoadHttpHandler;
    FNfeHttpHandler: TNfeHttpHandler;
    FEmpresaHttpHandler: TEmpresaHttpHandler;
    FInutilizacaoHttpHandler: TInutilizacoesHttpHandler;
    FCancelamentosHttpHandler: TCancelamentosHttpHandler;
    FCartaCorrecaoHttpHandler: TCartaCorrecaoHttpHandler;
    procedure updateSubclass(oclass: THttpServerBase);
  public
    procedure processrequest; override;
    constructor create; override;
  published

  end;

implementation

{ THttpHandlerBase }
constructor THttpHandlerBase.create;
begin
  inherited;
  FDashBoadHttpHandler := TDashBoadHttpHandler.create();
  FNfeHttpHandler := TNfeHttpHandler.create();
  FEmpresaHttpHandler := TEmpresaHttpHandler.create();
  FInutilizacaoHttpHandler := TInutilizacoesHttpHandler.create;
  FCancelamentosHttpHandler := TCancelamentosHttpHandler.create;
  FCartaCorrecaoHttpHandler :=TCartaCorrecaoHttpHandler.create;
end;

{ ------------------------------------------------------------------------------ }
procedure THttpHandlerBase.processrequest;
begin
  updateSubclass(FDashBoadHttpHandler);
  updateSubclass(FNfeHttpHandler);
  updateSubclass(FEmpresaHttpHandler);
  updateSubclass(FInutilizacaoHttpHandler);
  updateSubclass(FCancelamentosHttpHandler);
  updateSubclass(FCartaCorrecaoHttpHandler);
end;

procedure THttpHandlerBase.updateSubclass(oclass: THttpServerBase);
begin
  oclass.jValue := self.jValue;
  oclass.isjason := self.isjason;
  oclass.Context := self.Context;
  oclass.Command := self.Command;
  oclass.RequestInfo := self.RequestInfo;
  oclass.ResponseInfo := self.ResponseInfo;
  oclass.processrequest();
end;

{ ------------------------------------------------------------------------------ }
end.
