unit dfe.model.empresa;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  System.classes;

Type
  TEmpresa = class
  private
    Fcnpj: string;
    FrazaoSocial: string;
    Fendereco: string;
    Fbairro: string;
    Fcidade: string;
    FcodMunicipio: string;
    Fcomplemento: string;
    Fuf: string;
    Fnumero: string;
    Ftelefone: string;
    FinscricaoMunicipal: string;
    FinscricaoEstadual: string;
    FnomecertificadoPfx: string;
    FcertificadoPfx: string;
    FsenhaPfx: string;
    Fvalidade: TDateTime;
    Fambiente: integer;
    procedure cloneEmpresa(source: TEmpresa);
  public
    constructor create(cnpj: string);
  published
    property cnpj: string read Fcnpj write Fcnpj;
    property razaoSocial: string read FrazaoSocial write FrazaoSocial;
    property endereco: string read Fendereco write Fendereco;
    property bairro: string read Fbairro write Fbairro;
    property cidade: string read Fcidade write Fcidade;
    property codMunicipio: string read FcodMunicipio write FcodMunicipio;
    property complemento: string read Fcomplemento write Fcomplemento;
    property numero: string read Fnumero write Fnumero;
    property uf: string read Fuf write Fuf;
    property telefone: string read Ftelefone write Ftelefone;
    property inscricaoMunicipal: string read FinscricaoMunicipal
      write FinscricaoMunicipal;
    property inscricaoEstadual: string read FinscricaoEstadual
      write FinscricaoEstadual;
    property nomecertificadoPfx: string read FnomecertificadoPfx
      write FnomecertificadoPfx;
    property certificadoPfx: string read FcertificadoPfx write FcertificadoPfx;
    property senhaPfx: string read FsenhaPfx write FsenhaPfx;
    property validade: TDateTime read Fvalidade write Fvalidade;
    property ambiente: integer read Fambiente write Fambiente;
  end;

type
  Tempresas = TObjectList<TEmpresa>;

implementation

uses
  dfe.dao.empresa;

{ TEmpresa }

procedure TEmpresa.cloneEmpresa(source: TEmpresa);
begin
  Fcnpj := source.cnpj;
  FrazaoSocial := source.razaoSocial;
  Fendereco := source.endereco;
  Fbairro := source.bairro;
  Fcidade := source.cidade;
  FcodMunicipio := source.codMunicipio;
  Fcomplemento := source.complemento;
  Fnumero := source.numero;
  Fuf := source.uf;
  Ftelefone := source.telefone;
  FinscricaoMunicipal := source.inscricaoMunicipal;
  FinscricaoEstadual := source.inscricaoEstadual;
  FnomecertificadoPfx := source.nomecertificadoPfx;
  FcertificadoPfx := source.certificadoPfx;
  FsenhaPfx := source.senhaPfx;
  Fvalidade := source.validade;
  Fambiente := source.ambiente;
end;

{ ------------------------------------------------------------------------------ }
constructor TEmpresa.create(cnpj: string);
var
  dao: TDaoEmpresa;
  tmpEmpresa: TEmpresa;
begin
  if cnpj <> '' then
  begin
    try
      dao:= TDaoEmpresa.create;
      tmpEmpresa := dao.getEmpresa(cnpj);
      cloneEmpresa(tmpEmpresa);
    finally
      FreeAndNil(tmpEmpresa);
      FreeAndNil(dao);
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
end.
