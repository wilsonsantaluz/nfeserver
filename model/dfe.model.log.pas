unit dfe.model.log;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  System.classes;

Type
  Tlog = class
  private
    Fdate: TDateTime;
    Fdescription: string;
    Fseverity: integer;
    FtypeLog :Integer;
    FownerClass: string;
    FassertLine: integer;

  public

  published
    property date: TDateTime read Fdate write Fdate;
    property description: string read Fdescription write Fdescription;
    property severity: integer read Fseverity write Fseverity;
    property ownerClass: string read FownerClass write FownerClass;
    property assertLine: integer read FassertLine write FassertLine;
    property typeLog: integer read FtypeLog write FtypeLog;

  end;

type
  Tlogs = TObjectList<Tlog>;

implementation


{ Tlog }


end.
