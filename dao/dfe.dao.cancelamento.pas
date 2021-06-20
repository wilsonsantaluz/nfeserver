unit dfe.dao.cancelamento;

interface

Uses
  windows,
  sysutils,
  REST.JSON.Types,
  REST.JSON,
  system.JSON,
  dfe.dao.base,
  dfe.model.cancelamento,
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
  TDaoCancelamento = class(TdfeDaoBase)
  private

  public
    function gravarCancelamento(pCancelamento: TCancelamento): Boolean;
    function getCancelamento(param: TJSONObject): TCancelamento;
    function listCancelamentos(param: TJSONObject): TCancelamentos;

  end;

implementation

{ TDaoNfe }
{ ---------------------------------------------------------------------------- }
function TDaoCancelamento.getCancelamento(param: TJSONObject): TCancelamento;
var
  oCrs: IMongoCursor;
  s: string;
  oCancelamento: TCancelamento;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionCancelamentos);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []);
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionCancelamentos);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;
  result := TCancelamento.create();
  if oCrs.Next then
  begin
    s := oCrs.Doc.AsJSON;
    result := Tjson.JsonToObject<TCancelamento>(s);
  end;

end;

{ ---------------------------------------------------------------------------- }
function TDaoCancelamento.gravarCancelamento(pCancelamento
  : TCancelamento): Boolean;
var
  oText: string;
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
begin
  if Assigned(pCancelamento) then
  begin
    oCol := FCon[_Db][_ColectionCancelamentos];
    oText := Tjson.ObjectToJsonString(pCancelamento);
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

{ ---------------------------------------------------------------------------- }
function TDaoCancelamento.listCancelamentos(param: TJSONObject): TCancelamentos;
var
  oCrs: IMongoCursor;
  s: string;
  oCancelamento: TCancelamento;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionCancelamentos);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []);
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionCancelamentos);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;

  result := TCancelamentos.create;
  oCancelamento := TCancelamento.create;
  result.Add(oCancelamento);
  while oCrs.Next do
  begin
    s := oCrs.Doc.AsJSON;

    oCancelamento := Tjson.JsonToObject<TCancelamento>(s);
    result.Add(oCancelamento);
  end;

end;

{ ---------------------------------------------------------------------------- }
end.
