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
  dfe.httphandler.nfe in 'httphandlers\dfe.httphandler.nfe.pas',
  dfe.services.validar in 'services\dfe.services.validar.pas',
  dfe.model.config in 'model\dfe.model.config.pas',
  dfe.model.empresa in 'model\dfe.model.empresa.pas',
  nfe.controller.nfe in 'controller\nfe.controller.nfe.pas',
  dfe.lib.constants in 'lib\dfe.lib.constants.pas',
  dfe.model.cancelamento in 'model\dfe.model.cancelamento.pas',
  dfe.model.cancelamentoResponse in 'model\dfe.model.cancelamentoResponse.pas',
  dfe.model.cartaCorrecao in 'model\dfe.model.cartaCorrecao.pas',
  dfe.model.infonfe in 'model\dfe.model.infonfe.pas',
  dfe.model.inutilizacao in 'model\dfe.model.inutilizacao.pas',
  dfe.model.log in 'model\dfe.model.log.pas',
  dfe.model.validacaoResponse in 'model\dfe.model.validacaoResponse.pas',
  dfe.dao.cancelamento in 'dao\dfe.dao.cancelamento.pas',
  dfe.dao.cartaCorrecao in 'dao\dfe.dao.cartaCorrecao.pas',
  dfe.dao.infoNfe in 'dao\dfe.dao.infoNfe.pas',
  dfe.dao.inutilizacao in 'dao\dfe.dao.inutilizacao.pas',
  dfe.dao.log in 'dao\dfe.dao.log.pas',
  dfe.model.cancelamentoRequest in 'model\request\dfe.model.cancelamentoRequest.pas',
  dfe.model.cartaCorrecaoRequest in 'model\request\dfe.model.cartaCorrecaoRequest.pas',
  dfe.model.inutilizacaoRequest in 'model\request\dfe.model.inutilizacaoRequest.pas',
  dfe.model.validacaoRequest in 'model\request\dfe.model.validacaoRequest.pas',
  dfe.services.cancelar in 'services\dfe.services.cancelar.pas',
  dfe.services.cartaCorrecao in 'services\dfe.services.cartaCorrecao.pas',
  dfe.services.inutilizar in 'services\dfe.services.inutilizar.pas',
  dfe.lib.jsontoXml in 'lib\dfe.lib.jsontoXml.pas',
  dfe.lib.xmltoJson in 'lib\dfe.lib.xmltoJson.pas',
  dfe.lib.origin.return in 'lib\dfe.lib.origin.return.pas',
  dfe.lib.normalize in 'lib\dfe.lib.normalize.pas',
  dfe.dao.empresa in 'dao\dfe.dao.empresa.pas',
  dfe.lib.acbr.config in 'lib\dfe.lib.acbr.config.pas',
  dfe.httphandler.empresa in 'httphandlers\dfe.httphandler.empresa.pas',
  nfe.controller.empresa in 'controller\nfe.controller.empresa.pas';

{$R *.RES}

begin


  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(Tnfeserver, nfeserver);
  Application.Run;

end.
