{
  product id 1112  - generat:10/05/2021
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------

  __      __.__.__                        _______________  ____ ________
  /  \    /  \__|  |   __________   ____   \_____  \   _  \/_   /   __   \
  \   \/\/   /  |  |  /  ___/  _ \ /    \   /  ____/  /_\  \|   \____    /
  \        /|  |  |__\___ (  <_> )   |  \ /       \  \_/   \   |  /    /
  \__/\  / |__|____/____  >____/|___|  / \_______ \_____  /___| /____/
  \/               \/           \/          \/     \/
  -----------------------------------------------------------------------------


}
unit dfe.dao.base;

interface

uses
  System.SysUtils,
  variants,
  System.Classes,
  dfe.lib.util,
  inifiles,
  Data.DB,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.MongoDBDef,
  FireDAC.Phys.MongoDB,
  FireDAC.Comp.UI,
  FireDAC.Comp.Client,
  FireDAC.Phys.MongoDBWrapper,
  System.JSON.Types,
  System.JSON.BSON,
  System.JSON.Builders,
  System.Rtti,
  System.JSON.Readers,
  System.Diagnostics,
  FireDAC.Stan.util,
  FireDAC.Phys.MongoDBDataSet,
  FireDAC.Comp.DataSet;

const
  _Db = 'nfeDb';
  _ColectionNfe = 'nfe';
  _ColectionNotas = 'notas';
  _ColectionInfo = 'info';
  _ColectionConfig = 'config';
  _ColectionLotes = 'lotes';
  _ColectionEmpresas = 'empresas';
  _ColectionCancelamentos = 'cancelamentos';
  _ColectionLogs = 'nfelogs';
  _ColectionErros = 'erros';
  _ColectionInutilizacao = 'inutilizacoes';
  _ColectionCartaCorrecao = 'cartacorrecao';

type

  TdfeDaoBase = class
  private
    { Private declarations }

  public
    { Public declarations }
    FDConnection: TFDConnection;
    // FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDPhysMongoDriverLink: TFDPhysMongoDriverLink;
    FEnv: TMongoEnv;
    FCon: TMongoConnection;
    FQdata: TFDMongoQuery;
    Class procedure SetPoolDb();
    constructor create;
    destructor Destroy; override;

  end;

var
  dfeDaoBase: TdfeDaoBase;

implementation

constructor TdfeDaoBase.create;
begin
  try
    FDConnection := TFDConnection.create(Nil);

    FDPhysMongoDriverLink := TFDPhysMongoDriverLink(nil);
    FDConnection.LoginPrompt := false;
    FDConnection.DriverName := 'Mongo';
    FQdata := TFDMongoQuery.create(Nil);
    FQdata.Connection := FDConnection;

    FDConnection.Connected := True;
  except
    on e: Exception do
      raise Exception.create('Não foi posivel conectar ao servidor mongoDB ' +
        e.Message);

  end;
  FCon := TMongoConnection(FDConnection.CliObj);
  FEnv := FCon.Env;

end;

destructor TdfeDaoBase.Destroy;
begin

  inherited;
  try
    FDConnection.Close;
    FreeAndNil(FDConnection);
    FreeAndNil(FDPhysMongoDriverLink);
    FreeAndNil(FQdata);
  except
    on e: Exception do
      gravalog(e.Message);
  end;
end;

Class procedure TdfeDaoBase.SetPoolDb();
var
  ini: Tinifile;
begin

end;

{ ----------------------------------------------------------------------------- }
procedure setBinaryField(var oq: TFDQuery; fieldName, value: string);
var
  auxList: TStringList;
  auxStream: TMemoryStream;
begin
  try
    auxList := TStringList.create;
    auxList.Text := value;

    auxStream := TMemoryStream.create;
    auxList.SaveToStream(auxStream);
    auxStream.Position := 0;
    oq.paramByName(fieldName).DataType := ftBlob;
    oq.paramByName(fieldName).LoadFromStream(auxStream, ftBlob);
  finally
    FreeAndNil(auxList);
    FreeAndNil(auxStream);
  end;
end;
{ ----------------------------------------------------------------------------- }

end.
