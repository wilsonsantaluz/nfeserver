unit dfe.model.inutilizacaoRequest;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.classes;
Type
  TInutilizacaoRequest = class
  private
    Foperacao: string;
    Fcnpj: string;
    FnumeroInicial: integer;
    FnumeroFinal: integer;
    Fserie: integer;
    Fmodelo: integer;
    Fano: integer;
    Fjustificativa: string;

  public
    constructor create;
  published
    property operacao: string read Foperacao;
    property cnpj: string read Fcnpj write Fcnpj;
    property numeroInicial: integer read FnumeroInicial write FnumeroInicial;
    property numeroFinal: integer read FnumeroFinal write FnumeroFinal;
    property serie: integer read Fserie write Fserie;
    property modelo: integer read Fmodelo write Fmodelo;
    property ano: integer read Fano write Fano;
    property justificativa: string read Fjustificativa write Fjustificativa;
  end;

implementation

{ TInutilizacaoRequestRequest }

constructor TInutilizacaoRequest.create;
begin
  Foperacao := 'inutilizacao'
end;

end.
