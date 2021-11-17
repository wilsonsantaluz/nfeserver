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
    FdhRecbto:TDateTime;
    Fprotocolo: string;
    FxmlEvento: string;
    Fxmotivo:string;
    Fcstat:integer;
    Fdanfe:string;
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
    property xmotivo: string read Fxmotivo write Fxmotivo;
    property cstat: integer read Fcstat write Fcstat;
    property xmlEvento: string read FxmlEvento write FxmlEvento;
    property danfe: string read Fdanfe write Fdanfe;
    property dhRecbto: TDateTime read FdhRecbto write FdhRecbto;
  end;
type
  TInutilizacoes = TObjectList<TInutilizacao>;
implementation

{ TInutilizacao }

end.
