unit dfe.model.cartaCorrecaoRequest;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.classes;

Type
  TcartaCorrecaoRequest = class
  private
  private
    Foperacao: string;
    Fcnpj: string;
    Fchave: string;
    FdataHora: TDateTime;
    Fsequencia: integer;
    Fxcorrecao: string;
    FxmlEvento: string;
    Fcstat: integer;
    Fxmotivo: string;
  public
    constructor create;
  published
    property operacao: string read Foperacao;
    property cnpj: string read Fcnpj write Fcnpj;
    property chave: string read Fchave write Fchave;
    property dataHora: TDateTime read FdataHora write FdataHora;
    property sequencia: integer read Fsequencia write Fsequencia;
    property xcorrecao: string read Fxcorrecao write Fxcorrecao;

  end;

implementation

{ TcartaCorrecaoRequestRequest }

constructor TcartaCorrecaoRequest.create;
begin
  Foperacao := 'cartacorrecao'
end;

end.
