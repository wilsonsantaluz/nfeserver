unit dfe.dao.cartaCorrecao;

interface

Uses
  windows,
  sysutils,
  REST.JSON.Types,
  REST.JSON,
  system.JSON,
  dfe.dao.base,
  dfe.model.cartaCorrecao,
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
  TDaoCartaCorrecao = class(TdfeDaoBase)
  private

  public
    function gravarCartaCorrecao(pCartaCorrecao: TCartaCorrecao): Boolean;
    function getCartaCorrecao(param: TJSONObject): TCartaCorrecao;
    function listCartaCorrecaos(param: TJSONObject): TcartasCorrecao;


  end;

implementation

{ TDaoNfe }
{----------------------------------------------------------------------------}
function  TDaoCartaCorrecao.getCartaCorrecao(param: TJSONObject): TCartaCorrecao;
var
  oCrs: IMongoCursor;
  s: string;
  oCartaCorrecao: TCartaCorrecao;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionCartaCorrecao);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []) ;
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionCartaCorrecao);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;
  result:= TCartaCorrecao.create();
  if oCrs.Next then
  begin
    s := oCrs.Doc.AsJSON;
    result := Tjson.JsonToObject<TCartaCorrecao>(s);
  end;

end;
{----------------------------------------------------------------------------}
function  TDaoCartaCorrecao.gravarCartaCorrecao(pCartaCorrecao: TCartaCorrecao): Boolean;
var
  oText: string;
  oDoc: TMongoDocument;
  oCol: TMongoCollection;
begin
  if Assigned(pCartaCorrecao) then
  begin
    oCol := FCon[_Db][_ColectionCartaCorrecao];
    oText := Tjson.ObjectToJsonString(pCartaCorrecao);
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
function  TDaoCartaCorrecao.listCartaCorrecaos(param: TJSONObject): TcartasCorrecao;
var
  oCrs: IMongoCursor;
  s: string;
  oCartaCorrecao: TCartaCorrecao;
  oQry: TMongoQuery;
  collection: TMongoCollection;
begin
  if Assigned(param) then
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionCartaCorrecao);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oQry.Match(param.ToJSON);
    oCrs := collection.Find(oQry, []) ;
  end
  else
  begin
    collection := FCon.Databases[_Db].GetCollection(_ColectionCartaCorrecao);
    oQry := TMongoQuery.create(collection.Env).Limit(500);
    oCrs := collection.Find(oQry, [])
  end;

  Result := TcartasCorrecao.create;
  oCartaCorrecao:=TcartaCorrecao.Create;
  Result.Add(oCartaCorrecao);
  while oCrs.Next do
  begin
    s := oCrs.Doc.AsJSON;

    oCartaCorrecao := Tjson.JsonToObject<TCartaCorrecao>(s);
    Result.Add(oCartaCorrecao);
  end;

end;
{----------------------------------------------------------------------------}
end.
