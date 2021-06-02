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
    Fnumero: string;
    Ftelefone: string;
    FinscricaoMunicipal: string;
    FinscricaoEstadual: string;
    FcertificadoPfx: string;
    FsenhaPfx: string;
    Fvalidade: TDateTime;
    Fambiente: integer;

  public

  published
    property cnpj: string read Fcnpj write Fcnpj;
    property razaoSocial: string read FrazaoSocial write FrazaoSocial;
    property endereco: string read Fendereco write Fendereco;
    property bairro: string read Fbairro write Fbairro;
    property cidade: string read Fcidade write Fcidade;
    property codMunicipio: string read FcodMunicipio write FcodMunicipio;
    property complemento: string read Fcomplemento write Fcomplemento;
    property numero: string read Fnumero write Fnumero;
    property telefone: string read Ftelefone write Ftelefone;
    property inscricaoMunicipal: string read FinscricaoMunicipal
      write FinscricaoMunicipal;
    property inscricaoEstadual: string read FinscricaoEstadual
      write FinscricaoEstadual;
    property certificadoPfx: string read FcertificadoPfx write FcertificadoPfx;
    property senhaPfx: string read FsenhaPfx write FsenhaPfx;
    property validade: TDateTime read Fvalidade write Fvalidade;
    property ambiente: integer read Fambiente write Fambiente;
  end;

type
  Tempresas = TObjectList<TEmpresa>;

implementation

end.
