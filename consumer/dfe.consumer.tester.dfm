object fconsumer: Tfconsumer
  Left = 0
  Top = 0
  Caption = 'Rest test'
  ClientHeight = 721
  ClientWidth = 886
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 680
    Width = 886
    Height = 41
    Align = alBottom
    TabOrder = 0
  end
  object pagutils: TPageControl
    Left = 0
    Top = 0
    Width = 886
    Height = 680
    ActivePage = tabclass
    Align = alClient
    TabOrder = 1
    object tabgerarXml: TTabSheet
      Caption = 'gera'#231'ao Xml NFE'
      ImageIndex = 2
      ExplicitLeft = 8
      ExplicitTop = 22
    end
    object tabclass: TTabSheet
      Caption = 'Rest testes'
      object grouprequest: TGroupBox
        Left = 0
        Top = 49
        Width = 878
        Height = 603
        Align = alClient
        Caption = ' path  -> /dfeapi/nfe'
        TabOrder = 0
        object Splitter1: TSplitter
          Left = 2
          Top = 244
          Width = 874
          Height = 0
          Cursor = crVSplit
          Align = alTop
          ExplicitTop = 145
        end
        object Splitter2: TSplitter
          Left = 2
          Top = 241
          Width = 874
          Height = 3
          Cursor = crVSplit
          Align = alTop
          ExplicitTop = 368
          ExplicitWidth = 195
        end
        object memorequest: TMemo
          Left = 2
          Top = 50
          Width = 874
          Height = 191
          Align = alTop
          Color = clBlack
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
        end
        object Panel3: TPanel
          Left = 2
          Top = 563
          Width = 874
          Height = 38
          Align = alBottom
          TabOrder = 1
          object btenviar: TButton
            Left = 102
            Top = 6
            Width = 75
            Height = 25
            Caption = 'Enviar'
            TabOrder = 0
            OnClick = btenviarClick
          end
          object btgerarJson: TButton
            Left = 21
            Top = 6
            Width = 75
            Height = 25
            Caption = 'Gerar'
            TabOrder = 1
            OnClick = btgerarJsonClick
          end
        end
        object memoviewxml: TMemo
          Left = 2
          Top = 377
          Width = 874
          Height = 186
          Align = alClient
          Color = clBlack
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clLime
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 2
        end
        object Panel5: TPanel
          Left = 2
          Top = 15
          Width = 874
          Height = 35
          Align = alTop
          TabOrder = 3
          object Label2: TLabel
            Left = 16
            Top = 8
            Width = 69
            Height = 13
            Caption = 'opera'#231#227'o post'
          end
          object cboperacao: TComboBox
            Left = 93
            Top = 5
            Width = 145
            Height = 22
            Style = csOwnerDrawVariable
            ItemIndex = 0
            TabOrder = 0
            Text = 'validacao'
            OnChange = cboperacaoChange
            Items.Strings = (
              'validacao'
              'cancelamento'
              'inutilizacao'
              'cartacorrecao')
          end
        end
        object memoresponse: TMemo
          Left = 2
          Top = 244
          Width = 874
          Height = 133
          Align = alTop
          Color = clBlack
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clLime
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 4
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 878
        Height = 49
        Align = alTop
        TabOrder = 1
        ExplicitLeft = 2
        ExplicitTop = -6
        object Label1: TLabel
          Left = 16
          Top = 16
          Width = 45
          Height = 13
          Caption = 'Endere'#231'o'
        end
        object edtendereco: TEdit
          Left = 67
          Top = 14
          Width = 782
          Height = 21
          TabOrder = 0
          Text = 'http://localhost:4475'
        end
      end
    end
    object tabtransformer: TTabSheet
      Caption = 'Transforma'#231#227'o util'
      ImageIndex = 1
      object pnlcomands: TPanel
        Left = 430
        Top = 0
        Width = 88
        Height = 652
        Align = alLeft
        TabOrder = 0
        object bt_xmltojson: TButton
          Left = 5
          Top = 6
          Width = 75
          Height = 25
          Caption = 'XML to JSON'
          TabOrder = 0
          OnClick = bt_xmltojsonClick
        end
        object bt_jsontoxml: TButton
          Left = 6
          Top = 37
          Width = 75
          Height = 25
          Caption = 'JSON to XML'
          TabOrder = 1
          OnClick = bt_jsontoxmlClick
        end
      end
      object TPanel
        Left = 518
        Top = 0
        Width = 360
        Height = 652
        Align = alClient
        TabOrder = 1
        object memojson: TMemo
          Left = 1
          Top = 1
          Width = 358
          Height = 650
          Align = alClient
          Color = clBlack
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clLime
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
      object TPanel
        Left = 0
        Top = 0
        Width = 430
        Height = 652
        Align = alLeft
        TabOrder = 2
        object memoxml: TMemo
          Left = 1
          Top = 1
          Width = 428
          Height = 650
          Align = alClient
          Color = clBlack
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          Lines.Strings = (
            '<NFe>'
            #9'<infNFe>'
            #9#9'<ide>'
            #9#9#9'<cUF>41</cUF>'
            #9#9#9'<cNF>63968485</cNF>'
            #9#9#9'<natOp>VENDA PRODUTO C  ST</natOp>'
            #9#9#9'<mod>55</mod>'
            #9#9#9'<serie>6</serie>'
            #9#9#9'<nNF>676237</nNF>'
            #9#9#9'<dhEmi>2021-06-07T12:04:48-03:00</dhEmi>'
            #9#9#9'<dhSaiEnt>2021-07-04T12:04:48-03:00</dhSaiEnt>'
            #9#9#9'<tpNF>1</tpNF>'
            #9#9#9'<idDest>1</idDest>'
            #9#9#9'<cMunFG>4103701</cMunFG>'
            #9#9#9'<tpImp>1</tpImp>'
            #9#9#9'<tpEmis>1</tpEmis>'
            #9#9#9'<cDV>0</cDV>'
            #9#9#9'<tpAmb>2</tpAmb>'
            #9#9#9'<finNFe>1</finNFe>'
            #9#9#9'<indFinal>0</indFinal>'
            #9#9#9'<indPres>0</indPres>'
            #9#9#9'<procEmi>0</procEmi>'
            #9#9#9'<verProc>emissorxx</verProc>'
            #9#9'</ide>'
            #9#9'<emit>'
            #9#9#9'<CNPJ>03075319000174</CNPJ>'
            #9#9#9'<xNome>WILSON RODRIGUES DA LUZ</xNome>'
            #9#9#9'<xFant>'#9'WS INFORMATICA</xFant>'
            #9#9#9'<enderEmit>'
            #9#9#9#9'<xLgr>R JOSE CARLOS MUFATTO, 2560</xLgr>'
            #9#9#9#9'<nro>2560</nro>'
            #9#9#9#9'<xBairro>JD RIVIERA</xBairro>'
            #9#9#9#9'<cMun>4103701</cMun>'
            #9#9#9#9'<xMun>CAMBE</xMun>'
            #9#9#9#9'<UF>PR</UF>'
            #9#9#9#9'<CEP>86187025</CEP>'
            #9#9#9#9'<cPais>1058</cPais>'
            #9#9#9#9'<xPais>BRASIL</xPais>'
            #9#9#9'</enderEmit>'
            #9#9#9'<IE>9018225902</IE>'
            #9#9#9'<IM>5460200</IM>'
            #9#9#9'<CNAE>0000000</CNAE>'
            #9#9#9'<CRT>3</CRT>'
            #9#9'</emit>'
            #9#9'<dest>'
            #9#9#9'<CNPJ>12044700001724</CNPJ>'
            #9#9#9'<xNome>destinatariox</xNome>'
            #9#9#9'<enderDest>'
            #9#9#9#9'<xLgr>UNKNOW STREET</xLgr>'
            #9#9#9#9'<nro>780</nro>'
            #9#9#9#9'<xBairro>BIGORRILHO</xBairro>'
            #9#9#9#9'<cMun>4106902</cMun>'
            #9#9#9#9'<xMun>CURITIBA</xMun>'
            #9#9#9#9'<UF>PR</UF>'
            #9#9#9#9'<CEP>80730402</CEP>'
            #9#9#9#9'<cPais>1058</cPais>'
            #9#9#9#9'<xPais>BRASIL</xPais>'
            #9#9#9'</enderDest>'
            #9#9#9'<indIEDest>1</indIEDest>'
            #9#9#9'<IE>9084192942</IE>'
            #9#9#9'<email>destinatario@mail.com</email>'
            #9#9'</dest>'
            #9#9'<det nItem="1">'
            #9#9#9'<prod>'
            #9#9#9#9'<cProd>49420</cProd>'
            #9#9#9#9'<cEAN>7896261020269</cEAN>'
            #9#9#9#9'<xProd>ENTRESTO 24+26MG 28CPR</xProd>'
            #9#9#9#9'<NCM>30049049</NCM>'
            #9#9#9#9'<CEST>1300401</CEST>'
            #9#9#9#9'<CFOP>5403</CFOP>'
            #9#9#9#9'<uCom>UN</uCom>'
            #9#9#9#9'<qCom>2</qCom>'
            #9#9#9#9'<vUnCom>123.4300</vUnCom>'
            #9#9#9#9'<vProd>246.86</vProd>'
            #9#9#9#9'<cEANTrib>7896261020269</cEANTrib>'
            #9#9#9#9'<uTrib>UN</uTrib>'
            #9#9#9#9'<qTrib>2.0000</qTrib>'
            #9#9#9#9'<vUnTrib>123.4300</vUnTrib>'
            #9#9#9#9'<vDesc>69.96</vDesc>'
            #9#9#9#9'<indTot>1</indTot>'
            #9#9#9#9'<xPed>PBM</xPed>'
            #9#9#9#9'<rastro>'
            #9#9#9#9#9'<nLote>TFN35</nLote>'
            #9#9#9#9#9'<qLote>2</qLote>'
            #9#9#9#9#9'<dFab>2020-07-09</dFab>'
            #9#9#9#9#9'<dVal>2023-06-30</dVal>'
            #9#9#9#9'</rastro>'
            #9#9#9#9'<med>'
            #9#9#9#9#9'<cProdANVISA>1006811410018</cProdANVISA>'
            #9#9#9#9#9'<vPMC>164.16</vPMC>'
            #9#9#9#9'</med>'
            #9#9#9'</prod>'
            #9#9#9'<imposto>'
            #9#9#9#9'<ICMS>'
            #9#9#9#9#9'<ICMS10>'
            #9#9#9#9#9#9'<orig>2</orig>'
            #9#9#9#9#9#9'<CST>10</CST>'
            #9#9#9#9#9#9'<modBC>3</modBC>'
            #9#9#9#9#9#9'<vBC>176.90</vBC>'
            #9#9#9#9#9#9'<pICMS>12.00</pICMS>'
            #9#9#9#9#9#9'<vICMS>21.23</vICMS>'
            #9#9#9#9#9#9'<modBCST>1</modBCST>'
            #9#9#9#9#9#9'<pRedBCST>16.00</pRedBCST>'
            #9#9#9#9#9#9'<vBCST>275.79</vBCST>'
            #9#9#9#9#9#9'<pICMSST>18.00</pICMSST>'
            #9#9#9#9#9#9'<vICMSST>28.41</vICMSST>'
            #9#9#9#9#9'</ICMS10>'
            #9#9#9#9'</ICMS>'
            #9#9#9#9'<IPI>'
            #9#9#9#9#9'<cEnq>999</cEnq>'
            #9#9#9#9#9'<IPINT>'
            #9#9#9#9#9#9'<CST>53</CST>'
            #9#9#9#9#9'</IPINT>'
            #9#9#9#9'</IPI>'
            #9#9#9#9'<PIS>'
            #9#9#9#9#9'<PISNT>'
            #9#9#9#9#9#9'<CST>04</CST>'
            #9#9#9#9#9'</PISNT>'
            #9#9#9#9'</PIS>'
            #9#9#9#9'<COFINS>'
            #9#9#9#9#9'<COFINSNT>'
            #9#9#9#9#9#9'<CST>04</CST>'
            #9#9#9#9#9'</COFINSNT>'
            #9#9#9#9'</COFINS>'
            #9#9#9'</imposto>'
            #9#9#9'<infAdProd>info teste</infAdProd>'
            #9#9'</det>'
            #9#9'<total>'
            #9#9#9'<ICMSTot>'
            #9#9#9#9'<vBC>176.90</vBC>'
            #9#9#9#9'<vICMS>21.23</vICMS>'
            #9#9#9#9'<vICMSDeson>0.00</vICMSDeson>'
            #9#9#9#9'<vFCPUFDest>0.00</vFCPUFDest>'
            #9#9#9#9'<vICMSUFDest>0.00</vICMSUFDest>'
            #9#9#9#9'<vICMSUFRemet>0.00</vICMSUFRemet>'
            #9#9#9#9'<vFCP>0.00</vFCP>'
            #9#9#9#9'<vBCST>275.79</vBCST>'
            #9#9#9#9'<vST>28.41</vST>'
            #9#9#9#9'<vFCPST>0.00</vFCPST>'
            #9#9#9#9'<vFCPSTRet>0.00</vFCPSTRet>'
            #9#9#9#9'<vProd>246.86</vProd>'
            #9#9#9#9'<vFrete>0.00</vFrete>'
            #9#9#9#9'<vSeg>0.00</vSeg>'
            #9#9#9#9'<vDesc>69.96</vDesc>'
            #9#9#9#9'<vII>0.00</vII>'
            #9#9#9#9'<vIPI>0.00</vIPI>'
            #9#9#9#9'<vIPIDevol>0.00</vIPIDevol>'
            #9#9#9#9'<vPIS>0.00</vPIS>'
            #9#9#9#9'<vCOFINS>0.00</vCOFINS>'
            #9#9#9#9'<vOutro>0.00</vOutro>'
            #9#9#9#9'<vNF>205.31</vNF>'
            #9#9#9#9'<vTotTrib>0.00</vTotTrib>'
            #9#9#9'</ICMSTot>'
            #9#9'</total>'
            #9#9'<transp>'
            #9#9#9'<modFrete>0</modFrete>'
            #9#9#9'<transporta>'
            #9#9#9#9'<CNPJ>15488297000315</CNPJ>'
            #9#9#9#9'<xNome>SAO GABRIEL TRANSPORTES EIRELI - ME</xNome>'
            #9#9#9#9'<IE>ISENTO</IE>'
            #9#9#9#9'<xEnder>R ITALIA, 663</xEnder>'
            #9#9#9#9'<xMun>IBAITI</xMun>'
            #9#9#9#9'<UF>PR</UF>'
            #9#9#9'</transporta>'
            #9#9#9'<vol>'
            #9#9#9#9'<qVol>1</qVol>'
            #9#9#9#9'<esp>CX</esp>'
            #9#9#9#9'<pesoL>0.200</pesoL>'
            #9#9#9#9'<pesoB>0.000</pesoB>'
            #9#9#9'</vol>'
            #9#9'</transp>'
            #9#9'<cobr>'
            #9#9#9'<fat>'
            #9#9#9#9'<nFat>67623706</nFat>'
            #9#9#9#9'<vOrig>205.31</vOrig>'
            #9#9#9#9'<vDesc>0.00</vDesc>'
            #9#9#9#9'<vLiq>205.31</vLiq>'
            #9#9#9'</fat>'
            #9#9#9'<dup>'
            #9#9#9#9'<nDup>001</nDup>'
            #9#9#9#9'<dVenc>2021-08-03</dVenc>'
            #9#9#9#9'<vDup>205.31</vDup>'
            #9#9#9'</dup>'
            #9#9'</cobr>'
            #9#9'<pag>'
            #9#9#9'<detPag>'
            #9#9#9#9'<indPag>1</indPag>'
            #9#9#9#9'<tPag>15</tPag>'
            #9#9#9#9'<vPag>205.31</vPag>'
            #9#9#9'</detPag>'
            #9#9'</pag>'
            #9#9'<infAdic>'
            #9#9#9'<infAdFisco>Valor FCP: 0.00/ Valor FCPST: 0.00</infAdFisco>'
            #9#9#9'<infCpl>info cpl nota</infCpl>'
            #9#9#9'<obsCont xCampo="ROTA">'
            #9#9#9#9'<xTexto>CWB11-229-KDY-501</xTexto>'
            #9#9#9'</obsCont>'
            #9#9#9'<obsCont xCampo="NF">'
            #9#9#9#9'<xTexto>676237-07-00105-04/06/21</xTexto>'
            #9#9#9'</obsCont>'
            #9#9#9'<obsCont xCampo="TRANSPORTADORA">'
            #9#9#9#9'<xTexto>15488297000315</xTexto>'
            #9#9#9'</obsCont>'
            #9#9#9'<obsCont xCampo="RAZAO SOCIAL TRANSP">'
            #9#9#9#9'<xTexto>SAO GABRIEL TRANSPORTES EIRELI - ME</xTexto>'
            #9#9#9'</obsCont>'
            #9#9'</infAdic>'
            #9#9'<compra>'
            #9#9#9'<xPed>PBM</xPed>'
            #9#9'</compra>'
            #9#9'<infRespTec>'
            #9#9#9'<CNPJ>11395536000170</CNPJ>'
            #9#9#9'<xContato>wsinformatica@hotmail.com</xContato>'
            #9#9#9'<email>wsinformatica</email>'
            #9#9#9'<fone>5562993981242</fone>'
            #9#9'</infRespTec>'
            #9'</infNFe>'
            '</NFe>')
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
        end
      end
    end
  end
  object ACBrNFe1: TACBrNFe
    Configuracoes.Geral.SSLLib = libNone
    Configuracoes.Geral.SSLCryptLib = cryNone
    Configuracoes.Geral.SSLHttpLib = httpNone
    Configuracoes.Geral.SSLXmlSignLib = xsNone
    Configuracoes.Geral.FormatoAlerta = 'TAG:%TAGNIVEL% ID:%ID%/%TAG%(%DESCRICAO%) - %MSG%.'
    Configuracoes.Arquivos.OrdenacaoPath = <>
    Configuracoes.WebServices.UF = 'SP'
    Configuracoes.WebServices.AguardarConsultaRet = 0
    Configuracoes.WebServices.QuebradeLinha = '|'
    Configuracoes.RespTec.IdCSRT = 0
    Left = 440
    Top = 368
  end
end
