unit dfe.dao.empresa;

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
  dfe.lib.Util,
  classes;

type
  TDaoEmpresa = class(TdfeDaoBase)
  private

  public
    function gravarEmpresa(pEmpresa: Tempresa): Boolean;
    function apagarEmpresa(pEmpresa: Tempresa): Boolean;

    function getEmpresa(param: TJSONObject): Tempresa; overload;
    function getEmpresa(pcnpj: string): Tempresa; overload;
    function listEmpresas(param: TJSONObject): Tempresas;

  end;

implementation

{ TDaoEmpresa }
{ ---------------------------------------------------------------------------- }
function TDaoEmpresa.apagarEmpresa(pEmpresa: Tempresa): Boolean;
begin
  result := false;
  FCon.Databases[_Db].GetCollection(_ColectionEmpresas).Remove().Match()
    .Add('cnpj', pEmpresa.cnpj).&End.Exec;
  result := true;
end;

function TDaoEmpresa.getEmpresa(param: TJSONObject): Tempresa;
var
  oCrs: IMongoCursor;
  s: string;
  oEmpresa: Tempresa;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(5000);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []);
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(5000);
    oCrs := collection.Find(oQry, [])
  end;
  result := Tempresa.create('');
  if oCrs.Next then
  begin
    s := oCrs.Doc.AsJSON;
    result := Tjson.JsonToObject<Tempresa>(s);
  end;

end;

{ ---------------------------------------------------------------------------- }
function TDaoEmpresa.getEmpresa(pcnpj: string): Tempresa;
var
  oCrs: IMongoCursor;
  s: string;
  oEmpresa: Tempresa;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  try
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(5000);
    oQry.Match('{"cnpj":"' + (pcnpj) + '"}');
    oCrs := collection.Find(oQry, []);
    result := Tempresa.create('');
    if oCrs.Next then
    begin
      s := oCrs.Doc.AsJSON;
      result := Tjson.JsonToObject<Tempresa>(s);
    end;
  except
    on e: exception do
      gravalog(e.Message);
  end;
end;

function TDaoEmpresa.gravarEmpresa(pEmpresa: Tempresa): Boolean;
var
  oText: string;
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
  oQry: TMongoQuery;
  oCrs: IMongoCursor;
  oupdate: TMongoUpdate;
begin
  result := false;
  if Assigned(pEmpresa) then
  begin
    oCol := FCon[_Db][_ColectionEmpresas];
    try

      oText := Tjson.ObjectToJsonString(pEmpresa);
      oQry := TMongoQuery.create(oCol.Env).Limit(100);
      oQry.Match('{"cnpj":' + '"' + pEmpresa.cnpj + '"');
      oCrs := oCol.Find(oQry, []);
      if oCrs.Next then
      begin
        // REMOVER ACABA FICANDO MAIS RAPIDO
        oCol.Remove().Match().Add('cnpj', pEmpresa.cnpj).&End.Exec;
      end;
      oDoc := FEnv.NewDoc;
      try
        pEmpresa.cnpj := soNumeros(pEmpresa.cnpj);
        oText := Tjson.ObjectToJsonString(pEmpresa);
        oCol.BeginBulk;
        oDoc.AsJSON := oText;
        oCol.Insert(oDoc);
        oCol.EndBulk;
        result := true;
      except
        oCol.CancelBulk;
        raise;
      end;

    finally
      oDoc.Free;
    end;
  end;
end;

{ ---------------------------------------------------------------------------- }
function TDaoEmpresa.listEmpresas(param: TJSONObject): Tempresas;
var
  oCrs: IMongoCursor;
  s: string;
  oEmpresa: Tempresa;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []);
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionEmpresas);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;

  result := Tempresas.create;
  while oCrs.Next do
  begin
    s := oCrs.Doc.AsJSON;
    oEmpresa := Tempresa.create('');
    oEmpresa := Tjson.JsonToObject<Tempresa>(s);
    result.Add(oEmpresa);
  end;

end;

{ ---------------------------------------------------------------------------- }
end.
