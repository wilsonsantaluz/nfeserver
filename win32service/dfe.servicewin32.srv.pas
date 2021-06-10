unit dfe.servicewin32.srv;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  dfe.httpserver.base,
  dfe.httpserver,
  Vcl.SvcMgr,
  dfe.dao.base,
  Vcl.ExtCtrls

    ;

type
  Tnfeserver = class(TService)
    tmstart: TTimer;
    procedure tmstartTimer(Sender: TObject);
    procedure ServiceCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  FidlistenNfe: cardinal;
  nfeserver: Tnfeserver;

implementation

{$R *.dfm}

procedure GlobalLog(Msg: string; akind: Integer = 1);

var
  strSaida: string;

  procedure registrarLogEmArquivo;
  var
    p: string;
    f: TextFile;
  begin
    p := ExtractFilePath(ParamStr(0)) + 'log\';
    ForceDirectories(p);
    p := p + FormatDateTime('yyyymmdd', now) + '_' +
      ChangeFileExt(ExtractFileName(ParamStr(0)), '') + '.log';
    AssignFile(f, p);
    if not FileExists(p) then
      Rewrite(f)
    else
      Append(f);
    Writeln(f, strSaida);
    Closefile(f);
  end;

begin
  try
    strSaida := FormatDateTime('hh:nn:ss.zzz', now) + '[NFSE] - ' + Msg;
    OutputDebugString(pchar(datetimetostr(now) + ' - ' + Msg));

  except
  end;
  try
    registrarLogEmArquivo;
  except
  end;
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  nfeserver.Controller(CtrlCode);
end;

function Tnfeserver.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure Tnfeserver.ServiceCreate(Sender: TObject);
begin
  tmstart.Enabled := true;
end;

procedure listenNfe();
begin
  try

    TdfeDaoBase.SetPoolDb();
    THttpHandlerBase.create;

  except
    on E: Exception do
      GlobalLog('ERRO AO INICIAR LINSTEN NFE SERVICE' + E.Message);
  end;
end;

procedure Tnfeserver.tmstartTimer(Sender: TObject);
begin
  tmstart.Enabled := false;
  Try
    BeginThread(Nil, 0, @listenNfe, nil, 0, FidlistenNfe);
  except
    on E: Exception do
      GlobalLog('ERRO AO CRIAR LEITURA NFE' + E.Message);
  end;
end;

end.
