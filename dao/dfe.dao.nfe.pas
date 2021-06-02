unit dfe.dao.nfe;

interface

Uses
  windows,
  sysutils,
  REST.JSON.Types,
  REST.JSON,
  system.JSON,
  dfe.dao.base,
  dfe.model.nfe,
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
  TDaoNfe = class(TdfeDaoBase)
  private

  public
    function gravarNota(pnota: TNota): Boolean;
    function gravarNfe(jsonXml:string): Boolean;
    function getNota(param: TJSONObject): TNota;
    function listNotas(param: TJSONObject): TNotas;

  end;

implementation

{ TDaoNfe }
{----------------------------------------------------------------------------}
function TDaoNfe.getNota(param: TJSONObject): TNota;
var
  oCrs: IMongoCursor;
  s: string;
  onota: TNota;
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
  result:= TNota.create('');
  if oCrs.Next then
  begin
    s := oCrs.Doc.AsJSON;
    result := Tjson.JsonToObject<TNota>(s);
  end;

end;
{----------------------------------------------------------------------------}
function TDaoNfe.gravarNota(pnota: TNota): Boolean;
var
  oText: string;
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
begin
  if Assigned(pnota) then
  begin
    oCol := FCon[_Db][_ColectionNotas];
    oText := Tjson.ObjectToJsonString(pnota);
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
function TDaoNfe.gravarNfe(jsonXml:string): Boolean;
var
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
begin
  if jsonXml <>''  then
  begin
    oCol := FCon[_Db][_ColectionNfe];
    oDoc := FEnv.NewDoc;
    try
      oCol.BeginBulk;
      try
        oDoc.AsJSON := jsonXml;
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
function TDaoNfe.listNotas(param: TJSONObject): TNotas;
var
  oCrs: IMongoCursor;
  s: string;
  onota: TNota;
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

  Result := TNotas.create;
  while oCrs.Next do
  begin
    s := oCrs.Doc.AsJSON;
    onota := TNota.create('');
    onota := Tjson.JsonToObject<TNota>(s);
    Result.Add(onota);
  end;

end;
{----------------------------------------------------------------------------}
end.
