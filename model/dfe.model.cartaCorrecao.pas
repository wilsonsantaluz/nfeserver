unit dfe.model.cartaCorrecao;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.classes;
Type
  TcartaCorrecao = class
  private
    Fcnpj: string;
    Fchave: string;
    FdataHora: TDateTime;
    Fsequencia: integer;
    Fxcorrecao: string;
    FxmlEvento:string;
    FprotocoloCCe:string;
    Fcstat:Integer;
    Fxmotivo:string;
  public
  published
    property cnpj: string read Fcnpj write Fcnpj;
    property chave: string read Fchave write Fchave;
    property dataHora: TDateTime read FdataHora write FdataHora;
    property sequencia: integer read Fsequencia write Fsequencia;
    property xcorrecao: string read Fxcorrecao write Fxcorrecao;
    property xmlEvento: string read FxmlEvento write FxmlEvento;
    property cstat: integer read Fcstat write Fcstat;
    property xmotivo: string read Fxmotivo write Fxmotivo;
    property protocoloCce: string read FprotocoloCCe write FprotocoloCCe;
  end;
type
  TcartasCorrecao = TObjectList<TcartaCorrecao>;
implementation

{ TcartaCorrecao }


end.


