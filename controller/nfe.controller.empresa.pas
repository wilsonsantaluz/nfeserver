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
  dfe.dao.infonfe,
  dfe.lib.util,
  dfe.model.empresa;

type
  TEmpresaController = class
  private
    Fmodel: TEmpresa;
  public
    function gravarEmpresa(JSON: TJSONObject): string;
    function apagarEmpresa(JSON: TJSONObject): string;
    function getEmpresa(JSON: TJSONObject): string;
    function listarEmpresa(JSON: TJSONObject): string;

  end;

implementation

{ TEmpresaController }
{ ----------------------------------------------------------------------------- }
function TEmpresaController.apagarEmpresa(JSON: TJSONObject): string;
var
  dao: TDaoEmpresa;
  empresa: TEmpresa;
begin
  dao := TDaoEmpresa.create;
  try
    empresa := TEmpresa.create('');
    empresa := TJson.JsonToObject<TEmpresa>(JSON);
    dao.apagarEmpresa(empresa);
    result := 'Empresa ' + empresa.cnpj + ' excluida';
  finally
    if assigned(empresa) then
      FreeAndNil(empresa);
    FreeAndNil(dao);
  end;
end;

{ ----------------------------------------------------------------------------- }
function TEmpresaController.getEmpresa(JSON: TJSONObject): string;
var
  dao: TDaoEmpresa;
  empresas: Tempresas;
begin
  dao := TDaoEmpresa.create;
  try
    if assigned(JSON) then
      empresas := dao.listEmpresas(JSON)
    else
      empresas := dao.listEmpresas(Nil);
    result := TJson.ObjectToJsonString(empresas);
  finally
    if assigned(empresas) then
      FreeAndNil(empresas);
    FreeAndNil(dao);
  end;

end;

{ ----------------------------------------------------------------------------- }
function TEmpresaController.gravarEmpresa(JSON: TJSONObject): string;
var
  dao: TDaoEmpresa;
  empresa: TEmpresa;

begin
  dao := TDaoEmpresa.create;
  try
    empresa := TEmpresa.create('');
    empresa := TJson.JsonToObject<TEmpresa>(JSON);
    if (empresa.cnpj = '') or (Length(sonumeros(empresa.cnpj)) <> 14) then
      raise Exception.create('Cnpj não informado ou invalido -> ' +
        empresa.cnpj);
    if empresa.razaoSocial = '' then
      raise Exception.create('Razão social não informada');
    if empresa.certificadoPfx = '' then
      raise Exception.create('Arquivo pfx não informado');
    if empresa.senhaPfx = '' then
      raise Exception.create('Senha do arquivo pfx não informada');
    if empresa.validade = 0 then
      raise Exception.create('Validade do arquivo pfx não informada');
    dao.gravarEmpresa(empresa);
    result := 'Empresa ' + empresa.cnpj + ' gravada/atualizada';
  finally
    if assigned(empresa) then
      FreeAndNil(empresa);
    FreeAndNil(dao);
  end;
end;

{ ----------------------------------------------------------------------------- }
function TEmpresaController.listarEmpresa(JSON: TJSONObject): string;
var
  dao: TDaoEmpresa;
  empresas: Tempresas;
begin
  dao := TDaoEmpresa.create;
  try
    if assigned(JSON) then
      empresas := dao.listEmpresas(JSON)
    else
      empresas := dao.listEmpresas(Nil);
    result := TJson.ObjectToJsonString(empresas);
  finally
    if assigned(empresas) then
      FreeAndNil(empresas);
    FreeAndNil(dao);
  end;
end;

{ ----------------------------------------------------------------------------- }
end.
