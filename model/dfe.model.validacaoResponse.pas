unit dfe.model.validacaoResponse;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  System.classes;

Type
  TValidacaoResponse = class
  private

    Fcnpj: string;
    Fnumero: integer;
    Fserie: integer;
    Fchave: string;
    Fmodelo: integer;
    FxmlProcesado: string;
    FxmlRetorno: string;
    Fxmotivo: string;
    Fcstat: integer;
    Fprotocolo: string;
    FdanfeBase64:string;
    Fdigito: string;
    FdataProcesamemento: tdatetime;
    FdataValidacao: tdatetime;

  public

  published

    property cnpj: string read Fcnpj write Fcnpj;
    property numero: integer read Fnumero write Fnumero;
    property serie: integer read Fserie write Fserie;
    property modelo: integer read Fmodelo write Fmodelo;
    property xmlProcesado: string read FxmlProcesado write FxmlProcesado;
    property chave: string read Fchave write Fchave;
    property xmlRetorno: string read FxmlRetorno write FxmlRetorno;
    property danfeBase64: string read FdanfeBase64 write FdanfeBase64;
    property xmotivo: string read Fxmotivo write Fxmotivo;
    property cstat: integer read Fcstat write Fcstat;
    property protocolo: string read Fprotocolo write Fprotocolo;
    property digito: string read Fdigito write Fdigito;
    property dataProcesamemento: tdatetime read FdataProcesamemento
      write FdataProcesamemento;
    property dataValidacao: tdatetime read FdataValidacao write FdataValidacao;
  end;

implementation

{ Tlog }

end.
