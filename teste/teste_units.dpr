program teste_units;

uses
  Vcl.Forms,
  utester in 'utester.pas' {fteste},
  dfe.lib.origin.return in '..\lib\dfe.lib.origin.return.pas',
  dfe.lib.jsontoXml in '..\lib\dfe.lib.jsontoXml.pas',
  dfe.lib.normalize in '..\lib\dfe.lib.normalize.pas',
  dfe.lib.xmltoJson in '..\lib\dfe.lib.xmltoJson.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfteste, fteste);
  Application.Run;
end.
