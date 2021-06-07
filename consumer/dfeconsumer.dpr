program dfeconsumer;

uses
  Vcl.Forms,
  dfe.consumer.tester in 'dfe.consumer.tester.pas' {fconsumer},
  dfe.lib.origin.return in '..\lib\dfe.lib.origin.return.pas',
  dfe.lib.jsontoXml in '..\lib\dfe.lib.jsontoXml.pas',
  dfe.lib.normalize in '..\lib\dfe.lib.normalize.pas',
  dfe.lib.xmltoJson in '..\lib\dfe.lib.xmltoJson.pas',
  dfe.lib.http.client in '..\lib\dfe.lib.http.client.pas',
  dfe.model.validacaoRequest in '..\model\dfe.model.validacaoRequest.pas',
  dfe.model.validacaoResponse in '..\model\dfe.model.validacaoResponse.pas',
  Vcl.Themes,
  Vcl.Styles,
  dfe.model.cancelamentoRequest in '..\model\dfe.model.cancelamentoRequest.pas',
  dfe.model.cancelamento in '..\model\dfe.model.cancelamento.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(Tfconsumer, fconsumer);
  Application.Run;
end.
