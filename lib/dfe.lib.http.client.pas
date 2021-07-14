unit dfe.lib.http.client;

interface

uses
  IdComponent,
  System.SysUtils,
  System.Variants,
  System.Classes,
  IdHTTP,
  System.ZLib,
  System.JSON,
  idCookieManager,
  IdHashMessageDigest

    ;

type
  TbeforeExecute = TNotifyEvent;

type
  TipoRequest = (vpost, vget, vput, vdelete);

type
  ThttpClient = class(Tthread)
  private
    Fhost: string;
    Fuser: string;
    Fpass: String;
    FPath: string;

    Fresponse: string;
    myHttpCom: TIdHTTP;
    FbeforeExecute: TbeforeExecute;
    FMensageReturneD: string;
    Flogedin: Boolean;
    FFinalized: Boolean;
    Fparam: String;
    Ftiporequest: TipoRequest;
    function decompress(value: TStream): TStream;
    procedure setupIndy();
  public
    procedure execute; override;
    property OnBeforeExecute: TbeforeExecute Read FbeforeExecute
      write FbeforeExecute;
    property response: string Read Fresponse write Fresponse;
    property Host: string read Fhost write Fhost;
    property User: string read Fuser write Fuser;
    property Paht: string read FPath write FPath;
    property Param: string read Fparam write Fparam;
    property TipoRequest: TipoRequest read Ftiporequest write Ftiporequest;
  end;

implementation

{ ThttpClient }
procedure ThttpClient.setupIndy();
begin

  with myHttpCom do
  begin
    AllowCookies := true;
    ProxyParams.BasicAuthentication := false;
    ProxyParams.ProxyPort := 0;
    Request.ContentLength := -1;
    Request.ContentRangeEnd := 0;
    Request.ContentRangeStart := 0;
    ProtocolVersion := pv1_1;

    Request.BasicAuthentication := true;

    HandleRedirects := true;
    Request.Referer := Fhost + FPath;
    Request.Host := Fhost;
    Request.ContentEncoding := 'UTF-8'; // in test
    Request.CharSet := 'UTF-8'; // //in test
    Request.AcceptCharSet := 'UTF-8';
    /// /in test
    response.CharSet := 'UTF-8'; // in test
    response.ContentEncoding := 'UTF-8'; // in test

    Request.AcceptEncoding := 'gzip, deflate';
    myHttpCom.Request.Accept :=
      'application/json, text/javascript, */*; q=0.01';
    myHttpCom.Request.ContentType := 'application/json';

    myHttpCom.Request.CharSet := 'utf-8';

  end;
end;

function ThttpClient.decompress(value: TStream): TStream;
begin
  // compress to buff (System.ZLib)
  value.Position := 0;
  result := TstringStream.Create;
  ZDecompressStream(value, result);

end;

{ ------------------------------------------------------------------------------ }
procedure ThttpClient.execute;
var
  srespose: string;

  idmd5: TIdHashMessageDigest5;
  Req_Json: TStream;
  aurl: string;
  decoded: string;
  aresponse: TStream;
  procedure setresponse;
  begin
    if TstringStream(aresponse).DataString <> '' then
    begin
      try
        if Length( TstringStream(aresponse).DataString) > 1000 then
          aresponse := decompress(aresponse)
      except
      end;
      Fresponse := TstringStream(aresponse).DataString;
    end;
  end;

begin
  // inherited;
  idmd5 := TIdHashMessageDigest5.Create;
  myHttpCom := TIdHTTP.Create(nil);
  try
    FFinalized := false;

    setupIndy();
    Req_Json := TstringStream.Create(Fparam);
    Req_Json.Position := 0;
    try

      aresponse := TstringStream.Create('');
      case Ftiporequest of
        vget:
          begin

            myHttpCom.Get(Fhost + FPath + '?' + Fparam, aresponse);
            setresponse();

          end;
        vpost:
          begin
            myHttpCom.post(Fhost + FPath, Req_Json, aresponse);
            setresponse();

          end;
        vput:
          begin
            myHttpCom.Put(Fhost + FPath, Req_Json, aresponse);
            setresponse();

          end;
        vdelete:
          begin
            aurl := Fhost + FPath + Fparam;
            myHttpCom.Delete(aurl, aresponse);
            setresponse();
          end;
      end;

    except
      on E: Exception do
      begin

        if pos('forbidden', AnsiLowerCase(E.Message)) > 0 then
        begin
          FMensageReturneD := 'Servidor recusou a conexão,Atualize a versão';
        end
        else
        begin
          FMensageReturneD := 'Erro ao acessar servidor : ' + E.Message;
        end;
        Fresponse := FMensageReturneD;
      end;
    end;
  finally
    try
      FreeAndNil(myHttpCom);
      try
        if Assigned(FbeforeExecute) then
          FbeforeExecute(Nil);
      except
      end;
      FreeAndNil(idmd5);
    except
    end;

  end;
end;

end.
