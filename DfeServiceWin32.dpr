program DfeServiceWin32;

uses
  Vcl.SvcMgr,
  {$IFDEF MSWINDOWS}
  MidasLib,
  {$ENDIF MSWINDOWS}
  windows,
  System.SysUtils,
  classes,
  dfe.servicewin32.srv in 'win32service\dfe.servicewin32.srv.pas' {SrvRpswin32: TService},
  dfe.httphandler.dashboard in 'httphandlers\dfe.httphandler.dashboard.pas',
  dfe.httpserver.base in 'httpserver\dfe.httpserver.base.pas',
  dfe.httpserver in 'httpserver\dfe.httpserver.pas',
  dfe.lib.util in 'lib\dfe.lib.util.pas',
  dfe.dao.nfe in 'dao\dfe.dao.nfe.pas',
  dfe.model.nfe in 'model\dfe.model.nfe.pas',
  dfe.dao.base in 'dao\dfe.dao.base.pas',
  dfe.httphandlers.nfe in 'httphandlers\dfe.httphandlers.nfe.pas',
  dfe.services.validar in 'services\dfe.services.validar.pas',
  dfe.services.cancelar in 'services\dfe.services.cancelar.pas',
  dfe.services.inutilizar in 'services\dfe.services.inutilizar.pas',
  dfe.model.config in 'model\dfe.model.config.pas',
  dfe.model.empresa in 'model\dfe.model.empresa.pas',
  nfe.controller.nfe in 'controller\nfe.controller.nfe.pas',
  dfe.lib.constants in 'lib\dfe.lib.constants.pas';

{$R *.RES}

begin


  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TSrvRpswin32, SrvRpswin32);
  Application.Run;

end.
