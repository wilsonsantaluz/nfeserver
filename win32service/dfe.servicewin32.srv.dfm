object nfeserver: Tnfeserver
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = #174' Servidor NFE service'
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
