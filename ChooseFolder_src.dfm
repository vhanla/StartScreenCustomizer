object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Select the pictures for your slideshow'
  ClientHeight = 352
  ClientWidth = 553
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object rkSmartPath1: TrkSmartPath
    Left = 0
    Top = 0
    Width = 553
    Height = 25
    Align = alTop
    AllowEdit = False
    BtnGreyGrad1 = 15921906
    BtnGreyGrad2 = 14935011
    BtnNormGrad1 = 16643818
    BtnNormGrad2 = 16046502
    BtnHotGrad1 = 16643818
    BtnHotGrad2 = 16441260
    BtnPenGray = 9408399
    BtnPenNorm = 11632444
    BtnPenShade1 = 9598820
    BtnPenShade2 = 15388572
    BtnPenArrow = clBlack
    ComputerAsDefault = True
    DirMustExist = True
    EmptyPathIcon = -1
    EmptyPathText = 'Equipo'
    NewFolderName = 'NewFolder'
    ParentColor = False
    ParentBackground = False
    Path = 'C:\Users\vhanla\Documents\'
    SpecialFolders = [spDesktop, spDocuments]
    TabOrder = 0
    OnPathChanged = rkSmartPath1PathChanged
  end
  object viewMain: TrkView
    Left = 145
    Top = 25
    Width = 408
    Height = 286
    Align = alClient
    ShowHint = True
    TabOrder = 1
    HotTracking = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    OnMouseDown = viewMainMouseDown
    OnSelecting = viewMainSelecting
    CellWidth = 0
    CellSelect = True
    Columns = ''
    ColorSel = 16750899
    OnCellPaint = viewMainCellPaint
    object Splitter1: TSplitter
      Left = 0
      Top = 0
      Height = 265
      ExplicitTop = 152
      ExplicitHeight = 100
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 311
    Width = 553
    Height = 41
    Align = alBottom
    TabOrder = 2
    object labInfo: TLabel
      Left = 24
      Top = 24
      Width = 3
      Height = 13
    end
    object labThumb: TLabel
      Left = 24
      Top = 6
      Width = 3
      Height = 13
    end
    object btnCancel: TButton
      Left = 464
      Top = 6
      Width = 75
      Height = 25
      Caption = '&Cancel'
      TabOrder = 0
      OnClick = btnCancelClick
    end
    object btnSave: TButton
      Left = 384
      Top = 6
      Width = 74
      Height = 25
      Caption = '&Save'
      TabOrder = 1
      OnClick = btnSaveClick
    end
  end
  object ListBox1: TListBox
    Left = 0
    Top = 25
    Width = 145
    Height = 286
    Align = alLeft
    ItemHeight = 13
    TabOrder = 3
  end
end
