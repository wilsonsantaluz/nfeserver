unit consumer.model.nfe;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.json,
  System.classes;

Type
  Tnota = class
  private

    Fcnpj: string;
    Fnumero: Integer;
    Fserie: Integer;
    Fchave: string;
    FdataEmissao: Tdatetime;
    Fxml: string;
    FxmlRetorno: string;
    Fstatus: Integer;
    Fmotivo: String;
    Ftxt: string;
    Fdigitoval: string;
    FdataValidacao: Tdatetime;
    FdataProcessamento: Tdatetime;
    Fprotocolo: string;
    Fdanfe:string;
    Fcancelada:Boolean;

  public

  published
    property cnpj: string read Fcnpj write Fcnpj;
    property numero: Integer read Fnumero write Fnumero;
    property serie: Integer read Fserie write Fserie;
    property chave: string read Fchave write Fchave;
    property dataEmissao: Tdatetime read FdataEmissao write FdataEmissao;
    property xml: string read Fxml write Fxml;
    property xmlRetorno: string read FxmlRetorno write FxmlRetorno;
    property txt: string read Ftxt write Ftxt;
    property status: Integer read Fstatus write Fstatus;
    property motivo: string read Fmotivo write Fmotivo;
    property dataValidacao: Tdatetime read FdataValidacao write FdataValidacao;
    property dataProcessamento: Tdatetime read FdataProcessamento
      write FdataProcessamento;
    property protocolo: string read Fprotocolo write Fprotocolo;
    property digitoval: string read Fdigitoval write Fdigitoval;
    property cancelada: Boolean read Fcancelada write Fcancelada;
    property danfe: string read Fdanfe write Fdanfe;



  end;

type
  Tnotas = TObjectList<Tnota>;

implementation


end.
