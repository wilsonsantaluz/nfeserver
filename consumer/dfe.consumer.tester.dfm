object fconsumer: Tfconsumer
  Left = 0
  Top = 0
  Caption = 'Rest test'
  ClientHeight = 721
  ClientWidth = 985
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
    Width = 985
    Height = 41
    Align = alBottom
    TabOrder = 0
  end
  object pagutils: TPageControl
    Left = 0
    Top = 0
    Width = 985
    Height = 680
    ActivePage = tabclass
    Align = alClient
    TabOrder = 1
    object tabgerarXml: TTabSheet
      Caption = 'gera'#231'ao Xml NFE'
      ImageIndex = 2
      object Label16: TLabel
        Left = 16
        Top = 32
        Width = 67
        Height = 13
        Caption = 'Cnpj Emitente'
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 977
        Height = 17
        Align = alTop
        TabOrder = 0
      end
      object GroupBox1: TGroupBox
        Left = 16
        Top = 64
        Width = 313
        Height = 274
        Caption = 'Dados da nota (exemplo apenas com dados basicos)'
        TabOrder = 1
        object Label3: TLabel
          Left = 8
          Top = 24
          Width = 67
          Height = 13
          Caption = 'Cnpj Emitente'
        end
        object Label4: TLabel
          Left = 8
          Top = 56
          Width = 65
          Height = 13
          Caption = 'C'#243'd numerico'
        end
        object Label5: TLabel
          Left = 8
          Top = 88
          Width = 37
          Height = 13
          Caption = 'Numero'
        end
        object Label6: TLabel
          Left = 8
          Top = 120
          Width = 24
          Height = 13
          Caption = 'Serie'
        end
        object Label7: TLabel
          Left = 8
          Top = 152
          Width = 87
          Height = 13
          Caption = 'Inscri'#231'ao estadual'
        end
        object Label8: TLabel
          Left = 8
          Top = 182
          Width = 89
          Height = 13
          Caption = 'Inscri'#231'ao municipal'
        end
        object edtcnpj: TEdit
          Left = 112
          Top = 21
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 0
          Text = '11395536000170'
        end
        object edtCodNumerico: TEdit
          Left = 112
          Top = 56
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 1
          Text = '111999'
        end
        object edtnumeronota: TEdit
          Left = 112
          Top = 85
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 2
          Text = '0'
        end
        object edtserienota: TEdit
          Left = 112
          Top = 117
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 3
          Text = '1'
        end
        object edtie: TEdit
          Left = 112
          Top = 149
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 4
          Text = '9018225902'
        end
        object btgerarNfeTeste: TButton
          Left = 3
          Top = 238
          Width = 75
          Height = 25
          Caption = 'Gerar xml'
          TabOrder = 5
          OnClick = btgerarNfeTesteClick
        end
        object edtim: TEdit
          Left = 112
          Top = 179
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 6
          Text = '5460200'
        end
      end
      object GroupBox2: TGroupBox
        Left = 376
        Top = 63
        Width = 465
        Height = 274
        Caption = 'Dados para cancelamento/carta correcao'
        TabOrder = 2
        object Label9: TLabel
          Left = 8
          Top = 24
          Width = 31
          Height = 13
          Caption = 'Chave'
        end
        object Label10: TLabel
          Left = 8
          Top = 56
          Width = 77
          Height = 13
          Caption = 'Numero da nota'
        end
        object Label12: TLabel
          Left = 8
          Top = 88
          Width = 24
          Height = 13
          Caption = 'Serie'
        end
        object Label13: TLabel
          Left = 8
          Top = 120
          Width = 45
          Height = 13
          Caption = 'Protocolo'
        end
        object Label14: TLabel
          Left = 8
          Top = 150
          Width = 57
          Height = 13
          Caption = 'Justificativa'
        end
        object Label11: TLabel
          Left = 8
          Top = 222
          Width = 72
          Height = 13
          Caption = 'Correcao carta'
        end
        object Label15: TLabel
          Left = 8
          Top = 184
          Width = 77
          Height = 13
          Caption = 'Sequencia carta'
        end
        object edtChave: TEdit
          Left = 112
          Top = 21
          Width = 321
          Height = 21
          Alignment = taCenter
          TabOrder = 0
          Text = '41210605651966001184550060006762371639684850'
        end
        object edtnumerocancelar: TEdit
          Left = 112
          Top = 53
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 1
          Text = '1'
        end
        object edtsereriecancelar: TEdit
          Left = 112
          Top = 85
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 2
          Text = '1'
        end
        object edtProtocolocancelamento: TEdit
          Left = 112
          Top = 117
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 3
        end
        object edtJustificativa: TEdit
          Left = 112
          Top = 147
          Width = 337
          Height = 21
          Alignment = taCenter
          TabOrder = 4
          Text = 'ERRO AO GERAR NOTA'
        end
        object edtcorrecao: TEdit
          Left = 112
          Top = 219
          Width = 337
          Height = 21
          Alignment = taCenter
          TabOrder = 5
          Text = 'LOGRADOURO ALTERADO :RUA SR55'
        end
        object edtsequencia: TEdit
          Left = 112
          Top = 181
          Width = 121
          Height = 21
          Alignment = taRightJustify
          TabOrder = 6
          Text = '1'
        end
      end
      object GroupBox3: TGroupBox
        Left = 16
        Top = 344
        Width = 505
        Height = 217
        Caption = 'Dados para inutiliza'#231#227'o'
        TabOrder = 3
        object Label17: TLabel
          Left = 16
          Top = 32
          Width = 65
          Height = 13
          Caption = 'Numero inicial'
        end
        object Label18: TLabel
          Left = 16
          Top = 64
          Width = 60
          Height = 13
          Caption = 'Numero final'
        end
        object Label19: TLabel
          Left = 16
          Top = 158
          Width = 57
          Height = 13
          Caption = 'Justificativa'
        end
        object Label20: TLabel
          Left = 16
          Top = 96
          Width = 24
          Height = 13
          Caption = 'Serie'
        end
        object Label21: TLabel
          Left = 16
          Top = 128
          Width = 19
          Height = 13
          Caption = 'Ano'
        end
        object edtnuninicial: TEdit
          Left = 88
          Top = 29
          Width = 88
          Height = 21
          Alignment = taRightJustify
          TabOrder = 0
          Text = '1'
        end
        object edtnunfinal: TEdit
          Tag = 700
          Left = 88
          Top = 61
          Width = 88
          Height = 21
          Alignment = taRightJustify
          TabOrder = 1
          Text = '1'
        end
        object edtjustinu: TEdit
          Left = 16
          Top = 177
          Width = 337
          Height = 21
          Alignment = taCenter
          TabOrder = 2
          Text = 'ERRO AO GERAR NOTA'
        end
        object edtserieinu: TEdit
          Left = 88
          Top = 90
          Width = 88
          Height = 21
          Alignment = taRightJustify
          TabOrder = 3
          Text = '777'
        end
        object edtanoinu: TEdit
          Left = 88
          Top = 122
          Width = 88
          Height = 21
          Alignment = taRightJustify
          TabOrder = 4
          Text = '2021'
        end
      end
      object Edit1: TEdit
        Left = 96
        Top = 29
        Width = 121
        Height = 21
        Alignment = taRightJustify
        TabOrder = 4
        Text = '11395536000170'
      end
      object GroupBox4: TGroupBox
        Left = 544
        Top = 343
        Width = 377
        Height = 274
        Caption = 'Consulta'
        TabOrder = 5
        object Label22: TLabel
          Left = 16
          Top = 34
          Width = 31
          Height = 13
          Caption = 'Chave'
        end
        object Label23: TLabel
          Left = 2
          Top = 123
          Width = 373
          Height = 13
          Align = alBottom
          Caption = 'Xml retornado'
          ExplicitWidth = 67
        end
        object edtconsultaChave: TEdit
          Left = 16
          Top = 53
          Width = 321
          Height = 21
          Alignment = taCenter
          TabOrder = 0
          Text = 'NFe35210703075319000174550017141406231001119998'
        end
        object btconsultar: TButton
          Left = 16
          Top = 80
          Width = 75
          Height = 25
          Caption = 'consultar'
          TabOrder = 1
          OnClick = btconsultarClick
        end
        object memoxmlRetornado: TMemo
          Left = 2
          Top = 136
          Width = 373
          Height = 136
          Align = alBottom
          Lines.Strings = (
            'memoxmlRetornado')
          TabOrder = 2
        end
      end
    end
    object tabclass: TTabSheet
      Caption = 'Rest testes'
      object grouprequest: TGroupBox
        Left = 0
        Top = 49
        Width = 977
        Height = 603
        Align = alClient
        Caption = ' path  -> /dfeapi/nfe'
        TabOrder = 0
        object Splitter1: TSplitter
          Left = 2
          Top = 244
          Width = 973
          Height = 0
          Cursor = crVSplit
          Align = alTop
          ExplicitTop = 145
          ExplicitWidth = 874
        end
        object Splitter2: TSplitter
          Left = 2
          Top = 241
          Width = 973
          Height = 3
          Cursor = crVSplit
          Align = alTop
          ExplicitTop = 368
          ExplicitWidth = 195
        end
        object memorequest: TMemo
          Left = 2
          Top = 50
          Width = 973
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
          Width = 973
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
          Width = 973
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
          Width = 973
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
          Width = 973
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
        Width = 977
        Height = 49
        Align = alTop
        TabOrder = 1
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
        Width = 459
        Height = 652
        Align = alClient
        TabOrder = 1
        object memojson: TMemo
          Left = 1
          Top = 1
          Width = 457
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
            '')
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
        end
      end
    end
  end
end
