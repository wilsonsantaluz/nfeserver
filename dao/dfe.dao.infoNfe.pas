unit dfe.dao.infoNfe;

interface

Uses
  windows,
  sysutils,
  REST.JSON.Types,
  REST.JSON,
  system.JSON,
  dfe.dao.base,
  dfe.model.infoNfe,
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
  Xsuperobject,

  classes;

type
  TDaoInfoNfe = class(TdfeDaoBase)
  private

  public
    function getInfoNfe: TinfoNfe;
    procedure setInfoNfe(value: TinfoNfe);

  end;

implementation

{ TDaoInfoNfe }
{ ---------------------------------------------------------------------------- }
function TDaoInfoNfe.getInfoNfe: TinfoNfe;
var
  oCrs: IMongoCursor;
  s: string;
  oinfo: TinfoNfe;
  oQry: TMongoQuery;
  collection: TMongoCollection;

begin
  collection := FCon.Databases[_Db].GetCollection(_ColectionInfo);
  oQry := TMongoQuery.create(collection.Env).Limit(500);
  oCrs := collection.Find(oQry, []);

  result := TinfoNfe.create();
  if oCrs.Next then
  begin
    s := oCrs.Doc.AsJSON;
    result := TJSON.Parse<TinfoNfe>(s);
    s := result.analissemensal[0].tipo;
  end;
end;

{ ---------------------------------------------------------------------------- }
procedure TDaoInfoNfe.setInfoNfe(value: TinfoNfe);
var
  oText: string;
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
begin
  if Assigned(value) then
  begin
    oCol := FCon[_Db][_ColectionInfo];
    oCol.RemoveAll;
    // oText := REST.JSON.Tjson.ObjectToJsonString(value);
    oText := TJSON.Stringify<TinfoNfe>(value);
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

end.
