unit utester;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
   Xml.XmlTransform, Xml.XMLIntf, Xml.xmldom,System.JSON, Xml.XMLDoc,
  FireDAC.Phys.MongoDBDef, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MongoDB, System.Rtti,
  System.JSON.Types, System.JSON.Readers, System.JSON.BSON,
  System.JSON.Builders, FireDAC.Phys.MongoDBWrapper, FireDAC.VCLUI.Wait,
  Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Phys.MongoDBDataSet;

type
  Tfteste = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    memoxml: TMemo;
    bt_xmltojson: TButton;
    memojson: TMemo;
    bt_jsontoxml: TButton;
    FDPhysMongoDriverLink1: TFDPhysMongoDriverLink;
    qry: TFDMongoQuery;
    FDConnection: TFDConnection;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Button1: TButton;
    Button2: TButton;
    procedure bt_xmltojsonClick(Sender: TObject);
    procedure bt_jsontoxmlClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
const
  DB_NAME = 'nfedb';
  COLLECTION_NAME = 'config';
var
  fteste: Tfteste;

implementation

uses

 dfe.lib.XmltoJson, dfe.lib.jsontoXml;
{$R *.dfm}

procedure Tfteste.bt_xmltojsonClick(Sender: TObject);
var
  xml : iXMLDocument;
  list : TStringList;
  json : TJSONObject;
  XMLtoJSON:TXMLtoJSON;

begin
  xml := XMLtoJSON.normalizeOrigin(memoxml.Text);
  list := XMLtoJSON.normalizeOrigin(xml);


  json := XMLtoJSON.originTypeToReturnType(xml);

  list := XMLtoJSON.normalizeReturn(json);

  memojson.lines := list;


end;

procedure Tfteste.Button1Click(Sender: TObject);
var
  i: Integer;
  MongConn: TMongoConnection;
  MongoDoc: TMongoDocument;
  MongoEnv: TMongoEnv;
begin
  MongConn := TMongoConnection(FDConnection.CliObj);
  MongoEnv := MongConn.Env;
  MongConn[DB_NAME][COLLECTION_NAME].RemoveAll;
  for i := 1 to 10 do
  begin
    MongoDoc := MongoEnv.NewDoc;
    try
      MongoDoc
        .Add('parametro', 'valor ' + IntToStr(i) + ' -parametro ' + IntToStr(i));
      MongConn[DB_NAME][COLLECTION_NAME].Insert(MongoDoc);
    finally
      MongoDoc.Free;
    end;
  end;

end;

procedure Tfteste.Button2Click(Sender: TObject);
begin
  qry.Open;
end;

procedure Tfteste.bt_jsontoxmlClick(Sender: TObject);
var
  xml : iXMLDocument;
  list : TStringList;
  json : TJSONObject;
  JSONtoXML:TJSONtoXML   ;

begin
  json := JSONtoXML.normalizeOrigin(memojson.Text);
  list := JSONtoXML.normalizeOrigin(json);

  xml := JSONtoXML.originTypeToReturnType(json);

  list := JSONtoXML.normalizeReturn(xml);

  memoxml.Lines.Text := list.Text
end;

end.
