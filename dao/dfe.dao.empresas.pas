unit dfe.dao.empresas;

interface

Uses
  windows,
  sysutils,
  REST.JSON.Types,
  REST.JSON,
  system.JSON,
  dfe.dao.base,
  dfe.model.empresa,
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
  TDaoEmpresa = class(TdfeDaoBase)
  private

  public
    function gravarEmpresa(pEmpresa: Tempresa): Boolean;
    function apagarEmpresa(pEmpresa: Tempresa): Boolean;

    function getEmpresa(param: TJSONObject): Tempresa;
    function listEmpresas(param: TJSONObject): Tempresas;

  end;

implementation

{ TDaoEmpresa }
{----------------------------------------------------------------------------}
function TDaoEmpresa.apagarEmpresa(pEmpresa: Tempresa): Boolean;
begin
  result:=false;
 FCon.Databases[_Db].GetCollection(_ColectionEmpresas).Remove()
    .Match()
      .Add('cnpj', pEmpresa.cnpj)
    .&End
  .Exec;
  result:=true;
end;

function TDaoEmpresa.getEmpresa(param: TJSONObject): TEmpresa;
var
  oCrs: IMongoCursor;
  s: string;
  oEmpresa: TEmpresa;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(5000);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []) ;
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(5000);
    oCrs := collection.Find(oQry, [])
  end;
  result:= TEmpresa.create();
  if oCrs.Next then
  begin
    s := oCrs.Doc.AsJSON;
    result := Tjson.JsonToObject<TEmpresa>(s);
  end;

end;
{----------------------------------------------------------------------------}
function TDaoEmpresa.gravarEmpresa(pEmpresa: TEmpresa): Boolean;
var
  oText: string;
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
begin
  result:=false;
  if Assigned(pEmpresa) then
  begin
    oCol := FCon[_Db][_ColectionEmpresas];
    oText := Tjson.ObjectToJsonString(pEmpresa);
    oDoc := FEnv.NewDoc;
    try
      oCol.BeginBulk;
      try
        oDoc.AsJSON := oText;
        oCol.Insert(oDoc);
        oCol.EndBulk;
        result:=true;
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
function TDaoEmpresa.listEmpresas(param: TJSONObject): TEmpresas;
var
  oCrs: IMongoCursor;
  s: string;
  oEmpresa: TEmpresa;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []) ;
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;

  Result := TEmpresas.create;
  while oCrs.Next do
  begin
    s := oCrs.Doc.AsJSON;
    oEmpresa := TEmpresa.create();
    oEmpresa := Tjson.JsonToObject<TEmpresa>(s);
    Result.Add(oEmpresa);
  end;

end;
{----------------------------------------------------------------------------}
end.
