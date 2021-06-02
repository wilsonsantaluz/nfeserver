unit dfe.lib.util;

interface

uses
{$IFDEF MSWINDOWS}
  windows,
{$ENDIF MSWINDOWS}
  System.sysutils,
  Math,
  Rtti,
  XSBuiltIns,
  Data.DB,
  Datasnap.DBClient,
  classes;

type
  TpsProvedor = (Elotech, Rio, Goiania, acbr);
  TpsTipo = (temissao, tcancelamento);

  TdadosRequerente = record
    filial: integer;
    cnpj: string;
    inscricao: string;
    fraseSecreta: string;
    usuarioPrefeitura: string;
    nomecidade: string;
    senhaCertificado: string;
    senha: string;

  end;

function soNumeros(const Value: string): string;
function formatvalue(Value: double): string;
function vLrXmltoFloat(Value: string): double;

function pegarSaidaDOS(Comando, DiretorioTrabalho: string): string;
function RoundABNT(const AValue: double; const Digits: TRoundToRange;
  const Delta: double = 0.00001): double;

function makeJason(cds: TclienTdataset; aliasdata: string = ''): string;
procedure gravalog(mensagem: string);

function Valfloat(Value: string): double;
function GetTagByName(Value, xml: string): string;
function FormatDate(Value: string): TDateTime;
function formatMsg(Value: string): string;
function valInt(Value: string): integer;
Function Valdate(Value: string): TDateTime;

implementation

Function Valdate(Value: string): TDateTime;
var
  idate: TDateTime;
  lst: TStringList;
  day: word;
  year: word;
  month: word;
  minut: word;
  second: word;
  hour: word;
  stime: string;
begin
  day := 0;
  year := 0;
  month := 0;
  minut := 0;
  second := 0;
  hour := 0;
  Result := 0;
  lst := TStringList.Create;
  try
    if TryStrToDateTime(Value, idate) then
      Result := idate
    else
    begin
      if pos('-', Value) > 0 then
      begin
        lst.StrictDelimiter := true;
        lst.Delimiter := '-';
        lst.DelimitedText := Value;
        year := StrToInt(lst[0]);
        month := StrToInt(copy(lst[1], 0, 2));
        day := StrToInt(copy(lst[2], 0, 2));
        Result := EncodeDate(year, month, day)
      end;

      if pos(':', Value) > 0 then
      begin

        lst.StrictDelimiter := true;
        lst.Delimiter := ' ';
        lst.DelimitedText := Value;
        stime := lst[1];
        if stime <> '' then
        begin
          lst.StrictDelimiter := true;
          lst.Delimiter := ':';
          lst.DelimitedText := stime;
          if lst.Count > 1 then

            hour := StrToInt(lst[0]);
          if lst.Count > 2 then
            minut := StrToInt(lst[1]);
          if lst.Count > 3 then
            second := StrToInt(copy(lst[2], 0, 2));
          Result := Result + EncodeTime(hour, minut, second, 0);
        end;
      end;

    end;
  finally
    FreeAndNil(lst);
  end;
end;

function valInt(Value: string): integer;
var
  i: integer;
begin
  Result := 0;
  if soNumeros(Value) <> '' then
  begin
    if TryStrToInt(Value, i) then
      Result := i;
  end;

end;

{ ------------------------------------------------------------------------------- }
function GetTagByName(Value, xml: string): string;
var
  i, j: integer;
begin
  Result := '';
  i := pos('<' + uppercase(Value) + '>', uppercase(xml));
  if i > 0 then
  begin
    Result := copy(xml, i + length(Value) + 2, length(xml));
    j := pos('</' + uppercase(Value) + '>', uppercase(Result));
    Result := copy(Result, 0, j - 1);
  end;
end;

{ ------------------------------------------------------------------------------- }
function soNumeros(const Value: string): string;
var
  i: integer;
begin
  Result := '';

  if Value = '' then
    exit;

  for i := 0 to length(Value) do
    if Value[i] in ['0' .. '9'] then
      Result := Result + Value[i];
end;

function FormatDate(Value: string): TDateTime;
var
  idate: TDateTime;
  lst: TStringList;
  day: word;
  year: word;
  month: word;
  minut: word;
  second: word;
  hour: word;
  stime: string;
begin
  day := 0;
  year := 0;
  month := 0;
  minut := 0;
  second := 0;
  hour := 0;
  Result := 0;
  lst := TStringList.Create;
  try
    if TryStrToDateTime(Value, idate) then
      Result := idate
    else
    begin
      if pos('-', Value) > 0 then
      begin
        lst.StrictDelimiter := true;
        lst.Delimiter := '-';
        lst.DelimitedText := Value;
        year := StrToInt(lst[0]);
        month := StrToInt(copy(lst[1], 0, 2));
        day := StrToInt(copy(lst[2], 0, 2));
        Result := EncodeDate(year, month, day)
      end;

      if pos(':', Value) > 0 then
      begin

        lst.StrictDelimiter := true;
        if pos('T', uppercase(Value)) > 0 then
          lst.Delimiter := 'T'
        else
          lst.Delimiter := ' ';
        lst.DelimitedText := Value;
        stime := lst[1];
        if stime <> '' then
        begin
          lst.StrictDelimiter := true;
          lst.Delimiter := ':';
          lst.DelimitedText := stime;
          if lst.Count > 0 then

            hour := StrToInt(lst[0]);
          if lst.Count > 1 then
            minut := StrToInt(lst[1]);
          if lst.Count > 2 then
            second := StrToInt(copy(lst[2], 0, 2));
          Result := Result + EncodeTime(hour, minut, second, 0);
        end;
      end;

    end;
  finally
    FreeAndNil(lst);
  end;

end;

{ ------------------------------------------------------------------------------- }
function formatvalue(Value: double): string;
begin
  Result := StringReplace(FloatToStr(Value), ',', '.', [rfReplaceAll]);

end;

{ ------------------------------------------------------------------------------ }
function vLrXmltoFloat(Value: string): double;
var
  s: string;
begin
  Result := 0;

  s := StringReplace(Value, '.', FormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  if s <> '' then
    Result := strtofloat(s);
end;

{ ------------------------------------------------------------------------------ }
function valinteger(Value: string): integer;
var
  s: string;
begin
  Result := 0;

end;

{ ------------------------------------------------------------------------------ }
function pegarSaidaDOS(Comando, DiretorioTrabalho: string): string;
{$IFDEF MSWINDOWS}
var
  saSegunranca: TSecurityAttributes;
  siInformacoesInicializacao: TStartupInfo;
  piInformacaoDoProcesso: TProcessInformation;
  hLeitura, hEscrita: THandle;
  bOk, bHandle: Boolean;
  Buffer: array [0 .. 255] of AnsiChar;
  BytesLidos: Cardinal;
  Diretorio: string;
begin
  Result := '';
  with saSegunranca do
  begin
    nLength := SizeOf(saSegunranca);
    bInheritHandle := true;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(hLeitura, hEscrita, @saSegunranca, 0);
  try
    with siInformacoesInicializacao do
    begin
      FillChar(siInformacoesInicializacao,
        SizeOf(siInformacoesInicializacao), 0);
      cb := SizeOf(siInformacoesInicializacao);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE);
      hStdOutput := hEscrita;
      hStdError := hEscrita;
    end;
    Diretorio := DiretorioTrabalho;
    bHandle := CreateProcess(nil, PChar('cmd.exe /c ' + Comando), nil, nil,
      true, 0, nil, PChar(Diretorio), siInformacoesInicializacao,
      piInformacaoDoProcesso);
    CloseHandle(hEscrita);
    if bHandle then
    begin
      try
        repeat
          bOk := ReadFile(hLeitura, Buffer, 255, BytesLidos, nil);
          if BytesLidos > 0 then
          begin
            Buffer[BytesLidos] := #0;
            Result := Result + Buffer;
          end;
        until not bOk or (BytesLidos = 0);
        WaitForSingleObject(piInformacaoDoProcesso.hProcess, INFINITE);
      finally
        CloseHandle(piInformacaoDoProcesso.hThread);
        CloseHandle(piInformacaoDoProcesso.hProcess);
      end;
    end;
  finally
    CloseHandle(hLeitura);
  end;
{$ENDIF }
end;

function SimpleRoundToEX(const AValue: Extended;
  const ADigit: TRoundToRange = -2): Extended;
var
  LFactor: Extended;
begin
  LFactor := IntPower(10.0, ADigit);
  if AValue < 0 then
    Result := Int((AValue / LFactor) - 0.5) * LFactor
  else
    Result := Int((AValue / LFactor) + 0.5) * LFactor;
end;

{ -----------------------------------------------------------------------------
  Arredondamento segundo as normas da ABNT NBR 5891/77  (por: DSA)
  Fontes:
  http://www.sofazquemsabe.com/2011/01/como-fazer-arredondamento-da-numeracao.html
  http://partners.bematech.com.br/2011/12/edicao-98-entendendo-o-truncamento-e-arredondamento-no-ecf/
  ----------------------------------------------------------------------------- }
function RoundABNT(const AValue: double; const Digits: TRoundToRange;
  const Delta: double = 0.00001): double;
var
  Pow, FracValue, PowValue: Extended;
  RestPart: double;
  IntCalc, FracCalc, LastNumber, IntValue: Int64;
  Negativo: Boolean;
Begin
  Negativo := (AValue < 0);

  Pow := IntPower(10, abs(Digits));
  PowValue := abs(AValue) / 10;
  IntValue := trunc(PowValue);
  FracValue := frac(PowValue);

  PowValue := SimpleRoundToEX(FracValue * 10 * Pow, -9);
  // SimpleRoundTo elimina dizimas ;
  IntCalc := trunc(PowValue);
  FracCalc := trunc(frac(PowValue) * 100);

  if (FracCalc > 50) then
    Inc(IntCalc)

  else if (FracCalc = 50) then
  begin
    LastNumber := round(frac(IntCalc / 10) * 10);

    if odd(LastNumber) then
      Inc(IntCalc)
    else
    begin
      RestPart := frac(PowValue * 10);

      if RestPart > Delta then
        Inc(IntCalc);
    end;
  end;

  Result := ((IntValue * 10) + (IntCalc / Pow));
  if Negativo then
    Result := -Result;
end;

{ ----------------------------------------------------------------------------- }

function EscapeString(const AValue: string): string;
const
  ESCAPE = '\';
  // QUOTATION_MARK = '"';
  REVERSE_SOLIDUS = '\';
  SOLIDUS = '/';
  BACKSPACE = #8;
  FORM_FEED = #12;
  NEW_LINE = #10;
  CARRIAGE_RETURN = #13;
  HORIZONTAL_TAB = #9;
var
  AChar: Char;
begin
  try
    Result := '';
    for AChar in AValue do
    begin

      case AChar of

        REVERSE_SOLIDUS:
          Result := Result + ESCAPE + REVERSE_SOLIDUS;
        SOLIDUS:
          Result := Result + ESCAPE + SOLIDUS;
        BACKSPACE:
          Result := Result + ESCAPE + 'b';
        FORM_FEED:
          Result := Result + ESCAPE + 'f';
        NEW_LINE:
          Result := Result + ESCAPE + 'n';
        CARRIAGE_RETURN:
          Result := Result + ESCAPE + 'r';
        HORIZONTAL_TAB:
          Result := Result + ESCAPE + 't';
      else
        begin
          if (integer(AChar) < 32) or (integer(AChar) > 126) then
            Result := Result + ESCAPE + 'u' + IntToHex(integer(AChar), 4)
          else
            Result := Result + AChar;
        end;
      end;
    end;
  finally
    Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
  end;
end;

{ ---------------------------------------------------------------------- }
function formatMsg(Value: string): string;
begin
  Result := EscapeString(Value);

end;

{ ---------------------------------------------------------------------- }
function Valfloat(Value: string): double;
var
  vfloat: double;
  svalue: string;
  fs: TFormatSettings;
begin
  Result := 0;
  svalue := Value;
  if not TryStrToFloat(Value, vfloat) then
  begin
    try
      FillChar(fs, SizeOf(fs), 0);
      fs.ThousandSeparator := ',';
      fs.DecimalSeparator := '.';
      Result := strtofloat(Value, fs);

    except
      Value := StringReplace(Value, '.', ',', [rfReplaceAll]);
      if TryStrToFloat(Value, vfloat) then
        Result := RoundTo(vfloat, -2)
      else
        raise exception.Create('Valor ' + Value +
          ' Nao pode ser covertido para float');
    end;
  end
  else
    Result := vfloat;
end;

{ ---------------------------------------------------------------------- }
function valString(Value: string): string;
begin
  Result := Value;
  Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '''', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '''', [rfReplaceAll]);
  Result := EscapeString(Result);
  Result := '"' + Result + '"';
end;



{ ---------------------------------------------------------------------- }
function makeJason(cds: TclienTdataset; aliasdata: string = ''): string;
var
  Data: string;
  line: string;
  bmrk: TBookmark;
  R, i, F, t: integer;
begin
  try
    Result := '';
    cds.First;
    while not cds.Eof do
    begin

      line := '';
      for i := 0 to cds.FieldCount - 1 do
      begin
        if cds.Fields[i].Visible then
        begin
          if line <> '' then
            line := line + ',' + #13#10;
          line := line + '"' + cds.Fields[i].FullName + '":';
          if cds.Fields[i].DataType in [ftFloat, ftCurrency, ftInteger, ftBCD]
          then
          begin
            if cds.Fields[i].AsString <> '' then

              line := line + StringReplace(cds.Fields[i].AsString, ',', '.',
                [rfReplaceAll])
            else

              line := line + '""';
          end
          else if cds.Fields[i].DataType in [ftDate, ftDateTime, ftTimeStamp]
          then
          begin

            begin
              with TXSDateTime.Create() do
                try

                  AsUTCDateTime := cds.Fields[i].AsDateTime;
                  line := line + valString(copy(NativeToXS, 0, 19));
                finally
                  Free;
                end;

            end;
          end
          else
          begin
            line := line + valString(cds.Fields[i].AsString);
          end;
        end;
      end;
      if Data <> '' then
        Data := Data + ',';
      Data := Data + '{' + line + '}' + #13#10;
      cds.next
    end;
    if aliasdata = '' then
      aliasdata := 'data';
    Data := '{ "' + aliasdata + '": [' + #13#10 + Data + #13#10 + ']}';
    if DebugHook <> 0 then
    begin
      with TStringList.Create do
      begin
        Text := Data;
        savetofile(ExtractFilePath(GetModuleName(HInstance)) + 'Consulta.json');
        Free;
      end;
    end;
    Result := Data;
  except
    on e: exception do
      raise exception.Create('Error na geração do arquivo json ' + e.Message);
  end;
end;

procedure gravalog(mensagem: string);
var
  strSaida: string;
  HWND: Cardinal;
  procedure registrarLogEmArquivo;
  var
    p: string;
    F: TextFile;
  begin
    try
      try
        p := ExtractFilePath(ParamStr(0)) + 'log\';
        ForceDirectories(p);
        p := p + FormatDateTime('yyyymmdd', now) + '_' +
          ChangeFileExt(ExtractFileName(ParamStr(0)), '') + '.log';
        AssignFile(F, p);
        if not FileExists(p) then
          Rewrite(F)
        else
          Append(F);
        Writeln(F, strSaida);
      except
      end;
    finally
      Closefile(F);
    end;
  end;

begin
  Try
    HWND := 0;

    try
      strSaida := FormatDateTime('hh:nn:ss.zzz', now) + ' - ' + mensagem;
      OutputDebugString(PChar(datetimetostr(now) + ' - ' + mensagem));

      registrarLogEmArquivo;

    finally

    end;
  except
  end;
end;

end.
