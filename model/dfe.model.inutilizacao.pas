unit dfe.model.inutilizacao;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  System.classes;

Type
  TInutilizacao = class

  private

    Fcnpj: string;
    FnumeroInicial: integer;
    FnumeroFinal: integer;
    Fserie: integer;
    Fmodelo: integer;
    Fano: integer;
    Fjustificativa: string;
    Fprotocolo: string;
    FxmlEvento: string;

  public

  published

    property cnpj: string read Fcnpj write Fcnpj;
    property numeroInicial: integer read FnumeroInicial write FnumeroInicial;
    property numeroFinal: integer read FnumeroFinal write FnumeroFinal;
    property serie: integer read Fserie write Fserie;
    property modelo: integer read Fmodelo write Fmodelo;
    property ano: integer read Fano write Fano;
    property justificativa: string read Fjustificativa write Fjustificativa;
    property protocolo: string read Fprotocolo write Fprotocolo;
    property xmlEvento: string read FxmlEvento write FxmlEvento;
  end;

implementation

{ TInutilizacao }

end.
