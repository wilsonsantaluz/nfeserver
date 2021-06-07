unit nfe.controller.empresa;

interface

uses
  classes,
  REST.JSON.Types,
  REST.JSON,
  JSON,
  sysutils,

  dfe.dao.empresa,

  dfe.model.infonfe,
  dfe.dao.infoNfe,
  dfe.lib.util,
  dfe.model.empresa;

type
  TEmpresaController = class
  private
    Fmodel: TEmpresa;
  public
    function gravarEmpresa(json: TJSONObject): string;
    function apagarEmpresa(json: TJSONObject): string;
    function getEmpresa(json: TJSONObject): string;
    function listarEmpresa(json: TJSONObject): string;

  end;

implementation

{ TEmpresaController }
{-----------------------------------------------------------------------------}
function TEmpresaController.apagarEmpresa(json: TJSONObject): string;
var
  dao: TDaoEmpresa;
  empresa:TEmpresa;
begin
  dao := TDaoEmpresa.create;
  try
     empresa:=TEmpresa.Create('');
     empresa:=TJson.JsonToObject<TEmpresa> (json) ;
     dao.apagarEmpresa(empresa) ;
     result:='Empresa '+ empresa.cnpj +' excluida';
  finally
    if assigned(empresa) then
      FreeAndNil(empresa);
    FreeAndNil(dao);
  end;
end;


{-----------------------------------------------------------------------------}
function TEmpresaController.getEmpresa(json: TJSONObject): string;
var
  dao: TDaoEmpresa;
  empresas: Tempresas;
begin
  dao := TDaoEmpresa.create;
  try
    if assigned(JSON) then
    empresas:= dao.listEmpresas(JSON)
    else
     empresas:= dao.listEmpresas(Nil);
    result := tjson.ObjectToJsonString(empresas);
  finally
    if assigned(empresas) then
      FreeAndNil(empresas);
    FreeAndNil(dao);
  end;

end;
{-----------------------------------------------------------------------------}
function TEmpresaController.gravarEmpresa(json: TJSONObject): string;
var
  dao: TDaoEmpresa;
  empresa:TEmpresa;

begin
  dao := TDaoEmpresa.create;
  try
     empresa:=TEmpresa.Create('');
     empresa:=TJson.JsonToObject<TEmpresa> (json) ;
     if (empresa.cnpj ='') or (Length(sonumeros( empresa.cnpj)) <>14) then
       raise Exception.Create('Cnpj não informado ou invalido -> '+empresa.cnpj);
     if empresa.razaoSocial  ='' then
       raise Exception.Create('Razão social não informada');


     dao.gravarEmpresa(empresa) ;
     result:='Empresa '+ empresa.cnpj +' gravada/atualizada';
  finally
    if assigned(empresa) then
      FreeAndNil(empresa);
    FreeAndNil(dao);
  end;
end;
{-----------------------------------------------------------------------------}
function TEmpresaController.listarEmpresa(json: TJSONObject): string;
var
  dao: TDaoEmpresa;
  empresas: Tempresas;
begin
  dao := TDaoEmpresa.create;
  try
    if assigned(JSON) then
    empresas:= dao.listEmpresas(JSON)
    else
     empresas:= dao.listEmpresas(Nil);
    result := tjson.ObjectToJsonString(empresas);
  finally
    if assigned(empresas) then
      FreeAndNil(empresas);
    FreeAndNil(dao);
  end;
end;
{-----------------------------------------------------------------------------}
end.
