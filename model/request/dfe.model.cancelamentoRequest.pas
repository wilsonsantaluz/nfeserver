unit dfe.model.cancelamentoRequest;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  System.classes;

Type
  TCancelamentoRequest = class

  private
    Foperacao: string;
    Fcnpj: string;
    Fnumero: integer;
    Fserie: integer;
    Fmodelo: integer;
    Fchave: string;
    Fambiente: integer;
    Fprotocolo: string;
    Fdata: Tdate;
    Fjustificativa: string;

  public
    constructor create;
  published
    property operacao: string read Foperacao;
    property cnpj: string read Fcnpj write Fcnpj;
    property numero: integer read Fnumero write Fnumero;
    property serie: integer read Fserie write Fserie;
    property chave: string read Fchave write Fchave;
    property modelo: integer read Fmodelo write Fmodelo;
    property ambiente: integer read Fambiente write Fambiente;
    property protocolo: string read Fprotocolo write Fprotocolo;
    property data: Tdate read Fdata write Fdata;
    property justificativa: string read Fjustificativa write Fjustificativa;

  end;

implementation

{ TCancelamentoRequest }

constructor TCancelamentoRequest.create;
begin
  Foperacao := 'cancelamento'
end;

end.
