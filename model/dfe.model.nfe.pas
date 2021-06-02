unit dfe.model.nfe;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  system.json,
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
    Fstatus: Integer;
    Fmotivo: String;
    Ftxt: string;
    FdataValidacao: Tdatetime;
    Fprotocolo: string;

  public
    constructor create(param: string);
  published
    property Cnpj: string read Fcnpj write Fcnpj;
    property Numero: Integer read Fnumero write Fnumero;
    property Serie: Integer read Fserie write Fserie;
    property Chave: string read Fchave write Fchave;
    property DataEmissao: Tdatetime read FdataEmissao write FdataEmissao;
    property Xml: string read Fxml write Fxml;
    property Txt: string read Ftxt write Ftxt;
    property Status: Integer read Fstatus write Fstatus;
    property Motivo: string read Fmotivo write Fmotivo;
    property DataValidacao: Tdatetime read FdataValidacao write FdataValidacao;
    property Protocolo: string read Fprotocolo write Fprotocolo;
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
  oparam:tjsonObject;
begin
  dao := TDaoNfe.create;
  try
    if param <>'' then
    begin
      oparam:=TJSONObject.Create;
      oparam.ParseJSONValue(param);
       dao.getNota(oparam);
    end;
  finally
    FreeAndNil(dao);
  end;
end;

end.
