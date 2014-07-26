object Form1: TForm1
  Left = 1685
  Top = 137
  Width = 218
  Height = 772
  Caption = 'Motor Control'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object debug: TMemo
    Left = 8
    Top = 536
    Width = 185
    Height = 161
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object motorsettings_box: TGroupBox
    Left = 8
    Top = 168
    Width = 185
    Height = 273
    Caption = 'Motor Settings'
    TabOrder = 1
    object mmperrev_label: TLabel
      Left = 8
      Top = 90
      Width = 115
      Height = 13
      Caption = 'Millimeters per Rotation :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object stepsperrev_label: TLabel
      Left = 8
      Top = 42
      Width = 113
      Height = 13
      Caption = 'Full Steps per Rotation :'
    end
    object current_label: TLabel
      Left = 8
      Top = 120
      Width = 70
      Height = 13
      Caption = 'Motor Current :'
    end
    object idelcurrent_label: TLabel
      Left = 104
      Top = 120
      Width = 60
      Height = 13
      Caption = 'Idle Current :'
    end
    object ma_label_1: TLabel
      Left = 48
      Top = 140
      Width = 15
      Height = 13
      Caption = 'mA'
    end
    object ma_label_2: TLabel
      Left = 144
      Top = 140
      Width = 15
      Height = 13
      Caption = 'mA'
    end
    object accel_label: TLabel
      Left = 8
      Top = 172
      Width = 65
      Height = 13
      Caption = 'Acceleration :'
    end
    object accel_unit_label: TLabel
      Left = 135
      Top = 172
      Width = 44
      Height = 13
      Caption = 'steps / s²'
    end
    object decel_label: TLabel
      Left = 8
      Top = 196
      Width = 66
      Height = 13
      Caption = 'Deceleration :'
    end
    object decel_unit_label: TLabel
      Left = 135
      Top = 196
      Width = 44
      Height = 13
      Caption = 'steps / s²'
    end
    object velocity_label: TLabel
      Left = 8
      Top = 220
      Width = 43
      Height = 13
      Caption = 'Velocity :'
    end
    object velocity_unit_label: TLabel
      Left = 135
      Top = 220
      Width = 41
      Height = 13
      Caption = 'steps / s'
    end
    object stepping_box: TComboBox
      Left = 8
      Top = 16
      Width = 169
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 0
      Text = 'Motor Stepping'
      OnChange = stepping_boxChange
      Items.Strings = (
        'Full Steps     [200]'
        'Half Steps     [400]'
        'Quarter Steps  [800]'
        'Sixteenth Steps[3200]')
    end
    object units_box: TComboBox
      Left = 8
      Top = 64
      Width = 169
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 1
      Text = 'Motor Units'
      OnChange = units_boxChange
      Items.Strings = (
        'Steps'
        'Rotations'
        'Degrees'
        'Radians'
        'Millimeters')
    end
    object mmperrev: TEdit
      Left = 152
      Top = 88
      Width = 25
      Height = 21
      Enabled = False
      MaxLength = 2
      TabOrder = 2
      Text = '1'
    end
    object stepsperrev: TEdit
      Left = 152
      Top = 40
      Width = 25
      Height = 21
      MaxLength = 3
      TabOrder = 3
      Text = '200'
      OnKeyPress = stepsperrevKeyPress
    end
    object current: TEdit
      Left = 8
      Top = 136
      Width = 33
      Height = 21
      MaxLength = 4
      TabOrder = 4
      Text = '200'
      OnKeyPress = currentKeyPress
    end
    object idlecurrent: TEdit
      Left = 104
      Top = 136
      Width = 33
      Height = 21
      MaxLength = 4
      TabOrder = 5
      Text = '100'
      OnKeyPress = idlecurrentKeyPress
    end
    object accel: TEdit
      Left = 80
      Top = 168
      Width = 49
      Height = 21
      MaxLength = 5
      TabOrder = 6
      Text = '2000'
      OnKeyPress = accelKeyPress
    end
    object decel: TEdit
      Left = 80
      Top = 192
      Width = 49
      Height = 21
      MaxLength = 5
      TabOrder = 7
      Text = '2000'
      OnKeyPress = decelKeyPress
    end
    object velocity: TEdit
      Left = 80
      Top = 216
      Width = 49
      Height = 21
      MaxLength = 5
      TabOrder = 8
      Text = '200'
      OnKeyPress = velocityKeyPress
    end
    object reset_motor: TButton
      Left = 136
      Top = 240
      Width = 43
      Height = 25
      Caption = 'Reset'
      TabOrder = 9
      OnClick = reset_motorClick
    end
    object enable_motor: TCheckBox
      Left = 8
      Top = 248
      Width = 57
      Height = 17
      Caption = 'Enable'
      Checked = True
      State = cbChecked
      TabOrder = 10
      OnClick = enable_motorClick
    end
    object sleep_motor: TCheckBox
      Left = 72
      Top = 248
      Width = 57
      Height = 17
      Caption = 'Sleep'
      TabOrder = 11
      OnClick = sleep_motorClick
    end
  end
  object motorcontrol_box: TGroupBox
    Left = 8
    Top = 8
    Width = 185
    Height = 153
    Caption = 'Motor Control'
    TabOrder = 2
    object position_label: TLabel
      Left = 8
      Top = 20
      Width = 46
      Height = 13
      Caption = 'Position : '
    end
    object position_unit_label: TLabel
      Left = 104
      Top = 20
      Width = 25
      Height = 13
      Caption = 'steps'
    end
    object move_label: TLabel
      Left = 8
      Top = 44
      Width = 33
      Height = 13
      Caption = 'Move :'
    end
    object move_unit_label: TLabel
      Left = 104
      Top = 44
      Width = 25
      Height = 13
      Caption = 'steps'
    end
    object deg0_label: TLabel
      Left = 16
      Top = 104
      Width = 10
      Height = 13
      Caption = '0°'
    end
    object deg360_label: TLabel
      Left = 156
      Top = 104
      Width = 22
      Height = 13
      Caption = '360°'
    end
    object deg180_label: TLabel
      Left = 83
      Top = 104
      Width = 22
      Height = 13
      Caption = '180°'
    end
    object deg90_label: TLabel
      Left = 50
      Top = 104
      Width = 16
      Height = 13
      Caption = '90°'
    end
    object deg270_label: TLabel
      Left = 120
      Top = 104
      Width = 22
      Height = 13
      Caption = '270°'
    end
    object position: TEdit
      Left = 56
      Top = 16
      Width = 41
      Height = 21
      MaxLength = 6
      ReadOnly = True
      TabOrder = 0
      Text = '0'
    end
    object set_position: TButton
      Left = 136
      Top = 16
      Width = 43
      Height = 21
      Caption = 'Set'
      TabOrder = 1
      OnClick = set_positionClick
    end
    object stop: TButton
      Left = 8
      Top = 120
      Width = 75
      Height = 25
      Caption = 'Stop'
      TabOrder = 2
      OnClick = stopClick
    end
    object brake: TButton
      Left = 104
      Top = 120
      Width = 75
      Height = 25
      Caption = 'Brake'
      TabOrder = 3
      OnClick = brakeClick
    end
    object move: TEdit
      Left = 56
      Top = 40
      Width = 41
      Height = 21
      MaxLength = 6
      TabOrder = 4
      Text = '0'
      OnKeyPress = moveKeyPress
    end
    object go: TButton
      Left = 136
      Top = 40
      Width = 43
      Height = 21
      Caption = 'Go To'
      TabOrder = 5
      OnClick = goClick
    end
    object rotation: TTrackBar
      Left = 8
      Top = 72
      Width = 169
      Height = 33
      Max = 359
      Orientation = trHorizontal
      Frequency = 45
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 6
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = rotationChange
    end
  end
  object canbox: TGroupBox
    Left = 8
    Top = 448
    Width = 185
    Height = 81
    Caption = 'CAN Transmission'
    TabOrder = 3
    object canid_label: TLabel
      Left = 8
      Top = 24
      Width = 25
      Height = 13
      Caption = 'ID 0x'
    end
    object Label1: TLabel
      Left = 72
      Top = 24
      Width = 20
      Height = 13
      Caption = 'Size'
    end
    object candata_label: TLabel
      Left = 8
      Top = 50
      Width = 23
      Height = 13
      Caption = 'Data'
    end
    object canid: TEdit
      Left = 36
      Top = 21
      Width = 25
      Height = 21
      MaxLength = 3
      TabOrder = 0
      Text = '123'
    end
    object canrtr: TCheckBox
      Left = 136
      Top = 24
      Width = 41
      Height = 17
      Caption = 'RTR'
      TabOrder = 1
    end
    object cansize: TComboBox
      Left = 96
      Top = 21
      Width = 33
      Height = 21
      DropDownCount = 9
      ItemHeight = 13
      TabOrder = 2
      Text = '0'
      OnChange = cansizeChange
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8')
    end
    object cansend: TButton
      Left = 104
      Top = 48
      Width = 75
      Height = 22
      Caption = 'Send Msg'
      TabOrder = 3
      OnClick = cansendClick
    end
    object candata: TEdit
      Left = 36
      Top = 48
      Width = 61
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 4
      OnKeyUp = candataKeyUp
    end
  end
  object Button1: TButton
    Left = 8
    Top = 704
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 4
    OnClick = Button1Click
  end
  object position_timer: TTimer
    Interval = 250
    OnTimer = position_timerTimer
    Left = 88
    Top = 128
  end
end
