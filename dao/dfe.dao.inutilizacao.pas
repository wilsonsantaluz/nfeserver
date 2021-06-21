unit dfe.dao.inutilizacao;

interface

Uses
  windows,
  sysutils,
  REST.JSON.Types,
  REST.JSON,
  system.JSON,
  dfe.dao.base,
  dfe.model.inutilizacao,
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
  TDaoInutilizacao = class(TdfeDaoBase)
  private

  public
    function gravarInutilizacao(pInutilizacao: TInutilizacao): Boolean;
    function getInutilizacao(param: TJSONObject): TInutilizacao;
    function listInutilizacaos(param: TJSONObject): TInutilizacoes;

  end;

implementation

{ TDaoNfe }
{ ---------------------------------------------------------------------------- }
function TDaoInutilizacao.getInutilizacao(param: TJSONObject): TInutilizacao;
var
  oCrs: IMongoCursor;
  s: string;
  oInutilizacao: TInutilizacao;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionInutilizacao);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []);
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionInutilizacao);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;
  result := TInutilizacao.create();
  if oCrs.Next then
  begin
    s := oCrs.Doc.AsJSON;
    result := Tjson.JsonToObject<TInutilizacao>(s);
  end;

end;

{ ---------------------------------------------------------------------------- }
function TDaoInutilizacao.gravarInutilizacao(pInutilizacao
  : TInutilizacao): Boolean;
var
  oText: string;
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
begin
  if Assigned(pInutilizacao) then
  begin
    oCol := FCon[_Db][_ColectionInutilizacao];
    oText := Tjson.ObjectToJsonString(pInutilizacao);
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
function TDaoInutilizacao.listInutilizacaos(param: TJSONObject): TInutilizacoes;
var
  oCrs: IMongoCursor;
  s: string;
  oInutilizacao: TInutilizacao;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionInutilizacao);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []);
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionInutilizacao);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;
  result := TInutilizacoes.create;
  while oCrs.Next do
  begin
    s := oCrs.Doc.AsJSON;
    oInutilizacao := Tjson.JsonToObject<TInutilizacao>(s);
    result.Add(oInutilizacao);
  end;

end;

{ ---------------------------------------------------------------------------- }
end.
