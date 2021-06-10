unit dfe.model.cancelamento;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  System.classes;

Type
  TCancelamento = class
  private
    Fcnpj: string;
    Fnumero: integer;
    Fserie: integer;
    Fchave: string;
    Fambiente: integer;
    FprotocoloNota: string;
    FprotocoloCancelamento: string;
    Fdata: Tdate;
    Fjustificativa: string;
    Fcstat: integer;
    Fxmotivo: string;
    FxmlRetorno: string;
    Fdanfe: string;
  public

  published

    property cnpj: string read Fcnpj write Fcnpj;
    property numero: integer read Fnumero write Fnumero;
    property serie: integer read Fserie write Fserie;
    property chave: string read Fchave write Fchave;
    property ambiente: integer read Fambiente write Fambiente;
    property protocoloNota: string read FprotocoloNota write FprotocoloNota;
    property protocoloCancelamento: string read FprotocoloCancelamento
      write FprotocoloCancelamento;
    property data: Tdate read Fdata write Fdata;
    property justificativa: string read Fjustificativa write Fjustificativa;
    property cstat: integer read Fcstat write Fcstat;
    property xmotivo: string read Fxmotivo write Fxmotivo;
    property xmlRetorno: string read FxmlRetorno write FxmlRetorno;
    property danfe: string read Fdanfe write Fdanfe;
  end;

type

  Tcancelamentos = TObjectList<TCancelamento>;

implementation

end.
