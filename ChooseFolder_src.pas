unit ChooseFolder_src;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Classes, Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, rkView, rkSmartPath,
  ShlObj,Activex,ComObj,Jpeg, Math, CommCtrl, ShellApi, Vcl.StdCtrls,
  Vcl.ExtCtrls, rkIntegerList, inifiles;

const
  CM_UpdateView = WM_USER + 2102; // Custom Message...
  CM_Progress = WM_USER + 2112; // Custom Message...
  MinSize = 52;
  MaxSize = 256;
  ColorFormat: DWord = 24;
  IEIFLAG_ASYNC = $001; // ask the extractor if it supports ASYNC extract
  // (free threaded)
  IEIFLAG_CACHE = $002; // returned from the extractor if it does NOT cache
  // the thumbnail
  IEIFLAG_ASPECT = $004; // passed to the extractor to beg it to render to
  // the aspect ratio of the supplied rect
  IEIFLAG_OFFLINE = $008; // if the extractor shouldn't hit the net to get
  // any content needs for the rendering
  IEIFLAG_GLEAM = $010; // does the image have a gleam? this will be
  // returned if it does
  IEIFLAG_SCREEN = $020; // render as if for the screen  (this is exlusive
  // with IEIFLAG_ASPECT )
  IEIFLAG_ORIGSIZE = $040; // render to the approx size passed, but crop if
  // neccessary
  IEIFLAG_NOSTAMP = $080; // returned from the extractor if it does NOT want
  // an icon stamp on the thumbnail
  IEIFLAG_NOBORDER = $100; // returned from the extractor if it does NOT want
  // an a border around the thumbnail
  IEIFLAG_QUALITY = $200; // passed to the Extract method to indicate that
  // a slower, higher quality image is desired,
  // re-compute the thumbnail

  SHIL_LARGE = $00; // The image size is normally 32x32 pixels. However, if the Use large icons option is selected from the Effects section of the Appearance tab in Display Properties, the image is 48x48 pixels.
  SHIL_SMALL = $01; // These images are the Shell standard small icon size of 16x16, but the size can be customized by the user.
  SHIL_EXTRALARGE = $02; // These images are the Shell standard extra-large icon size. This is typically 48x48, but the size can be customized by the user.
  SHIL_SYSSMALL = $03; // These images are the size specified by GetSystemMetrics called with SM_CXSMICON and GetSystemMetrics called with SM_CYSMICON.
  SHIL_JUMBO = $04; // Windows Vista and later. The image is normally 256x256 pixels.
  IID_IImageList: TGUID = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';
  SID_IExtractImage2 = '{953BB1EE-93B4-11D1-98A3-00C04FB687DA}';
  IID_IExtractImage2: TGUID = SID_IExtractImage2;

type
{$HPPEMIT 'DECLARE_DINTERFACE_TYPE_UUID("953BB1EE-93B4-11D1-98A3-00C04FB687DA", IExtractImage2)'}
  IRunnableTask = interface
    ['{85788D00-6807-11D0-B810-00C04FD706EC}']
    function Run: HResult; stdcall;
    function Kill(fWait: BOOL): HResult; stdcall;
    function Suspend: HResult; stdcall;
    function Resume: HResult; stdcall;
    function IsRunning: Longint; stdcall;
  end;

  IExtractImage = interface
    ['{BB2E617C-0920-11d1-9A0B-00C04FC2D6C1}']
    function GetLocation(pszwPathBuffer: PWideChar; cch: DWord;
      var dwPriority: DWord; var rgSize: TSize; dwRecClrDepth: DWord;
      var dwFlags: DWord): HResult; stdcall;
    function Extract(var hBmpThumb: HBITMAP): HResult; stdcall;
  end;

  IExtractImage2 = interface(IExtractImage)
    [SID_IExtractImage2]
    function GetDateStamp(var pDateStamp: TFileTime): HResult; stdcall;
  end;

  PCacheItem = ^TCacheItem;

  TCacheItem = record
    Idx: Integer;
    Size: Integer;
    Age: TDateTime;
    Scale: Integer;
    Bmp: TBitmap;
  end;

  PItemData = ^TItemData;

  TItemData = record
    Name: string;
    ThumbWidth: Word;
    ThumbHeight: Word;
    Size: Integer;
    Modified: TDateTime;
    Dir: Boolean;
    GotThumb: Boolean;
    IWidth, IHeight: Word;
    ImgIdx: Integer;
    IsIcon: Boolean;
    ImgState: Byte;
    Image: TObject;
  end;

  ThumbThread = class(TThread)
  private
    { Private declarations }
    ViewLink: TrkView;
    ItemsLink: TList;
  protected
    procedure Execute; override;
  public
    constructor Create(View: TrkView; Items: TList);
  end;

  TfrmMain = class(TForm)
    rkSmartPath1: TrkSmartPath;
    viewMain: TrkView;
    Panel1: TPanel;
    labInfo: TLabel;
    labThumb: TLabel;
    ListBox1: TListBox;
    Splitter1: TSplitter;
    btnSave: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure GenCellColors;
    procedure FormDestroy(Sender: TObject);

    procedure UpdateStatus;
    procedure BiResample(Src, Dest: TBitmap; Sharpen: Boolean);
    procedure OpenDir;
    procedure CMProgress(var message: TMessage); message CM_Progress;
    procedure CMUpdateView(var message: TMessage); message CM_UpdateView;
    procedure ItemPaintBasic(Canvas: TCanvas; R: TRect; State: TsvItemState);
    function Running: Boolean;
    procedure Start;
    procedure Stop;
    procedure DoSort;
    procedure viewMainSelecting(Sender: TObject; Count: Integer);
    procedure viewMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure viewMainCellPaint(Sender: TObject; Canvas: TCanvas; Cell: TRect;
      IdxA, Idx: Integer; State: TsvItemState);
    procedure rkSmartPath1PathChanged(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
    Items: TList;
    ThumbSizeW, ThumbSizeH: Integer;
    FhImageList48: Cardinal;
    FIconSize: Integer;
    procedure SetThumbSize(Value: Integer; UpdateTrackbar: Boolean);
    function ThumbBmp(Idx: Integer): TBitmap;
    procedure ClearThumbs;
    procedure ClearThumbsPool;
  protected
    ThumbThr: ThumbThread;
    ThreadDone: Boolean;
  public
    { Public declarations }
    Directory: string;
        // Colors
    cGSelectedStart, cGSelectedEnd, cGHotStart, cGHotEnd, cGDisabledStart,
      cGDisabledEnd, cGHeaderStart, cGHeaderEnd, cGHeaderHotStart,
      cGHeaderHotEnd, cGHeaderSelStart, cGHeaderSelEnd, cHot, cSelected,
      cDisabled, cBackground, cLineHighLight: TColor;
    cShadeSelect: TColor;
    cShadeDisabled: TColor;
    CellShade0: TColor;
    CellShade1: TColor;
    CellShade2: TColor;
    CellShade3: TColor;
    CellShade4: TColor;
    CellBkgColor: TColor;
    CellBrdColor: array [Boolean, Boolean] of TColor;
  end;

var
  frmMain: TfrmMain;
  CellJpeg: TJpegImage;
  WI, HI, TW, TH, HSX, vIdx: Integer;
  CellScale: Integer;
  CellStyle: Integer;
  ThumbsPool: TList;
  PoolSize, MaxPool: Integer;
  dummy: String;
implementation
uses modernuistartscreen_src;
{$R *.dfm}
procedure HackAlpha(ABitmap: TBitmap; Color: TColor);
// Fast alpha remove hack... bitmap must be 32bit
type
  PRGB32 = ^TRGB32;

  TRGB32 = record
    B, G, R, A: Byte;
  end;

  PPixel32 = ^TPixel32;
  TPixel32 = array [0 .. 0] of TRGB32;
var
  Row: PPixel32;
  X, Y, slMain, slSize: Integer;
  R, G, B: Byte;
  c: Integer;
begin
  ABitmap.PixelFormat := pf32bit;
  c := ColorToRGB(Color);
  R := Byte(c);
  G := Byte(c shr 8);
  B := Byte(c shr 16);
  slMain := Integer(ABitmap.ScanLine[0]);
  slSize := Integer(ABitmap.ScanLine[1]) - slMain;
  for Y := 0 to ABitmap.Height - 1 do
  begin
    Row := PPixel32(slMain);
    for X := 0 to ABitmap.Width - 1 do
    begin
      Row[X].R := Row[X].A * (Row[X].R - R) shr 8 + R;
      Row[X].G := Row[X].A * (Row[X].G - G) shr 8 + G;
      Row[X].B := Row[X].A * (Row[X].B - B) shr 8 + B;
    end;
    slMain := slMain + slSize;
  end;
end;

function HackIconSize(ABitmap: TBitmap): TPoint;
// Fast iconsize hack... bitmap must be 32bit
type
  PPixel32 = ^TPixel32;
  TPixel32 = array [0 .. 0] of Cardinal;
var
  Row: PPixel32;
  X, Y, i, j, slMain, slSize: Integer;
begin
  ABitmap.PixelFormat := pf32bit;
  Result.X := ABitmap.Width;
  Result.Y := ABitmap.Height;
  if (Result.X < 1) or (Result.Y < 1) then
    Exit;
  slMain := Integer(ABitmap.ScanLine[0]);
  slSize := Integer(ABitmap.ScanLine[1]) - slMain;
  Result.X := 0;
  Result.Y := 0;
  for Y := 0 to ABitmap.Height - 1 do
  begin
    Row := PPixel32(slMain);
    for X := 0 to ABitmap.Width - 1 do
    begin
      if (Row[X] and $FF000000) <> 0 then
      begin
        if X > Result.X then
          Result.X := X;
        if Y > Result.Y then
          Result.Y := Y;
      end;
    end;
    slMain := slMain + slSize;
  end;
  i := Max(Result.X, Result.Y);
  j := 0;
  while i > j do
    j := j + 8;
  if j > 256 then
    j := 256;
  Result.X := j;
  Result.Y := Result.X;
end;

function GetImageListSH(SHIL_FLAG: Cardinal): HIMAGELIST;
type
  _SHGetImageList = function(iImageList: Integer; const riid: TGUID;
    var ppv: Pointer): HResult; stdcall;
var
  Handle: THandle;
  SHGetImageList: _SHGetImageList;
begin
  Result := 0;
  Handle := LoadLibrary('Shell32.dll');
  if Handle <> S_OK then
    try
      SHGetImageList := GetProcAddress(Handle, PChar(727));
      if Assigned(SHGetImageList) and (Win32Platform = VER_PLATFORM_WIN32_NT)
        then
        SHGetImageList(SHIL_FLAG, IID_IImageList, Pointer(Result));
    finally
      FreeLibrary(Handle);
    end;
end;


procedure GraphicToBitmap(const Src: Graphics.TGraphic;
  const Dest: Graphics.TBitmap; const TransparentColor: Graphics.TColor);
{ Copies a graphic object to a bitmap, which is set to the same size as the source object. }
{ If the source graphic is transparent then the bitmap is set to transparent and, if TransparentColor is not clNone, it is used as the bitmap's transparent colour. }
{ TransparentColor is ignored if the source is not transparent. }
var
  Crop: TPoint;
begin
  // Do nothing if either source or destination are nil
  if not Assigned(Src) or not Assigned(Dest) then
    Exit;

  if (Src.Width = 0) or (Src.Height = 0) then
    Exit;
  // Size the bitmap
  Dest.Width := Src.Width;
  Dest.Height := Src.Height;
  if Src.Transparent then
  begin
    // Source graphic is transparent, make bitmap behave transparently
    Dest.Transparent := true;
    if (TransparentColor <> Graphics.clNone) then
    begin
      // Set destination as transparent using required colour key
      Dest.TransparentColor := TransparentColor;
      Dest.TransparentMode := Graphics.tmFixed;
      // Set background colour of bitmap to transparent colour
      Dest.Canvas.Brush.Color := TransparentColor;
    end
    else
      // No transparent colour: set transparency to automatic
      Dest.TransparentMode := Graphics.tmAuto;
  end;
  // Clear bitmap to required background colour and draw bitmap
  Dest.Canvas.FillRect(Classes.Rect(0, 0, Dest.Width, Dest.Height));
  Dest.Canvas.Draw(0, 0, Src);
  Crop := HackIconSize(Dest);
  Dest.Width := Crop.X;
  Dest.Height := Crop.Y;
end;
{ ThumbThread }

constructor ThumbThread.Create(View: TrkView; Items: TList);
begin
  ViewLink := View;
  ItemsLink := Items;
  FreeOnTerminate := False;
  inherited Create(False);
  Priority := tpLower;
end;

procedure GetIconFromFile(aFile: string; var aIcon: TIcon; SHIL_FLAG: Cardinal);
var
  aImgList: HIMAGELIST;
  SFI: TSHFileInfo;
  aIndex: Integer;
begin // Get the index of the imagelist
  SHGetFileInfo(PChar(aFile), FILE_ATTRIBUTE_NORMAL, SFI, SizeOf(TSHFileInfo),
    SHGFI_ICON or { SHGFI_LARGEICON or } SHGFI_SHELLICONSIZE or
      SHGFI_SYSICONINDEX or SHGFI_TYPENAME or SHGFI_DISPLAYNAME);
  if not Assigned(aIcon) then
    aIcon := TIcon.Create;
  aImgList := GetImageListSH(SHIL_FLAG); // get the imagelist
  aIndex := SFI.iIcon; // get index
  // OBS! Use ILD_IMAGE since ILD_NORMAL gives bad result in Windows 7
  aIcon.Handle := ImageList_GetIcon(aImgList, aIndex, ILD_IMAGE);
end;

procedure ThumbThread.Execute;
var
  Cnt, i: Integer;
  PThumb: PItemData;
  Old: Integer;
  InView: Integer;
  ShellFolder, DesktopShellFolder: IShellFolder;
  XtractImage: IExtractImage;
  XtractImage2: IExtractImage2;
  XtractIcon: IExtractIcon;
  fileShellItemImage: IShellItemImageFactory;
  ImageFactory: IShellItemImageFactory;
  Bmp: TBitmap;
  Path: string;
  Eaten: DWord;
  PIDL: PItemIDList;
  RunnableTask: IRunnableTask;
  Flags: DWord;
  Buf: array [0 .. MAX_PATH * 4] of WideChar;
  BmpHandle: HBITMAP;
  Atribute, Priority: DWord;
  GetLocationRes: HResult;
  ThumbJPEG: TJpegImage;
  MS: TMemoryStream;
  ASize: TSize;
  FName: string;
  p, pro: Integer;
  PV: Single;
  IIdx: Integer;
  IFlags: Cardinal;
  SIcon, LIcon: HIcon;
  IconS, IconL: TIcon;
  Done: Boolean;
  Res: HResult;
  Colordepth: Cardinal;
  IsVistaOrLater: Boolean;
begin
  inherited;
  if (ViewLink.Items.Count = 0) then
    Exit;

  IsVistaOrLater := CheckWin32Version(6);

  CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE);
  try
    ThumbJPEG := TJpegImage.Create;
    ThumbJPEG.CompressionQuality := 80;
    ThumbJPEG.Performance := jpBestSpeed;
    Path := frmMain.Directory;

    OleCheck(SHGetDesktopFolder(DesktopShellFolder));
    OleCheck(DesktopShellFolder.ParseDisplayName(0, nil, StringToOleStr(Path),
        Eaten, PIDL, Atribute));
    OleCheck(DesktopShellFolder.BindToObject(PIDL, nil, IID_IShellFolder,
        Pointer(ShellFolder)));
    CoTaskMemFree(PIDL);

    Cnt := 0;
    Old := ViewLink.ViewIdx;
    pro := 0;
    PV := 100 / ViewLink.Items.Count;
    repeat
      while (not Terminated) and (Cnt < ViewLink.Items.Count) do
      begin
        if Old <> ViewLink.ViewIdx then
        begin
          Cnt := ViewLink.ViewIdx - 1;
          if Cnt = -1 then
            Cnt := 0;
          Old := ViewLink.ViewIdx;
        end;

        PThumb := PItemData(ItemsLink.Items[ViewLink.Items[Cnt]]);
        Done := PThumb.GotThumb;
        PThumb.ImgState := 0;

        if IsVistaOrLater then
        begin
          if not Done then
          begin
            Bmp := TBitmap.Create;
            Bmp.Canvas.Lock;
            FName := Path + PThumb.Name;
            Res := SHCreateItemFromParsingName(PChar(FName), nil,
              IShellItemImageFactory, fileShellItemImage);
            if Succeeded(Res) then
            begin
              ASize.cx := 256;
              ASize.cy := 256;
              Res := fileShellItemImage.GetImage(ASize, SIIGBF_THUMBNAILONLY,
                BmpHandle);
              if Succeeded(Res) then
              begin
                Bmp.Canvas.UnLock;
                Bmp.Handle := BmpHandle;
                Bmp.Canvas.Lock;
                HackAlpha(Bmp, clWhite);
                PThumb.IsIcon := False;
                Done := true;
              end;
            end;
          end;
        end
        else
        begin
          if not Done then
          begin
            Bmp := TBitmap.Create;
            Bmp.Canvas.Lock;
            OleCheck(ShellFolder.ParseDisplayName(0, nil,
                StringToOleStr(PThumb.Name), Eaten, PIDL, Atribute));
            ShellFolder.GetUIObjectOf(0, 1, PIDL, IExtractImage, nil,
              XtractImage);
            CoTaskMemFree(PIDL);
            if Assigned(XtractImage) then
            begin
              if XtractImage.QueryInterface(IID_IExtractImage2,
                Pointer(XtractImage2)) <> E_NOINTERFACE then
              else
                XtractImage2 := nil;
              RunnableTask := nil;
              ASize.cx := 256;
              ASize.cy := 256;
              Priority := 0;
              Flags :=
                IEIFLAG_SCREEN or IEIFLAG_OFFLINE or IEIFLAG_ORIGSIZE
                or IEIFLAG_QUALITY;
              Colordepth := 32;
              GetLocationRes := XtractImage.GetLocation(Buf, MAX_PATH,
                Priority, ASize, Colordepth, Flags);
              if (GetLocationRes = NOERROR) or (GetLocationRes = E_PENDING) then
              begin
                if GetLocationRes = E_PENDING then
                  if XtractImage.QueryInterface(IRunnableTask, RunnableTask)
                    <> S_OK then
                    RunnableTask := nil;
                try
                  if Succeeded(XtractImage.Extract(BmpHandle)) then
                  begin
                    Bmp.Canvas.UnLock;
                    Bmp.Handle := BmpHandle;
                    Bmp.Canvas.Lock;
                    HackAlpha(Bmp, clWhite);
                    PThumb.IsIcon := False;
                    Done := true;
                  end;
                except
                  on E: EOleSysError do
                    OutputDebugString
                      (PChar(string(E.ClassName) + ': ' + E.message))
                  else
                    raise ;
                end; // try/except
              end;
            end;
          end;
        end;

        if (not Done) and (not IsVistaOrLater) then // we did not get a thumbnail, try getting a icon
        begin
          OleCheck(ShellFolder.ParseDisplayName(0, nil,
              StringToOleStr(PThumb.Name), Eaten, PIDL, Atribute));
          ShellFolder.GetUIObjectOf(0, 1, PIDL, IExtractIcon, nil, XtractIcon);
          CoTaskMemFree(PIDL);
          if Assigned(XtractIcon) then
          begin
            GetLocationRes := XtractIcon.GetIconLocation(GIL_FORSHELL, @Buf,
              SizeOf(Buf), IIdx, IFlags);
            if (GetLocationRes = NOERROR) or (GetLocationRes = E_PENDING) then
            begin
              try
                OleCheck(XtractIcon.Extract(@Buf, IIdx, LIcon, SIcon,
                    256 + (48 shl 16)));
                if (LIcon <> 0) then
                begin
                  IconL := TIcon.Create;
                  try
                    IconL.Handle := LIcon;
                    if (IconL.Width > 32) then
                    begin
                      Bmp.Canvas.Lock;
                      GraphicToBitmap(IconL, Bmp, clNone);
                      PThumb.IsIcon := true;
                      if Bmp.Width >= 248 then
                        PThumb.ImgState := 1;
                      Done := true;
                    end;
                  finally
                    IconL.Free;
                  end;
                end;
                if (SIcon <> 0) then
                begin
                  IconS := TIcon.Create;
                  try
                    IconS.Handle := SIcon;
                    if (IconS.Width > 32) and (not Done) then
                    begin
                      Bmp.Canvas.Lock;
                      GraphicToBitmap(IconS, Bmp, clNone);
                      PThumb.IsIcon := true;
                      if Bmp.Width >= 248 then
                        PThumb.ImgState := 1;
                      Done := true;
                    end;
                  finally
                    IconS.Free;
                  end;
                end;
                if Done then
                begin

                end;
              except
                on E: EOleSysError do
                  OutputDebugString
                    (PChar(string(E.ClassName) + ': ' + E.message))
                else
                  raise ;
              end; // try/except
            end;
          end;
        end;

        if not Done then
        begin
          IconL := TIcon.Create;
          try
            FName := Path + PThumb.Name;
            GetIconFromFile(FName, IconL, SHIL_JUMBO);
            Bmp.Canvas.Lock;
            GraphicToBitmap(IconL, Bmp, clNone);
            Done := true;
            PThumb.IsIcon := true;
            if Bmp.Width >= 248 then
              PThumb.ImgState := 1;
          finally
            IconL.Free;
          end;
        end;

        if Done and not Terminated then
        begin
          if (Bmp <> nil) then
          begin
            if (Bmp.Width > 0) and (Bmp.Height > 0) then
            begin
              ThumbJPEG.Assign(Bmp);
              ThumbJPEG.Compress;
              MS := TMemoryStream.Create;
              MS.Position := 0;
              try
                ThumbJPEG.SaveToStream(MS);
                PThumb.Image := MS;
              except
                MS.Free;
                raise ;
              end;
            end;
            PThumb.ThumbWidth := Bmp.Width;
            PThumb.ThumbHeight := Bmp.Height;
            PThumb.GotThumb := true;
          end;
        end
        else
          PThumb.Image := nil;

        if Assigned(Bmp) then
        begin
          Bmp.Canvas.UnLock;
          FreeAndNil(Bmp);
        end;

        if (Done) and (not Terminated) then
        begin
          InView := ViewLink.ViewIdx +
            (ViewLink.ViewColumns * (ViewLink.ViewRows));
          if (Cnt >= ViewLink.ViewIdx) and (Cnt <= InView) then
            PostMessage(frmMain.Handle, CM_UpdateView, 0, 0);
          if (Cnt = 0) then
            p := 0
          else
            p := Round(PV * Cnt);
          if (pro <> p) then
          begin
            PostMessage(frmMain.Handle, CM_Progress, 0, p);
            pro := p;
          end;
        end;
        inc(Cnt);
      end;

      Cnt := 0;
      for i := 0 to ViewLink.Items.Count - 1 do
        if not PItemData(ItemsLink.Items[i]).GotThumb then
          inc(Cnt);
    until (Cnt = 0) or (Terminated);

    if not Terminated then
      PostMessage(frmMain.Handle, CM_UpdateView, 0, 0);

    PostMessage(frmMain.Handle, CM_Progress, 0, 100);
    ThumbJPEG.Free;
  finally
    CoUninitialize;
  end;
end;
procedure TfrmMain.FormCreate(Sender: TObject);
var
  hImagList16, hImagList32: Cardinal;
  ShInfo1: TSHFileInfo;
  icHgt, icWid: Integer;
begin
  viewMain.MultipleSelection:=True;

  hImagList32 := SHGetFileInfo('file.txt', FILE_ATTRIBUTE_NORMAL, ShInfo1,
    SizeOf(ShInfo1),
    SHGFI_LARGEICON or SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);

  hImagList16 := SHGetFileInfo('file.txt', FILE_ATTRIBUTE_NORMAL, ShInfo1,
    SizeOf(ShInfo1),
    SHGFI_SMALLICON or SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);

  FhImageList48 := hImagList16 + (hImagList16 - hImagList32);
  if ImageList_GetIconSize(FhImageList48, icHgt, icWid) and (icHgt = 48) then
    FIconSize := 48
  else
  begin
    FhImageList48 := hImagList32;
    if ImageList_GetIconSize(hImagList32, icHgt, icWid) then
      FIconSize := icHgt
    else
      FIconSize := 32;
  end;

  Items := TList.Create;
  // Max thumbnail size...
  ThumbSizeW := 255;
  ThumbSizeH := 255;
  viewMain.CellWidth := ThumbSizeW + 20;
  viewMain.CellHeight := ThumbSizeH + 40;
  CellJpeg := TJpegImage.Create;
  CellJpeg.Performance := jpBestSpeed;
  GenCellColors;
  CellStyle := -1;
  PoolSize := 0;
  MaxPool := Round(((Screen.Width * Screen.Height) * 3) * 1.5);
  Items := TList.Create;
  ThumbsPool := TList.Create;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  i: Integer;
  Item: PItemData;
begin
  CellJpeg.Free;
  for i := Items.Count - 1 downto 0 do
  begin
    Item := Items[i];
    if Item.Size <> 0 then
      Item.Image.Free;
    Dispose(Item);
  end;
  ThumbsPool.Free;
  Items.Free;
end;

function BytesToStr(const i64Size: Int64): string;
const
  i64GB = 1024 * 1024 * 1024;
  i64MB = 1024 * 1024;
  i64KB = 1024;
begin
  if i64Size div i64GB > 0 then
    Result := Format('%.1f GB', [i64Size / i64GB])
  else if i64Size div i64MB > 0 then
    Result := Format('%.2f MB', [i64Size / i64MB])
  else if i64Size div i64KB > 0 then
    Result := Format('%.0f kB', [i64Size / i64KB])
  else
    Result := IntToStr(i64Size) + ' byte';
end;

procedure TfrmMain.UpdateStatus;
var
  i: Integer;
  n: Int64;
begin
  n := 0;
  ListBox1.Clear;
  for i := 0 to viewMain.Selection.Count - 1 do
  begin
    n := n + PItemData(Items[viewMain.Selection[i]]).Size;
    ListBox1.Items.Add( PItemData(Items[viewMain.Selection[i]]).Name );
  end;
  labInfo.Caption := IntToStr(viewMain.Items.Count) + ' items, ' + IntToStr
    (viewMain.Selection.Count) + ' selected (' + BytesToStr(n) + ')';
end;

function CalcThumbSize(W, H, TW, TH: Cardinal): Cardinal;
begin
  Result := 0;
  if (W = 0) or (H = 0) then
    Exit;
  if (W < TW) and (H < TH) then
    Result := (W shl 16) + H
  else
  begin
    if W > H then
    begin
      if W < TW then
        TW := W;
      Result := (TW shl 16) + Trunc(TW * H / W);
      if (Result and $FFFF) > TH then
        Result := (Trunc(TH * W / H) shl 16) + TH;
    end
    else
    begin
      if H < TH then
        TH := H;
      Result := (Trunc(TH * W / H) shl 16) + TH;
      if ((Result shr 16) and $FFFF) > TW then
        Result := (TW shl 16) + Trunc(TW * H / W);
    end;
  end;
end;

procedure TfrmMain.viewMainCellPaint(Sender: TObject; Canvas: TCanvas;
  Cell: TRect; IdxA, Idx: Integer; State: TsvItemState);
var
  X, Y: Integer;
  f, s: Boolean;
  R: TRect;
  TW, TH: Integer;
  Txt: string;
  Item: PItemData;
  c: Cardinal;
begin
  Item := PItemData(Items[Idx]);
  if (Item.ImgIdx <> -1) and (Item.Image = nil) then
    c := CalcThumbSize(FIconSize, FIconSize, CellScale, CellScale)
  else
    c := CalcThumbSize(Item.ThumbWidth, Item.ThumbHeight, CellScale, CellScale);
  TW := c shr 16;
  TH := c and $FFFF;
  ItemPaintBasic(Canvas, Cell, State);
  f := viewMain.Focused;
  s := State = svSelected;

  X := Cell.Left + ((Cell.Right - (Cell.Left + TW)) shr 1);
  if Item.IsIcon then
    Y := Cell.Top + ((Cell.Right - (Cell.Left + TW)) shr 1)
  else
    Y := (Cell.Bottom - TH) - 21;

  if (Item.IsIcon) and (Item.ImgState = 0) then
  begin
    R := Cell;
    R.Bottom := R.Bottom - 16;
    InflateRect(R, -5, -5);
    Canvas.Pen.Color := CellBrdColor[f, s];
    Canvas.Brush.Color := clWhite;
    Canvas.Brush.Style := bsSolid;
    Canvas.Rectangle(R);
    Canvas.Brush.Style := bsClear;
  end;

  if (Item.Image <> nil) and (Item.GotThumb) then
    Canvas.Draw(X, Y, ThumbBmp(Idx))
  else
    ImageList_Draw(FhImageList48, Item.ImgIdx, Canvas.Handle, X, Y,
      ILD_TRANSPARENT);

  if (not Item.IsIcon) and (not Item.Dir) then
  begin
    R.Left := X;
    R.Top := Y;
    R.Right := X + TW;
    R.Bottom := Y + TH;
    Canvas.Pen.Color := CellBrdColor[f, s];
    InflateRect(R, 2, 2);
    Canvas.Rectangle(R);
    Canvas.Pen.Color := clWhite;
    InflateRect(R, -1, -1);
    Canvas.Rectangle(R);
  end;

  Canvas.Font.Color := clBlack;
  R := Cell;
  R.Top := R.Bottom - (16);
  Txt := Item.Name;
  DrawText(Canvas.Handle, PChar(Txt), Length(Txt), R,
    DT_END_ELLIPSIS or DT_SINGLELINE or DT_NOPREFIX or DT_CENTER);
end;



procedure TfrmMain.viewMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  Thumb: PItemData;
begin
  vIdx := viewMain.ViewIdx;
  i := viewMain.ItemAtXY(Point(X, Y), False);
  if i <> -1 then
  begin
    Thumb := Items[viewMain.Items[i]];
    labThumb.Caption := Thumb.Name;
  end
  else
    labThumb.Caption := '';
end;

procedure TfrmMain.viewMainSelecting(Sender: TObject; Count: Integer);
begin
  UpdateStatus;
end;

procedure TfrmMain.BiResample(Src, Dest: TBitmap; Sharpen: Boolean);
// Fast bilinear resampling procedure found at Swiss Delphi Center + my mods...
type
  PRGB24 = ^TRGB24;

  TRGB24 = record
    B, G, R: Byte;
  end;

  PRGBArray = ^TRGBArray;
  TRGBArray = array [0 .. 0] of TRGB24;
var
  X, Y, px, py: Integer;
  i, x1, x2, z, z2, iz2: Integer;
  w1, w2, w3, w4: Integer;
  Ratio: Integer;
  sDst, sDstOff: Integer;
  sScanLine: array [0 .. 255] of PRGBArray;
  Src1, Src2: PRGBArray;
  c, C1, C2: TRGB24;
  y1, y2, y3, x3, iRed, iGrn, iBlu: Integer;
  p1, p2, p3, p4, p5: PRGB24;
begin
  // ScanLine buffer for Source
  sDst := Integer(Src.ScanLine[0]);
  sDstOff := Integer(Src.ScanLine[1]) - sDst;
  for i := 0 to Src.Height - 1 do
  begin
    sScanLine[i] := PRGBArray(sDst);
    sDst := sDst + sDstOff;
  end;
  // ScanLine for Destiantion
  sDst := Integer(Dest.ScanLine[0]);
  y1 := sDst; // only for sharpening...
  sDstOff := Integer(Dest.ScanLine[1]) - sDst;
  // Ratio is same for width and height
  Ratio := ((Src.Width - 1) shl 15) div Dest.Width;
  py := 0;
  for Y := 0 to Dest.Height - 1 do
  begin
    i := py shr 15;
    if i > Src.Height - 1 then
      i := Src.Height - 1;
    Src1 := sScanLine[i];
    if i < Src.Height - 1 then
      Src2 := sScanLine[i + 1]
    else
      Src2 := Src1;
    z2 := py and $7FFF;
    iz2 := $8000 - z2;
    px := 0;
    for X := 0 to Dest.Width - 1 do
    begin
      x1 := px shr 15;
      x2 := x1 + 1;
      C1 := Src1[x1];
      C2 := Src2[x1];
      z := px and $7FFF;
      w2 := (z * iz2) shr 15;
      w1 := iz2 - w2;
      w4 := (z * z2) shr 15;
      w3 := z2 - w4;
      c.R := (C1.R * w1 + Src1[x2].R * w2 + C2.R * w3 + Src2[x2].R * w4) shr 15;
      c.G := (C1.G * w1 + Src1[x2].G * w2 + C2.G * w3 + Src2[x2].G * w4) shr 15;
      c.B := (C1.B * w1 + Src2[x2].B * w2 + C2.B * w3 + Src2[x2].B * w4) shr 15;
      // Set destination pixel
      PRGBArray(sDst)[X] := c;
      inc(px, Ratio);
    end;
    sDst := sDst + sDstOff;
    inc(py, Ratio);
  end;

  Exit; // Remove this to enable sharpening

  // Sharpening...
  y2 := y1 + sDstOff;
  y3 := y2 + sDstOff;
  for Y := 1 to Dest.Height - 2 do
  begin
    for X := 0 to Dest.Width - 3 do
    begin
      x1 := X * 3;
      x2 := x1 + 3;
      x3 := x1 + 6;
      p1 := PRGB24(y1 + x1);
      p2 := PRGB24(y1 + x3);
      p3 := PRGB24(y2 + x2);
      p4 := PRGB24(y3 + x1);
      p5 := PRGB24(y3 + x3);
      // -15 -11                       // -17 - 13
      iRed := (p1.R + p2.R + (p3.R * -15) + p4.R + p5.R) div -11;
      iGrn := (p1.G + p2.G + (p3.G * -15) + p4.G + p5.G) div -11;
      iBlu := (p1.B + p2.B + (p3.B * -15) + p4.B + p5.B) div -11;
      if iRed < 0 then
        iRed := 0
      else if iRed > 255 then
        iRed := 255;
      if iGrn < 0 then
        iGrn := 0
      else if iGrn > 255 then
        iGrn := 255;
      if iBlu < 0 then
        iBlu := 0
      else if iBlu > 255 then
        iBlu := 255;
      PRGB24(y2 + x2).R := iRed;
      PRGB24(y2 + x2).G := iGrn;
      PRGB24(y2 + x2).B := iBlu;
    end;
    inc(y1, sDstOff);
    inc(y2, sDstOff);
    inc(y3, sDstOff);
  end;
end;

procedure TfrmMain.OpenDir;
var
  Entry: PItemData;
  SR: TSearchRec;
  n: Integer;
  SFI: TSHFileInfo;
  FName: string;
begin
  Directory := rkSmartPath1.Path;
//  BrowseForFolder('Open folder', '', False);
  if Directory <> '' then
  begin
    Stop;
    ClearThumbs;
    ClearThumbsPool;
    viewMain.ViewIdx := -1;
    viewMain.Clear;
    viewMain.BeginUpdate;
    ///Forms.Application.ProcessMessages;
    if Directory[Length(Directory)] <> '\' then
      Directory := Directory + '\';
    if FindFirst(Directory + '*.*', faAnyFile { - faDirectory } , SR) = 0 then
    begin
      Items.Capacity := 1000;
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..')
        and FileExists(Directory+SR.Name)
        and (
          (UpperCase(ExtractFileExt(SR.Name))='.PNG')
          or (UpperCase(ExtractFileExt(SR.Name))='.JPG')
          or (UpperCase(ExtractFileExt(SR.Name))='.BMP')
          or (UpperCase(ExtractFileExt(SR.Name))='.GIF')
        )
        then
        begin
          New(Entry);
          Entry.Name := SR.Name;
          Entry.Size := SR.Size;
          Entry.Modified := FileDateToDateTime(SR.Time);
          Entry.IWidth := 0;
          Entry.IHeight := 0;
          Entry.ThumbWidth := 0;
          Entry.ThumbHeight := 0;
          Entry.Dir := ((SR.Attr and faDirectory) <> 0);
          Entry.GotThumb := False;
          Entry.Image := nil;
          FName := Directory + SR.Name;
          SHGetFileInfo(PChar(FName), FILE_ATTRIBUTE_NORMAL, SFI,
            SizeOf(TSHFileInfo), SHGFI_LARGEICON or SHGFI_SYSICONINDEX);
          Entry.ImgIdx := SFI.iIcon;
          n := Items.Add(Entry);
          if n <> -1 then
            viewMain.Items.Add(n);
        end;
      until FindNext(SR) <> 0;
      FindClose(SR);
      Items.Capacity := Items.Count;
    end;
  end;
  viewMain.EndUpdate;
  DoSort;
///  SetThumbSize(tbSize.Position, False);
  SetThumbSize(128,False);
  if ThumbThr = nil then
  begin
    ThreadDone := False;
    ThumbThr := ThumbThread.Create(viewMain, Items);
  end;
  UpdateStatus;
end;

procedure TfrmMain.rkSmartPath1PathChanged(Sender: TObject);
begin
  opendir;
end;

procedure TfrmMain.CMProgress(var message: TMessage);
begin
  if message.LParam = 100 then
    message.LParam := 0;
  // vprothumbs.Visible := message.LParam > 0;
  // vprothumbs.Position := message.LParam;
end;

procedure TfrmMain.CMUpdateView(var message: TMessage);
begin
  viewMain.Invalidate;
end;

procedure WinGradient(DC: HDC; ARect: TRect; AColor2, AColor1: TColor);
var
  Vertexs: array [0 .. 1] of TTriVertex;
  GRect: TGradientRect;
begin
  Vertexs[0].X := ARect.Left;
  Vertexs[0].Y := ARect.Top;
  Vertexs[0].Red := (AColor1 and $000000FF) shl 8;
  Vertexs[0].Green := (AColor1 and $0000FF00);
  Vertexs[0].Blue := (AColor1 and $00FF0000) shr 8;
  Vertexs[0].alpha := 0;
  Vertexs[1].X := ARect.Right;
  Vertexs[1].Y := ARect.Bottom;
  Vertexs[1].Red := (AColor2 and $000000FF) shl 8;
  Vertexs[1].Green := (AColor2 and $0000FF00);
  Vertexs[1].Blue := (AColor2 and $00FF0000) shr 8;
  Vertexs[1].alpha := 0;
  GRect.UpperLeft := 0;
  GRect.LowerRight := 1;
  GradientFill(DC, @Vertexs, 2, @GRect, 1, GRADIENT_FILL_RECT_V);
end;

procedure TfrmMain.ItemPaintBasic(Canvas: TCanvas; R: TRect;
  State: TsvItemState);
var
  c: TColor;
begin
  Canvas.Brush.Style := bsClear;
  if (State = svSelected) or (State = svHot) then
  begin
    if (viewMain.Focused) and (State = svSelected) then
    begin
      Canvas.Pen.Color := cSelected;
      WinGradient(Canvas.Handle, R, cGSelectedStart, cGSelectedEnd);
    end
    else if (State = svHot) then
    begin
      Canvas.Pen.Color := cHot;
      WinGradient(Canvas.Handle, R, cGHotStart, cGHotEnd);
    end
    else
    begin
      Canvas.Pen.Color := cDisabled;
      WinGradient(Canvas.Handle, R, cGDisabledStart, cGDisabledEnd);
    end;
    Canvas.Rectangle(R);
    if (viewMain.Focused) then
      c := cShadeSelect
    else
      c := cShadeDisabled;
    Canvas.Pen.Color := c;
    Canvas.MoveTo(R.Left + 1, R.Top + 2);
    Canvas.LineTo(R.Left + 1, R.Bottom - 2);
    Canvas.LineTo(R.Right - 2, R.Bottom - 2);
    Canvas.LineTo(R.Right - 2, R.Top + 1);
    Canvas.Pen.Style := psSolid;
    Canvas.Pixels[R.Left, R.Top] := c;
    Canvas.Pixels[R.Left, R.Bottom - 1] := c;
    Canvas.Pixels[R.Right - 1, R.Top] := c;
    Canvas.Pixels[R.Right - 1, R.Bottom - 1] := c;
  end;
end;

function TfrmMain.Running: Boolean;
begin
  Result := ThumbThr <> nil;
end;

procedure TfrmMain.Start;
begin
  if Running then
    Exit;
  ThreadDone := False;
  ThumbThr := ThumbThread.Create(viewMain, Items);
end;

procedure TfrmMain.Stop;
begin
  if ThumbThr <> nil then
  begin
    ThumbThr.Terminate;
    ThumbThr.WaitFor;
    ThumbThr.Free;
    ThumbThr := nil;
  end;
end;


function CompareNatural(s1, s2: string): Integer;
  function ExtractNr(n: Integer; var Txt: string): Int64;
  begin
    while (n <= Length(Txt)) and (Txt[n] >= '0') and (Txt[n] <= '9') do
      n := n + 1;
    Result := StrToInt64Def(Copy(Txt, 1, n - 1), 0);
    Delete(Txt, 1, (n - 1));
  end;

var
  B: Boolean;
begin
  Result := 0;
  s1 := LowerCase(s1);
  s2 := LowerCase(s2);
  if (s1 <> s2) and (s1 <> '') and (s2 <> '') then
  begin
    B := False;
    while (not B) do
    begin
      if ((s1[1] >= '0') and (s1[1] <= '9')) and
        ((s2[1] >= '0') and (s2[1] <= '9')) then
        Result := Sign(ExtractNr(1, s1) - ExtractNr(1, s2))
      else
        Result := Sign(Integer(s1[1]) - Integer(s2[1]));
      B := (Result <> 0) or (Min(Length(s1), Length(s2)) < 2);
      if not B then
      begin
        Delete(s1, 1, 1);
        Delete(s2, 1, 1);
      end;
    end;
  end;
  if Result = 0 then
  begin
    if (Length(s1) = 1) and (Length(s2) = 1) then
      Result := Sign(Integer(s1[1]) - Integer(s2[1]))
    else
      Result := Sign(Length(s1) - Length(s2));
  end;
end;


function SortItem(List: TIntList; Index1, Index2: Integer): Integer;
var
  Item1, Item2: PItemData;
begin
  Item1 := frmMain.Items[List[Index1]];
  Item2 := frmMain.Items[List[Index2]];
  if Item1.Dir and Item2.Dir then
    Result := CompareNatural(Item1.Name, Item2.Name)
  else if Item1.Dir then
    Result := -1
  else if Item2.Dir then
    Result := 1
  else
    Result := CompareNatural(Item1.Name, Item2.Name);
end;


procedure TfrmMain.DoSort;
begin
  viewMain.Items.CustomSort(SortItem);
  viewMain.UpdateView;
  viewMain.Invalidate;
end;

procedure TfrmMain.SetThumbSize(Value: Integer; UpdateTrackbar: Boolean);
var
  W, H: Integer;
begin
  case Value of
    32 .. 63:
      CellJpeg.Scale := jsQuarter;
    64 .. 127:
      CellJpeg.Scale := jsHalf;
    128 .. 255:
      CellJpeg.Scale := jsFullSize;
  else
    CellJpeg.Scale := jsEighth;
  end;
  W := Value + 10;
  H:= Value + 10 + 16;
  HSX := (W - 70) shr 1;
  viewMain.CellWidth := W;
  viewMain.CellHeight := H;
  CellScale := Value;
  if UpdateTrackbar then
  begin
    ///tbSize.OnChange := nil;
    ///tbSize.Position := CellScale;
    ///tbSize.OnChange := tbSizeChange;
  end;
  viewMain.CalcView(False);
  if not UpdateTrackbar then
    viewMain.SetAtTop(-1, vIdx);
end;


function TfrmMain.ThumbBmp(Idx: Integer): TBitmap;
var
  i, n, sf: Integer;
  p: PCacheItem;
  T: PItemData;
  Bmp, tmp: TBitmap;
  pt: TPoint;
  c: Cardinal;
  Oldest: TDateTime;
begin
  Result := nil;
  // if we have thumbs, see if we can find it...
  if ThumbsPool.Count > 0 then
  begin
    i := ThumbsPool.Count - 1;
    while (i >= 0) and (PCacheItem(ThumbsPool[i]).Idx <> Idx) do
      i := i - 1;
    if i <> -1 then
    begin
      p := ThumbsPool[i];
      if (p.Idx = Idx) then
      begin
        if (p.Scale = CellScale) then
        begin
          p.Age := Now;
          Result := p.Bmp
        end
        else
        begin
          PoolSize := PoolSize - p.Size;
          p.Bmp.Free;
          Dispose(p);
          ThumbsPool.Delete(i);
        end;
      end;
    end;
  end;
  // if we dont have a thumb, make one...
  if Result = nil then
  begin
    T := Items[Idx];
    if T.Image <> nil then
    begin
      TMemoryStream(T.Image).Position := 0;

      sf := Trunc(Min(T.ThumbWidth / CellScale, T.ThumbHeight / CellScale));
      if sf < 0 then
        sf := 0;
      case sf of
        0 .. 1:
          CellJpeg.Scale := jsFullSize;
        2 .. 3:
          CellJpeg.Scale := jsHalf;
        4 .. 7:
          CellJpeg.Scale := jsQuarter;
      else
        CellJpeg.Scale := jsEighth;
      end;
      CellJpeg.LoadFromStream(TMemoryStream(T.Image));

      Bmp := TBitmap.Create;
      Bmp.PixelFormat := pf24bit;
      c := CalcThumbSize(CellJpeg.Width, CellJpeg.Height, CellScale, CellScale);
      pt.X := c shr 16;
      pt.Y := c and $FFFF;
      if pt.X <> CellJpeg.Width then
      begin
        tmp := TBitmap.Create;
        tmp.PixelFormat := pf24bit;
        tmp.Width := CellJpeg.Width;
        tmp.Height := CellJpeg.Height;
        tmp.Canvas.Draw(0, 0, CellJpeg);
        Bmp.Width := pt.X;
        Bmp.Height := pt.Y;
        if (Bmp.Width > 4) and (Bmp.Height > 4) then
          BiResample(tmp, Bmp, False)
        else
          Bmp.Canvas.StretchDraw(Rect(0, 0, pt.X, pt.Y), tmp);
        tmp.Free;
      end
      else
      begin
        Bmp.Width := CellJpeg.Width;
        Bmp.Height := CellJpeg.Height;
        Bmp.Canvas.Draw(0, 0, CellJpeg);
      end;
      New(p);
      p.Idx := Idx;
      p.Size := (Bmp.Width * Bmp.Height) * 3;
      p.Age := Now;
      p.Scale := CellScale;
      p.Bmp := Bmp;
      ThumbsPool.Add(p);
      PoolSize := PoolSize + p.Size;
      Result := p.Bmp;
      // Purge thumbs if needed
      while (PoolSize > MaxPool) and (ThumbsPool.Count > 0) do
      begin
        Oldest := Now;
        n := 0;
        for i := 0 to ThumbsPool.Count - 1 do
        begin
          p := ThumbsPool[i];
          if p.Age <= Oldest then
          begin
            Oldest := p.Age;
            n := i;
          end;
        end;
        Assert(n >= 0);
        p := ThumbsPool[n];
        PoolSize := PoolSize - p.Size;
        p.Bmp.Free;
        Dispose(p);
        ThumbsPool.Delete(n);
      end;
    end;
  end;
end;

procedure TfrmMain.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
var
  list: string;
  I: Integer;
  ini: TMemIniFile;
begin
  if ListBox1.Items.Count > 1 then
  begin
    list:='';
    SlideshowList.Clear;
    list:=ListBox1.Items[0];
    SlideshowList.Add(ListBox1.Items[0]);
    for I := 1 to ListBox1.Items.Count-1 do
    begin
      list:=list+'*'+ListBox1.Items[I];
      SlideshowList.Add(ListBox1.Items[I]);
    end;
//    ShowMessage('These are the pictures you selected:'#13+list);
    //let's save that to our ini file
      ini:=TMemIniFile.Create(ConfigFilePath, TEncoding.UTF8);
      try
        ini.WriteString('Slideshow','Path',rkSmartPath1.Path);
        SlideshowPath:=rkSmartPath1.Path;
        ini.WriteString('Slideshow','Pictures',list);
      finally
        ini.UpdateFile;
        ini.Free;
      end;
    close;
  end
  else if ListBox1.Items.Count = 1 then
  begin
    //
    MessageDlg('You only selected one picture, that''s useless. Please choose at least two pictures.',mtInformation,[mbYes],0);

  end
  else
  begin
    //
    if MessageDlg('You didn''t select any picture. Continue?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
    close;
  end;

end;

procedure TfrmMain.ClearThumbs;
var
  i: Integer;
  Item: PItemData;
begin
  viewMain.Items.Clear;
  for i := Items.Count - 1 downto 0 do
  begin
    Item := Items[i];
    if Assigned(Item) then
      if Item.Size <> 0 then
        Item.Image.Free;
    Dispose(Item);
  end;
  Items.Clear;
end;

procedure TfrmMain.ClearThumbsPool;
var
  i: Integer;
  Thumb: PCacheItem;
begin
  for i := ThumbsPool.Count - 1 downto 0 do
  begin
    Thumb := ThumbsPool[i];
    if Thumb.Bmp <> nil then
      Thumb.Bmp.Free;
    Dispose(Thumb);
  end;
  ThumbsPool.Clear;
  PoolSize := 0;
end;

procedure TfrmMain.GenCellColors;
begin
  cHot := $00FDDE99;
  cGHotStart := $00FDF5E6;
  cGHotEnd := $00FDFBF6;
  cSelected := $00FDCE99;
  cGSelectedStart := $00FCEFC4;
  cGSelectedEnd := $00FDF8EF;
  cShadeSelect := $00F8F3EA;
  cDisabled := $00D9D9D9;
  cGDisabledStart := $00EAE9E9;
  cGDisabledEnd := $00FCFBFB;
  cShadeDisabled := $00F6F5F5;
  cGHeaderStart := $00F9F9F9;
  cGHeaderEnd := $00FEFEFE;
  cGHeaderHotStart := $00FFEDBD;
  cGHeaderHotEnd := $00FFF7E3;
  cGHeaderSelStart := $00FCEABA;
  cGHeaderSelEnd := $00FCF4E0;
  cBackground := clWindow; ;
  cLineHighLight := $00FEFBF6;
  CellBkgColor := clWindow;
  CellBrdColor[False, False] := cDisabled;
  CellBrdColor[False, true] := cDisabled;
  CellBrdColor[true, False] := $00B5B5B5;
  CellBrdColor[true, true] := cSelected;
end;

end.
