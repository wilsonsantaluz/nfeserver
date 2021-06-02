unit nfe.controller.nfe;

interface

uses
  classes,
  REST.JSON.Types,
  REST.JSON,
  JSON,
  sysutils,
  dfe.model.nfe,
  dfe.model.config,
  dfe.dao.nfe,
  dfe.services.validar,
  dfe.model.infonfe,
  dfe.dao.infoNfe,
  dfe.model.empresa;

type
  TNnfeController = class
  private
    Fmodel: Tnota;
  public
    function validarNfe(JSON: TJSONObject): string;
    function cancelarNfe(JSON: TJSONObject): string;
    function inutilizarNfe(JSON: TJSONObject): string;
    function listarNfe(JSON: TJSONObject): string;
    function getInfo():string;
  end;

implementation

{ TNnfeController }
{-----------------------------------------------------------------------------}
function TNnfeController.cancelarNfe(JSON: TJSONObject): string;
begin
  // ***
end;
{-----------------------------------------------------------------------------}
function TNnfeController.getInfo: string;
var
   dao: TDaoInfoNfe;
   model:TinfoNfe;
begin
   dao :=TDaoInfoNfe.create;
   model:= dao.getInfoNfe();
   result:=tjson.ObjectToJsonString(model);
end;
{-----------------------------------------------------------------------------}
function TNnfeController.inutilizarNfe(JSON: TJSONObject): string;
begin
  /// ***
end;
{-----------------------------------------------------------------------------}
function TNnfeController.listarNfe(JSON: TJSONObject): string;
var
  dao: TDaoNfe;
  notas: Tnotas;
begin
  dao := TDaoNfe.create;
  try
    if assigned(JSON) then
      notas := dao.listNotas(JSON)
    else
      notas := dao.listNotas(Nil);
    result := tjson.ObjectToJsonString(notas);
  finally
    if assigned(notas) then
      FreeAndNil(notas);
    FreeAndNil(dao);
  end;
end;
{-----------------------------------------------------------------------------}
function TNnfeController.validarNfe(JSON: TJSONObject): string;
var
  jv: TJSONValue;
  Fnota: Tnota;
  Fvalidar: TNfeValidar;
begin
  Fnota := Tnota.create('');

  TNfeValidar.create(Fnota);
  if Fnota.Protocolo <> '' then
  begin

  end;

end;
{-----------------------------------------------------------------------------}
end.
