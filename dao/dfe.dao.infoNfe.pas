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
  dfe.model.nfe,
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
  TRetornoInfo = class
  private
    F_id: TDateTime;
    Fcount: integer;
  public
    property _id: TDateTime read F_id write F_id;
    property count: integer read Fcount write Fcount;
  end;

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
  oret: TRetornoInfo;
  oQry: TMongoQuery;
  collection: TMongoCollection;
  oanalisse: Tanalissemensal;

begin
  result := TinfoNfe.create();
  result.notasEmitidas := FCon[_db][_ColectionNotas].count().value();
  result.notasCanceladas := FCon[_db][_ColectionCancelamentos].count().value();
  result.notasInutilizadas := FCon[_db][_ColectionInutilizacao].count().value();
  result.errosEmissao := FCon[_db][_ColectionErros].count().value();

  oCrs := FCon[_db][_ColectionNotas].Aggregate().Match.Add('cancelada',
    false).&End

    .Group.Add('_id', '$dataEmissao').BeginObject('count').Add('$sum', 1)

    .EndObject.&End;

  while oCrs.Next do
  begin
    oanalisse := Tanalissemensal.create;
    oret := REST.JSON.Tjson.JsonToObject<TRetornoInfo>(oCrs.Doc.AsJSON);
    oanalisse.tipo := 'VALIDADAS';
    oanalisse.valor := oret.count;
    oanalisse.Data := oret._id;
    result.analissemensal.Add(oanalisse);
  end;

  oCrs := FCon[_db][_ColectionNotas].Aggregate().Match.Add('cancelada',
    true).&End

    .Group.Add('_id', '$dataEmissao').BeginObject('count').Add('$sum', 1)

    .EndObject.&End;

  while oCrs.Next do
  begin
    oanalisse := Tanalissemensal.create;
    oret := REST.JSON.Tjson.JsonToObject<TRetornoInfo>(oCrs.Doc.AsJSON);
    oanalisse.tipo := 'CANCELADAS';
    oanalisse.valor := oret.count;
    oanalisse.Data := oret._id;
    result.analissemensal.Add(oanalisse);
  end;

end;

{ ---------------------------------------------------------------------------- }
procedure TDaoInfoNfe.setInfoNfe(value: TinfoNfe);
begin
  {TODO}
end;

end.
