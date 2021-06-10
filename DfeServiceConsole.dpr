program DfeServiceConsole;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  {$IFDEF MSWINDOWS}
  MidasLib,
  {$ENDIF MSWINDOWS}
  windows,
  System.SysUtils,
  classes,
  dfe.servicewin32.srv in 'win32service\dfe.servicewin32.srv.pas' {nfeserver: TService},
  dfe.httphandler.dashboard in 'httphandlers\dfe.httphandler.dashboard.pas',
  dfe.httpserver.base in 'httpserver\dfe.httpserver.base.pas',
  dfe.httpserver in 'httpserver\dfe.httpserver.pas',
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
  dfe.model.infonfe in 'model\dfe.model.infonfe.pas',
  dfe.dao.infoNfe in 'dao\dfe.dao.infoNfe.pas',
  dfe.dao.empresa in 'dao\dfe.dao.empresa.pas',
  nfe.controller.empresa in 'controller\nfe.controller.empresa.pas',
  XSuperJSON in 'components\superobject\XSuperJSON.pas',
  XSuperObject in 'components\superobject\XSuperObject.pas',
  dfe.httphandlers.empresa in 'httphandlers\dfe.httphandlers.empresa.pas',
  dfe.lib.constants in 'lib\dfe.lib.constants.pas',
  dfe.lib.jsontoXml in 'lib\dfe.lib.jsontoXml.pas',
  dfe.lib.normalize in 'lib\dfe.lib.normalize.pas',
  dfe.lib.origin.return in 'lib\dfe.lib.origin.return.pas',
  dfe.lib.util in 'lib\dfe.lib.util.pas',
  dfe.lib.xmltoJson in 'lib\dfe.lib.xmltoJson.pas',
  dfe.origin.return in 'lib\dfe.origin.return.pas',
  dfe.dao.log in 'dao\dfe.dao.log.pas',
  dfe.model.log in 'model\dfe.model.log.pas',
  dfe.lib.acbr.config in 'lib\dfe.lib.acbr.config.pas',
  dfe.model.validacaoResponse in 'model\dfe.model.validacaoResponse.pas',
  dfe.model.cancelamento in 'model\dfe.model.cancelamento.pas',
  dfe.dao.cancelamento in 'dao\dfe.dao.cancelamento.pas',
  dfe.model.cartaCorrecao in 'model\dfe.model.cartaCorrecao.pas',
  dfe.model.inutilizacao in 'model\dfe.model.inutilizacao.pas',
  dfe.model.cancelamentoRequest in 'model\request\dfe.model.cancelamentoRequest.pas',
  dfe.model.validacaoRequest in 'model\request\dfe.model.validacaoRequest.pas',
  dfe.model.cartaCorrecaoRequest in 'model\request\dfe.model.cartaCorrecaoRequest.pas',
  dfe.model.inutilizacaoRequest in 'model\request\dfe.model.inutilizacaoRequest.pas',
  dfe.dao.inutilizacao in 'dao\dfe.dao.inutilizacao.pas',
  dfe.dao.cartaCorrecao in 'dao\dfe.dao.cartaCorrecao.pas',
  dfe.services.cartaCorrecao in 'services\dfe.services.cartaCorrecao.pas';

var
  terminate: Boolean;



begin
  try
    terminate:=false;
    Writeln('---------------------------------------------------------------');
    Writeln(' /  \    /  \__|  |   __________   ____   |  |  __ __________  ');
    Writeln(' \   \/\/   /  |  |  /  ___/  _ \ /    \  |  | |  |  \___   /  ');
    Writeln('  \        /|  |  |__\___ (  <_> )   |  \ |  |_|  |  //    /   ');
    Writeln('   \__/\  / |__|____/____  >____/|___|  / |____/____//_____ \  ');
    Writeln('        \/               \/           \/                   \/  ');
    Writeln(' NFE CONSOLE SERVICE 2021                                      ');
    Writeln(' Runing on port:  ' + inttostr(_HTTP_PORT));
    Writeln('---------------------------------------------------------------');
    THttpHandlerBase.Create;
    while not terminate do
    begin
      sleep(1);
    end;
  except
    on e: exception do
    begin
      gravalog('ERRO AO INICAR SERVIÇO NFE ' + e.Message);
      Writeln(e.ClassName, ': ', e.Message);
    end;

  end;

end.
