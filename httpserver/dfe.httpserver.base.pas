unit dfe.httpserver.base;

interface

uses
  math,
  System.SysUtils,
  IdCoder3to4,
  System.JSON,
  Variants,
  Classes,
  dfe.lib.util,
  System.ZLib,

  IdContext,
  IdCustomHTTPServer,
  IdBaseComponent,
  IdComponent,
  IdCustomTCPServer,
  IdHTTPServer,
  REST.Client,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  IdTCPConnection,
  IdTCPClient,
  dfe.lib.constants,
  IdHTTP

    ;

type
  httpVerbs = (vrGet, vrPost, vrDelete, vrPut, vrOptions, vrHead);

type

  TOnProcessRequest = procedure() of object;

  THttpServerBase = class
  private
    FOnProcessRequest: TOnProcessRequest;
    os: string;
    oc: string;
    ot: string;
    isfileRequest: Boolean;
    Fisjason: Boolean;
    Fcommand: httpVerbs;
    Fserver: TIdHTTPServer;
    FContext: TIdContext;
    FRequestInfo: TIdHTTPRequestInfo;
    FResponseInfo: TIdHTTPResponseInfo;
    FjValue: TJSONObject;
    procedure FserverCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FserverCommandOther(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

    procedure processcommand(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

    procedure pipelog(value: string);
    function getComandVerb(value: string): httpVerbs;

  public

    // deve ser implementado nas implementações
    procedure processrequest(); virtual;
    procedure setResponse(coderetorno, respno: integer; msg: string);
  published
    property Context: TIdContext read FContext write FContext;
    property RequestInfo: TIdHTTPRequestInfo read FRequestInfo
      write FRequestInfo;
    property ResponseInfo: TIdHTTPResponseInfo read FResponseInfo
      write FResponseInfo;
    property jValue: TJSONObject read FjValue write FjValue;
    property isjason: Boolean read Fisjason write Fisjason;
    property Command: httpVerbs read Fcommand write Fcommand;
    property OnProcessRequest: TOnProcessRequest read FOnProcessRequest
      write FOnProcessRequest;
    constructor create; virtual;

  end;

implementation

{ TItecNfseApi }
{ ------------------------------------------------------------------------------ }
constructor THttpServerBase.create;
begin
  Fserver := TIdHTTPServer.create(Nil);
  Fserver.DefaultPort := _HTTP_PORT;
  Fserver.OnCommandOther := FserverCommandOther;
  Fserver.OnCommandGet := FserverCommandGet;
  Fserver.Active := true;
end;

{ ------------------------------------------------------------------------------ }
function THttpServerBase.getComandVerb(value: string): httpVerbs;
begin
  if SameText(value, 'GET') then
    result := vrGet
  else if SameText(value, 'POST') then
    result := vrPost
  else if SameText(value, 'DELETE') then
    result := vrDelete
  else if SameText(value, 'PUT') then
    result := vrPut
  else if SameText(value, 'OPTIONS') then
    result := vrOptions
  else if SameText(value, 'HEAD') then
    result := vrHead;
end;

{ ------------------------------------------------------------------------------ }
procedure THttpServerBase.processcommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  aFilename: string;
  aRequestStream: TStringStream;

  aRequestContent, aResponseContent: string;
  i: integer;
  outstrem: TFileStream;
  os: string;
  srcbuf, destbuf: TBytes;
  str: string;
  s: string;
begin
  FjValue := nil;
  FContext := nil;
  FRequestInfo := nil;
  FResponseInfo := nil;
  try
    FContext := AContext;
    FRequestInfo := ARequestInfo;
    FResponseInfo := AResponseInfo;

    FResponseInfo.ResponseNo := 200;
    FResponseInfo.ContentText := '';
    AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Methods',
      'POST, GET, OPTIONS, PUT, DELETE, HEAD');
    os := ARequestInfo.RawHeaders.Values['Origin'];
    oc := ARequestInfo.RawHeaders.Values['Access-Control-Request-Headers'];
    ot := ARequestInfo.RawHeaders.Values['Accept'];
    AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin', os);
    AResponseInfo.CustomHeaders.AddValue('Content-Type', oc);
    AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Headers', oc);
    AResponseInfo.CustomHeaders.AddValue('Accept', ot);
    Fisjason := false;

    os := ARequestInfo.Host;

    Fcommand := getComandVerb(ARequestInfo.Command);
    os := ARequestInfo.RemoteIP;
    i := ARequestInfo.Cookies.Count;
    if i > 0 then
      os := ARequestInfo.Cookies[0].value;
    os := '';

    if Assigned(ARequestInfo.PostStream) then
    begin
      aRequestStream := TStringStream.create;
      try
        aRequestStream.LoadFromStream(ARequestInfo.PostStream);
        aRequestStream.Position := 0;
        if (pos('{', aRequestStream.DataString) > 0) and
          (ARequestInfo.ContentType = 'application/json') then
        begin

          FjValue := TJSONObject.ParseJSONValue(aRequestStream.DataString)
            as TJSONObject;
          Fisjason := true;

        end
        else
        Begin

          aRequestContent := aRequestStream.DataString;
        End;
      finally
        aRequestStream.Free;
      end;
    end
    else
    begin
      if (pos('{', ARequestInfo.Params.Text) > 0) and
        (ARequestInfo.ContentType = 'application/json') then
      begin

        FjValue := TJSONObject.ParseJSONValue(ARequestInfo.Params.Text)
          as TJSONObject;
        if not Assigned(FjValue) then
          raise Exception.create('Conteudo json invalido : ' +
            ARequestInfo.Params.Text);

        Fisjason := true;

      end
    end;

    isfileRequest := false;
    aFilename := '';
    aFilename := ExtractFileExt(StringReplace(ARequestInfo.URI, '/', '\',
      [rfReplaceAll]));
    if (pos('.', aFilename) > 0) or (FRequestInfo.URI = '/') then
    begin
      isfileRequest := true;
      AResponseInfo.Connection := 'keep-alive';

      if (UpperCase(aFilename) = '.CSS') or (UpperCase(aFilename) = '.JS') or

        (UpperCase(aFilename) = '.HTML') Then
      begin
        AResponseInfo.Date := now;
        AResponseInfo.LastModified := now;
        AResponseInfo.CacheControl := 'private';
        AResponseInfo.Expires := Date + 10;
      end;
      if UpperCase(aFilename) = '.CSS' then
        AResponseInfo.ContentType := 'text/css';

      if UpperCase(aFilename) = '.PDF' then
        AResponseInfo.ContentType := 'application/pdf';

      if FRequestInfo.URI = '/' then
        aFilename := ExtractFilePath(GetModuleName(HInstance)) + _SERVERROOT +
          '\index.html'
      else
        aFilename := ExtractFilePath(GetModuleName(HInstance)) + _SERVERROOT +
          StringReplace(ARequestInfo.URI, '/', '\', [rfReplaceAll]);
      if FileExists(aFilename) then
      begin

        outstrem := TFileStream.create(aFilename, fmOpenRead);
        Try
          AResponseInfo.ContentStream := outstrem;
          AResponseInfo.ResponseNo := 200;
          exit;
        Finally
        End;
      end
      else
      begin
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ContentText :=
          '<html><head><title>Arquivo não encontrado</title></head><body><h1>' +
          'O arquivo : ' + ExtractFileName(aFilename) +
          '\nao foi localizado no servidor  </h1></body></html>';
        exit;
      end;
    end;

    AContext := FContext;
    ARequestInfo := FRequestInfo;
    AResponseInfo := FResponseInfo;
    if not isfileRequest then
      processrequest();
    if Length(AResponseInfo.ContentText) > 1000 then
    begin

      str := AResponseInfo.ContentText;
      srcbuf := BytesOf(str);
      ZCompress(srcbuf, destbuf, zcMax);
      AResponseInfo.ContentText := '';
      AResponseInfo.ContentStream := TMemoryStream.create;
      AResponseInfo.ContentEncoding := 'deflate';

      AResponseInfo.ContentStream.WriteData(@(destbuf[0]), Length(destbuf));
      AResponseInfo.ContentLength := (Length(destbuf));
      AResponseInfo.ContentStream.Position := 0;

    end;
  finally
    FjValue := nil;
  end;

end;
{ ------------------------------------------------------------------------------ }

procedure THttpServerBase.FserverCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  processcommand(AContext, ARequestInfo, AResponseInfo);
end;

{ ------------------------------------------------------------------------------ }
procedure THttpServerBase.FserverCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

begin
  Fcommand := getComandVerb(ARequestInfo.Command);
  if Fcommand = vrOptions then
  begin
    AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Methods',
      'POST, GET, OPTIONS, PUT, DELETE, HEAD');
    os := ARequestInfo.RawHeaders.Values['Origin'];
    oc := ARequestInfo.RawHeaders.Values['Access-Control-Request-Headers'];
    ot := ARequestInfo.RawHeaders.Values['Accept'];
    AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin', os);
    AResponseInfo.CustomHeaders.AddValue('Content-Type', oc);
    AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Headers', oc);
    AResponseInfo.CustomHeaders.AddValue('Accept', ot);
    AResponseInfo.ResponseNo := 200
  end
  else
  begin
    processcommand(AContext, ARequestInfo, AResponseInfo);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure THttpServerBase.pipelog(value: string);
begin
  gravalog(value);
end;

{ ------------------------------------------------------------------------------ }
procedure THttpServerBase.processrequest();
begin

end;

procedure THttpServerBase.setResponse(coderetorno, respno: integer;
  msg: string);
begin
  ResponseInfo.ContentType := 'application/json; charset=iso-8859-1';
  ResponseInfo.ResponseNo := respno;
  if (coderetorno = 10) or (coderetorno = 1) then

    ResponseInfo.ContentText := '{"codretorno":' + IntToStr(coderetorno) +
      ' ,"msg":"' + msg + '"}'
  else
    ResponseInfo.ContentText := msg;
end;

{ ------------------------------------------------------------------------------ }
end.
