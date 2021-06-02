object SrvRpswin32: TSrvRpswin32
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = #174' PAINEL NFSE service'
  Height = 150
  Width = 215
  object tmstart: TTimer
    Enabled = False
    Interval = 15000
    OnTimer = tmstartTimer
    Left = 40
    Top = 56
  end
end
