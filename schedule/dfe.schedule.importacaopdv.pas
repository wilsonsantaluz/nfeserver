unit dfe.schedule.importacaopdv;

interface

uses

  System.SysUtils,
  System.Classes,
  inifiles,
  variants,
  Data.DB,
  math,
  rps.dao.core,
  Datasnap.DBClient,
  Datasnap.Provider,
  SyncObjs,
  rps.lib.util;

type

  TGeracaoRps = Class(TThread)
  private
    Ftimework: Integer;
    Fetapa: Integer;
    procedure LoadParameter;
    Procedure Executar;
    procedure Execute; override;

  public
    Terminar: Boolean;

  published
  end;

var
  CountExecs: Integer;
  ccCritical: TCriticalSection;

implementation

{ TGeracaoRps }

procedure TGeracaoRps.Execute;
begin
  inherited;
  Executar();
end;

{ ------------------------------------------------------------------------------ }
procedure TGeracaoRps.LoadParameter;
begin
end;

{ ------------------------------------------------------------------------------ }
procedure TGeracaoRps.Executar;
begin
  try
    Ftimework := 0;
    LoadParameter;
    while not Terminar do
    begin
      Fetapa := 0;
      sleep(10);
      if Ftimework <= 0 then
      begin
        Try
          TRpsDaoCore.insertRpsPendentes();
        except
          on E: Exception do
            gravalog('ERRO AO CRIAR LEITURA RPS' + E.Message);
        end;
        Ftimework := (30);
      end; // END WORK
      sleep(1000);
      dec(Ftimework);
    end;

  finally

  end;
end;
{ ------------------------------------------------------------------------------ }

initialization

ccCritical := TCriticalSection.create;

finalization

FreeAndNil(ccCritical);

end.
