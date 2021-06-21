unit dfe.model.nfe;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.json,
  System.classes;

Type
  Tnota = class
  private

    Fcnpj: string;
    Fnumero: Integer;
    Fserie: Integer;
    Fchave: string;
    FdataEmissao: Tdatetime;
    Fxml: string;
    FxmlRetorno: string;
    Fstatus: Integer;
    Fmotivo: String;
    Ftxt: string;
    Fdigitoval: string;
    FdataValidacao: Tdatetime;
    FdataProcessamento: Tdatetime;
    Fprotocolo: string;
    Fcancelada:Boolean;

  public
    constructor create(param: string);
  published
    property cnpj: string read Fcnpj write Fcnpj;
    property numero: Integer read Fnumero write Fnumero;
    property serie: Integer read Fserie write Fserie;
    property chave: string read Fchave write Fchave;
    property dataEmissao: Tdatetime read FdataEmissao write FdataEmissao;
    property xml: string read Fxml write Fxml;
    property xmlRetorno: string read FxmlRetorno write FxmlRetorno;
    property txt: string read Ftxt write Ftxt;
    property status: Integer read Fstatus write Fstatus;
    property motivo: string read Fmotivo write Fmotivo;
    property dataValidacao: Tdatetime read FdataValidacao write FdataValidacao;
    property dataProcessamento: Tdatetime read FdataProcessamento
      write FdataProcessamento;
    property protocolo: string read Fprotocolo write Fprotocolo;
    property digitoval: string read Fdigitoval write Fdigitoval;
    property cancelada: Boolean read Fcancelada write Fcancelada;

  end;

type
  Tnotas = TObjectList<Tnota>;

implementation

uses
  dfe.dao.nfe;

{ Tnota }

constructor Tnota.create(param: string);
var
  dao: TDaoNfe;
  oparam: tjsonObject;
begin
  dao := TDaoNfe.create;
  try
    if param <> '' then
    begin
      oparam := tjsonObject.create;
      oparam.ParseJSONValue(param);
      dao.getNota(oparam);
    end;
  finally
    if assigned(dao) then

    FreeAndNil(dao);
  end;
end;

end.
