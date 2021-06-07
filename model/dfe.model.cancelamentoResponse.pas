unit dfe.model.cancelamentoResponse;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  System.classes;

Type
  TCancelamentoResponse = class

  private

    Fcnpj: string;
    Fnumero: integer;
    Fserie: integer;
    Fmodelo: integer;
    Fambiente: integer;
    FprotocoloCancelamento: string;
    Fdata: Tdate;
    Fjustificativa: string;
    Fcstat: integer;
    Fxmotivo: string;
    FxmlRetorno:string;

  public

  published

    property cnpj: string read Fcnpj write Fcnpj;
    property numero: integer read Fnumero write Fnumero;
    property serie: integer read Fserie write Fserie;
    property modelo: integer read Fmodelo write Fmodelo;
    property ambiente: integer read Fambiente write Fambiente;
    property protocoloCacelamento: string read FprotocoloCancelamento
      write FprotocoloCancelamento;
    property data: Tdate read Fdata write Fdata;
    property justificativa: string read Fjustificativa write Fjustificativa;
    property cstat: integer read Fcstat write Fcstat;
    property xmotivo: string read Fxmotivo write Fxmotivo;
    property xmlRetorno: string read FxmlRetorno write FxmlRetorno;
  end;

implementation

{ TCancelamentoResponse }

end.
