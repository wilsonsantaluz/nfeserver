unit dfe.model.infonfe;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.json,
  System.classes;
type
  Tanalissemensal=class
    tipo :string;
    valor:double;
    data:TDateTime;
  end;
type
  TanalisesmensalList = TObjectList<Tanalissemensal>;

type
  TinfoNfe = class
  private
    FnotasEmitidas: integer;
    FnotasCanceladas: integer;
    FnotasInutilizadas: integer;
    FerrosEmissao: integer;
    FdataUpdate: TDate;
    Fanalissemensal:TanalisesmensalList;
  published
    property notasEmitidas: integer read FnotasEmitidas write FnotasEmitidas;
    property notasCanceladas: integer read FnotasCanceladas
      write FnotasCanceladas;
    property notasInutilizadas: integer read FnotasInutilizadas
      write FnotasInutilizadas;
    property errosEmissao: integer read FerrosEmissao write FerrosEmissao;
    property dataUpdate: TDate read FdataUpdate write FdataUpdate;
    property analissemensal: TanalisesmensalList read Fanalissemensal write Fanalissemensal;
  public
    constructor create;

  end;

implementation

{ TinfoNfe }

constructor TinfoNfe.create;
begin
  FnotasEmitidas := 0;
  FnotasCanceladas := 0;
  FnotasInutilizadas := 0;
  FerrosEmissao := 0;
  FdataUpdate := now;
  Fanalissemensal:=TanalisesmensalList.create();;
end;

end.
