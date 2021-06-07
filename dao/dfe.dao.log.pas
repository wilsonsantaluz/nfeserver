unit dfe.dao.log;

interface

Uses
  windows,
  sysutils,
  REST.JSON.Types,
  REST.JSON,
  system.JSON,
  dfe.dao.base,
  dfe.model.log,
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
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.MongoDBWrapper,
  system.JSON.Types,
  system.JSON.BSON,
  system.JSON.Builders,
  system.Rtti,
  system.JSON.Readers,
  system.Diagnostics,
  FireDAC.Stan.Util,
  classes;

type
  TDaoLog = class(TdfeDaoBase)
  private

  public
    procedure gravarLog(plog:Tlog);

    function listLog(param: TJSONObject): TLogs ;

  end;

implementation

{ TDaoLog }
{----------------------------------------------------------------------------}

{----------------------------------------------------------------------------}
procedure TDaoLog.gravarLog(plog: Tlog)  ;
var
  oText: string;
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
begin
  if Assigned(plog) then
  begin
    oCol := FCon[_Db][_ColectionLogs];
    oText := Tjson.ObjectToJsonString(plog);
    oDoc := FEnv.NewDoc;
    try
      oCol.BeginBulk;
      try
        oDoc.AsJSON := oText;
        oCol.Insert(oDoc);
        oCol.EndBulk;
      except
        oCol.CancelBulk;
        raise;
      end;
    finally
      oDoc.Free;
    end;
  end;
end;
{----------------------------------------------------------------------------}

{----------------------------------------------------------------------------}
function TDaoLog.listLog(param: TJSONObject): Tlogs;
var
  oCrs: IMongoCursor;
  s: string;
  olog: Tlog;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionNotas);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []) ;
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionNotas);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;

  Result := Tlogs.create;
  while oCrs.Next do
  begin
    s := oCrs.Doc.AsJSON;
    olog := Tlog.create();
    olog := Tjson.JsonToObject<Tlog>(s);
    Result.Add(olog);
  end;

end;
{----------------------------------------------------------------------------}
end.
