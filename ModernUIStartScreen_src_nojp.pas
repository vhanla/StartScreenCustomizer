(*
ModerUIStartScreenChanger

[TODO]

ChangeLOG:
[2013-10-10] v1.4.10
  - Added multilanguage support
[2013-10-09] v1.4.09
  - Fixed applying picture in different monitor ratio.
[2013-10-05] v1.4.05
  - Fix image size when changing to another monitor size (multimonitor)
  - Replaced Scree.Width and Screen.Height with multimonitor support and startscreen detection
    as its monitor container
  - Fixed picture ratio on a different ratio monitor
  - Fixed bad size on slidesho and desktop wallpaper

[2013-09-09] v1.4.09
  - Routine to get Global DPI on Windows 8.1
[2013-09-08] v1.4.08
  - Changed paypal donation ids to specific app ids
  - Determine effective screen resolution
    http://msdn.microsoft.com/en-us/library/windows/desktop/dd464660(v=vs.85).aspx
  - Added SetProcessDPIAware WINAPI
[2013-09-06] v1.4.06
  - Detect Win8DpiScaling using win registry
[2013-09-04] v1.4.04
  - Detect where is located the start screen so we can adjust it again depending
    on monitor's resolution
    //using http://www.experts-exchange.com/Programming/Languages/Pascal/Delphi/Q_26433567.html
  - Fixed memory exception fault when loaded some weird gif files
  - Animation fixed to respect original frame's delay of each frame
[2013-09-01] v1.4
  - Fixed 2801 resource not found on Win81 RTM
[2013-08-29] v1.3.29
  - Desktop support for animations (not working though) changes are on tmrgif
[2013-08-26] v1.3.15
  - GIF Animation support instead of large slideshows
  - Progressbar to show loading big GIF files
  - Changed TIniFile to TMemIniFile to allow unicode filenames
  - Fixed incompatibilities of gif, slideshow, desktop and static modes [needs review]
  - TODO: fix autoapplying when selected original (restoring) on Windows 8.1
          option to allow mixing with parallax effect

[2013-08-15] v1.3.14
  - Disabled features non working on Windows 8.1
  - Adding animation features: on the go, using FFMPEG to convert videos to sequences
  - FastBlur method added (changed desktop variable to tbitmap32 and is faster, also BMP in correspondant procedures where FastBlur is used)
  - Resampler method added so it will shows better, not pixelized (using GR32_Resamplers)
  - Added a routine to see in slideshow timer if startscreen is focused

[2013-08-13] v1.3.13
  - Support for Windows 8.1

[2013-01-07] v1.3.11
  - Cleaning up unused code

[2012-12-11] v1.3.10
  Thanks to http://stackoverflow.com/a/7398658/537347
  - Added even further reduction with {$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED} in .DRP file
    reduced to 2736KB it is reccommend only for exe files
  - Added further reducing seetings with
    {$IFOPT D-}{$WEAKLINKRTTI ON}{$ENDIF}
    {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
    after program;
    reduce to 2942KB

  - Added {$WeakLinkRtti On} to reduce file size - it reduced from 3381KB to 3010KB

[2012-12-07] v1.3.9
  - Fixed layered window on setbackground (previously only worked with trakbars only)
  - Added a shape to differentiate tiles rows settings from other settings
  - Fixing Run at startup

[2012-12-06] v1.3.8 [published]
  - Adding HIGH DPI Awareness since it considered smaller in high dpi (150% e.g)
    I used a manifest file suggested by Microsoft

[2012-11-29] v1.3.7
  - Fixing monitor change

[2012-11-20] v1.3.6
  - Updating desktop picture if newer is loaded in a sequence
  - Slideshow almost complete, well it is complete.
  - Blur working perfectly, slow but working
  - Added single instance to launch itself when another instance tries to execute
  - Added "extra preferences" to the WriteINI procedure
  - Fixed load new picture if running the wallpaper or slideshow
  - Config.ini path variable added incase we like to save in other directory
    specially if we are going to deploy in program files directory
  - Fixing bugs about readini that doesn't load correctly if no picture in bgpic

[2012-11-19] v1.3.5
  - Getting desktop picture straight from the desktop
  - Dimming modal background ( thsnk tohttp://www.delphipraxis.net/140886-lightbox-effekt-fuer-form.html )

[2012-11-17] v1.3.4
  - Adding desktop wallpaper as background

[2012-11-15] v1.3.3
  - Tiles opacity added

[2012-11-12] v1.3.2
  - Clear picture so it will be available the old ones
  - TODO:
    - Auto adjust selection centered on load new picture
    - Drag & Drop support

[2012-11-11] v1.3.0
  - Detect screen resolution change


[2012-11-11] REWRITE FROM SCRATCH !almost
  - Getting rid of imageres.dll version

[2012-11-11]
  - Added detection if is running with admin privileges
  - Fixed scrolling issue in previewer
  - Added alpha opacity feature for Start Screen

[2012-11-10]
  - Added start screen tile rows modifier
  - Fixed Imageresversion detection which was using SysWOW in 64bit system, now it
    uses Sysnative instead if 64bit os otherwise system32 in 32bit os
  - Elevated Privieleges detection that will tell if user is running this application
    as admin

[2012-11-09]
  - Added multithread processing to faster DLL resource replacing
  - Fixed some bugs related to the processing steps and avoiding unwanted steps

[2012-11-08]
  - Added multithread support to process cropping
[2012-11-07]
  - Added fullpic mode that will cut picture so it will adjust to screen resolution view

[2012-11-06]
  - Fixed replacing PNG in imageres
  - Added a way to identifi imageres.dll compiled machine architecture (43bit/64bit)
  - Prevent user to use this tool for 64bit or 32bit editing
  - Added Preview PNG
  - Added checkbuttons to crop &| replace

[2012-11-03_04]
  - Now it can save to 8bit PNG with floydsteinberg algorithm
  - Fixed cropping and resizing the new picture
   (working great now)
   it was using getbitmapsize which was not accurate
   changed to bitmap.boundsrect.width|height

  Learn that using [roConstrain] and adjusting as maxwidth and maxheight as top will help
  So onresize was the chosen one since onconstrain doesn't work as expected

  Finally it seems that resizing inside the imgbox works! thanks to setting correctly the
  maxwith and maxheight using the aspect ratio

[2012-10-16]
  Added Is64bitOS function to detect Syswow64 presence
  %windir%\sysnative = system32
*)
unit ModernUIStartScreen_src;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ShellAnimations, Vcl.ExtDlgs,{ System.UITypes,}
  math, shlobj, Vcl.ComCtrls, GR32_Image, GR32, GR32_Layers,GR32_Polygons,GR32_Resamplers,
  Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg, Vcl.Imaging.jpeg, Vcl.Samples.Spin,
  Inifiles, Registry, ShellApi,GR32_Math, Vcl.Menus, System.Classes,
  DWMApi;

const AppVersion = '1.3.15';

type
  TSeleccionador = class(TRubberbandLayer)
    private
      FFillColor: TColor32;
      FLineColor: TColor32;
      procedure SetFillColor(Value: TColor32);
      procedure SetLineColor(Value: TColor32);
      procedure GetResize(Sender: TObject;
        const OldLocation: TFloatRect;
        var NewLocation: TFloatRect;
        DragState: TDragState;
        Shift: TShiftState);
    protected
      procedure Paint(Buffer: TBitmap32); override;
    public
      property FillColor: TColor32 read FFillColor write SetFillColor;
      property LineColor: TColor32 read FLineColor write SetLineColor;
  end;

type
  TDesktopCanvas = class(TCanvas)
  private
    DC: hDC;
    function GetWidth:Integer;
    function GetHeight:Integer;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
  end;

type
  HMONITOR = type Integer;
  PMonitorInfoA = ^TMonitorInfoA;
  TMonitorInfoA = record
    cbSize: DWORD;
    rcMonitor: TRect;
    rcWork: TRect;
    dwFlags: DWORD;
  end;
const
  MONITOR_DEFAULTTONEAREST = $2;

type
  MONITOR_DPI_TYPE = (MDT_Effective_DPI = 0,MDT_Angular_DPI = 1,MDT_Raw_DPi = 2, MDT_Default = MDT_Effective_DPI);

//http://delphi.about.com/library/weekly/aa011805a.htm
type
  TResourceLocalizer = class
    class procedure GetLanguages(const Strings : TStrings);
    class function GetString(const Offset, Position : integer) : string;
    class procedure GetStrings(const Strings : TStrings; Offset : integer; Positions : array of integer);
  end;
const
  MaxBuffer = 255;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Image18: TImage;
    Image19: TImage;
    Image20: TImage;
    Image502x52: TImage;
    img320x240: TImage;
    Timer1: TTimer;
    Label1: TLabel;
    Panel1: TPanel;
    BalloonHint1: TBalloonHint;
    OpenPictureDialog1: TOpenPictureDialog;
    btnExit: TButton;
    Label3: TLabel;
    Label4: TLabel;
    btnPreview: TButton;
    ImgView321: TImgView32;
    btnLoadPicture: TButton;
    Shape2: TShape;
    pnlLog: TPanel;
    lblSupport: TLabel;
    cbDonate: TComboBox;
    imgBtnDonate: TImage;
    Panel2: TPanel;
    SpinEdit1: TSpinEdit;
    lblRowsNumber: TLabel;
    btnTilesRowApply: TButton;
    btnTilesRowRestore: TButton;
    Label6: TLabel;
    tmrDesktop: TTimer;
    SystrayPopupMenu: TPopupMenu;
    btnHide: TButton;
    lblLike: TLabel;
    imgLike: TImage;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    chkDesktopWallpaper: TCheckBox;
    chkGaussianBlur: TCheckBox;
    chkSlideShow: TCheckBox;
    btnSlideshow: TButton;
    chkStartup: TCheckBox;
    chkRandom: TCheckBox;
    spinSlideInterval: TSpinEdit;
    lblInterval: TLabel;
    spinGaussian: TSpinEdit;
    Button5: TButton;
    tmrSlideshow: TTimer;
    Shape1: TShape;
    tmrgif: TTimer;
    ProgressBar1: TProgressBar;
    TabSheet2: TTabSheet;
    lblStartScreenOpacityTB: TLabel;
    TrackBar1: TTrackBar;
    lblStartScreenOpacity: TLabel;
    lblTilesOpacityTB: TLabel;
    TrackBar2: TTrackBar;
    lblTilesOpacity: TLabel;
    tmrfixsize: TTimer;
    cbLanguage: TComboBox;
    lblLanguage: TLabel;    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
    procedure Image13Click(Sender: TObject);
    procedure Image14Click(Sender: TObject);
    procedure Image15Click(Sender: TObject);
    procedure Image16Click(Sender: TObject);
    procedure Image17Click(Sender: TObject);
    procedure Image18Click(Sender: TObject);
    procedure Image19Click(Sender: TObject);
    procedure Image20Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Image502x52Click(Sender: TObject);
    procedure img320x240Click(Sender: TObject);
    procedure btnLoadPictureClick(Sender: TObject);
    procedure btnCloseLogClick(Sender: TObject);

    procedure imgBtnDonateClick(Sender: TObject);
    procedure btnTilesRowRestoreClick(Sender: TObject);
    procedure btnTilesRowApplyClick(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure tmrDesktopTimer(Sender: TObject);
    procedure chkStartupClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure lblLikeClick(Sender: TObject);
    procedure imgLikeClick(Sender: TObject);
    procedure chkDesktopWallpaperClick(Sender: TObject);
    procedure btnSlideshowClick(Sender: TObject);
    procedure chkGaussianBlurClick(Sender: TObject);
    procedure spinGaussianChange(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure chkSlideShowClick(Sender: TObject);
    procedure tmrSlideshowTimer(Sender: TObject);
    procedure tmrgifTimer(Sender: TObject);
    procedure tmrfixsizeTimer(Sender: TObject);
    procedure cbLanguageChange(Sender: TObject);
    procedure FormShow(Sender: TObject);

private
    { Private declarations }
    IconData : TNotifyIconData;
    procedure ReadRegistry;
    procedure SaveRegistry;
    procedure AutoStartState;
    procedure RestoreRegistry;
    procedure ApplyChanges;
    procedure ReadINI;
    procedure WriteINI;
    procedure ReadSlidesFromINI;
    procedure Iconito(var msg: TMessage); message WM_USER+1;
    procedure WMDisplayChange(var Msg: TMessage); message WM_DISPLAYCHANGE;

    procedure MainFormModalShow(Sender: TObject);
    procedure MainFormModalHide(Sender: TObject);

    procedure OnProgress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);

    procedure ApplyWallpaper;
    procedure ApplySlide;
  protected
    procedure CreateParams(var Params: TCreateParams);override;
    procedure WndProc(var Msg:TMessage);override;

  public
    { Public declarations }
    Seleccionador: TSeleccionador;

  end;


var
  Form1: TForm1;
  fwm_TaskbarRestart : Cardinal;
  ResLanguage: Word;
  apppath,temapath:string;
  IsWin8x64:boolean = false;
  customIcon, customSmall, customMedium, customLarge, customPreview: String;
  elHilo: integer;
  proceso: integer=0;

  gAppDir: string;
  gTempDir: string;
  gSysnative: string;
  gSystem32: string;

  bgpic:string;

  hratio: real; //to keep selection ratio
  vratio: real;

  fullpic: boolean=true; //this will serve as activator to choose entire picture
  //i.e. 50% frame in the middle included
  processed: boolean;

  ElevationType: Integer;
  Elevation: DWord;

  //desktop cycler
  WallpaperAge: int64;
  WallpaperAsBG: boolean = false;

  //slideshow files
  SlideshoOn: boolean = false;
  SlideshowPath: string;
  SlideshowList: TStringList;
  Startpos: integer;


  ConfigFilePath: string;

  IsWin81: boolean = false;
  IsWin81RTM: boolean = false;
  //gIF
  gif: TGIFImage;
  gir: TGIFRenderer;
  gifon : boolean = False; //to let app know that animated gif is loaded

  //desktop canvas
  Desk : TDesktopCanvas;

  //windows8dpiscaling
  Win81DPIOn: boolean = False; //by default lets consider it disabled since it would be that way on Windows 8

  //resolution changes
  scrWith, scrHeight: integer;

  //Multilanguage string variables
  msgHelp: string;

const
  Themes: array[1..20] of integer = (
 10000,
 10100,
 10220,
 10310,
 10430,
 10500,
 10600,
 10710,
 10810,
 10910,
 11010,
 11100,
 11210,
 11300,
 11430,
 11510,
 11600,
 11700,
 11800,
 11900);

  Themes81: array[1..14] of integer = (
 20001,
 20201,
 20301,
 20401,
 20501,
 20601,
 20701,
 20801,
 21001,
 21101,
 21201,
 21301,
 21401,
 21801
  );

  Themes81RTM: array[1..19] of integer = (
 20001,
 20201,
 20301,
 20401,
 20501,
 20601,
 20701,
 20801,
 21001,
 21101,
 21201,
 21301,
 21401,
 21501,
 21601,
 21701,
 21901,
 22001,
 22101
 );


//  procedure SwitchToThisWindow(h1: hWnd; x: bool); stdcall;
//  external user32 Name 'SwitchToThisWindow';
  (*procedure SHChangeNotify(wEventID:LONG; uFlags:UINT;dwItem1:LPCVOID;dwItem2:LPCVOID); stdcall;
  external 'shell32' Name 'SHChangeNotify';*)
  procedure SwitchToThisWindow(h1: hWnd; x: bool); stdcall;
  external user32 Name 'SwitchToThisWindow';
function GetShellWindow:HWND;stdcall;
external user32 Name 'GetShellWindow';
function PrintWindow(Handle: HWND;hdcBlt:HDC;nFlags:UINT):boolean;stdcall;
  external User32 name 'PrintWindow';
(*function SetProcessDPIAware:boolean;stdcall;
  external User32 name 'SetProcessDPIAware';*)
//function GetDpiForMonitor(hmonitor: HMONITOR;dpiType: MONITOR_DPI_TYPE; var dpiX: cardinal; var dpiY: cardinal):HRESULT;stdcall;
//  external 'ShCore' name 'GetDpiForMonitor';
function MonitorFromWindow(hWnd: HWND; dwFlags: DWORD): HMONITOR; stdcall;
  external 'User32' name 'MonitorFromWindow';
procedure GetScaleFactorForMonitor(hMon: HMONITOR; var pScale: cardinal);stdcall;
external 'shcore' name 'GetScaleFactorForMonitor';
implementation

{$R *.dfm}
{$R StringTableLocalization.RES}

uses ChooseFolder_src, GBlur2;
{ThreadVar
  msgPtr : ^TMsgRecord;}

{ TDesktopCanvas object}
function TDesktopCanvas.GetWidth:Integer;
begin
  Result:= GetDeviceCaps(Handle, HORZRES);
end;

function TDesktopCanvas.GetHeight:Integer;
begin
  Result := GetDeviceCaps(Handle, VERTRES);
end;

constructor TDesktopCanvas.Create;
begin
  inherited Create;
  DC := GetWindowDC(GetDesktopWindow);
  Handle := DC;
end;

destructor TDesktopCanvas.Destroy;
begin
  Handle := 0;
  ReleaseDC(GetDesktopWindow, DC);
  inherited Destroy;
end;

(* CDPI routines *)

//following routines from http://stackoverflow.com/a/15066022/537347 from lazarus lcltype.pp
function MathRound(AValue: Extended): Int64; inline;
begin
  if AValue >= 0 then
    Result := Trunc(AValue + 0.5)
  else
    Result := Trunc(AValue - 0.5);
end;
function MulDiv(nNumber, nNumerator, nDenominator: Integer): Integer;
begin
  if nDenominator = 0 then
    Result := -1
  else
    Result := MathRound(Int64(nNumber) * Int64(nNumerator) / nDenominator);
end;

function RealScreenWidthResolution:integer;
var
  DC : HDC;
begin
  DC := GetDC(0);
  try
    Result := MulDiv(GetSystemMetrics(SM_CYSCREEN), 96, GetDeviceCaps(DC, LOGPIXELSY));
  finally
    ReleaseDC(0,DC);
  end;
end;


(* Seleccionador *)
procedure TSeleccionador.Paint(Buffer: TBitmap32);
var
  Cx,Cy: integer;
  R: TRect;

  procedure DrawHandle(X,Y:integer);
  var
    A,R:Double;
    AFP:TArrayOfFixedPoint;
    i,res: Integer;
    xf,yf: Double;
  begin
    R:=(HandleSize * 2);
    res:=Round(R);
    if R <= 16 then res:=32;
    if R <= 8 then res:=16;
    if R <= 4 then res:=8;
    SetLength(AFP,res);
    for I := 0   to  res -1 do
    begin
      A:=(i / res)*2*PI;
      xf:=Cos(A)*R;
      yf:=Sin(A)*R;
      AFP[i]:=FixedPoint(xf+X,yf+Y);
    end;
    PolygonXS(Buffer,AFP,FLineColor);

    SetLength(AFP,0);

    R:=(HandleSize*2)-1;
    res:=Round(R);
    if R <= 16 then res := 32;
    if R <= 8 then res := 16;
    if R <= 4 then res := 8;

    SetLength(AFP, res);
    for i := 0 to res - 1 do
    begin
      A := (i / res) * 2*PI;
      xf := Cos(A) * R;
      yf := Sin(A) * R;
      AFP[i] := FixedPoint(xf + X, yf + Y);
    end;
    PolygonXS(Buffer, AFP, FFillColor);
  end;
begin
  R:=MakeRect(GetAdjustedRect(Location));
  with R do
  begin
    if rhFrame in Handles then
    begin
      Buffer.FrameRectS(Left,Top,Right,Bottom,FFillColor);
(*      if fullpic then
        //let's divide it
        Buffer.FrameRectS(Left,Top+(trunc((Bottom-Top)/2*0.73)),Right,Bottom-(trunc((Bottom-Top)/2*0.27)),color32(123,153,0))
      else
        Buffer.FrameRectS(Left,Top+(trunc((Bottom-Top)*0.73)),Right,Bottom-(trunc((Bottom-Top)*0.27)),color32(123,153,0));*)
    end;
    if rhCorners in Handles then
    begin
      if not (rhNotTLCorner in Handles) then DrawHandle(Left, Top);
      if not (rhNotTRCorner in Handles) then DrawHandle(Right, Top);
      if not (rhNotBLCorner in Handles) then DrawHandle(Left, Bottom);
      if not (rhNotBRCorner in Handles) then DrawHandle(Right, Bottom);
    end;
    if rhSides in Handles then
    begin
      Cx:=(Left+Right) div 2;
      Cy:=(Top+Bottom) div 2;
      if not (rhNotTopSide in Handles) then DrawHandle(Cx+1, Top);
      if not (rhNotLeftSide in Handles) then DrawHandle(Left, Cy+1);
      if not (rhNotRightSide in Handles) then DrawHandle(Right, Cy+1);
      if not (rhNotBottomSide in Handles) then DrawHandle(Cx+1, Bottom);
    end;
  end;
end;

procedure TSeleccionador.SetFillColor(Value: TColor32);
begin
  FFillColor:=Value;
  Update;
end;

procedure TSeleccionador.SetLineColor(Value: TColor32);
begin
  FLineColor:=Value;
  Update;
end;

{ TResourceLocalizer }

class procedure TResourceLocalizer.GetLanguages(const Strings : TStrings);
const
  delta = 1000;
var
  buffer : array[0..MaxBuffer] of char;
  ls : integer;
  position : integer;
begin
  position := delta;
  Strings.Clear;
  ls := LoadString(hInstance, position, buffer, sizeof(buffer));
  while ls <> 0 do
  begin
    Strings.AddObject(buffer, TObject(position));
    position := position + delta;
    ls := LoadString(hInstance, position, buffer, sizeof(buffer));
  end;
end;

class function TResourceLocalizer.GetString(const Offset, Position: integer) : string;
var
  buffer : array[0..MaxBuffer] of char;
  ls : integer;
begin
  Result := '';
  ls := LoadString(hInstance, Offset + Position, buffer, sizeof(buffer));
  if ls <> 0 then
  begin
    Result := buffer;
  end;
end;

class procedure TResourceLocalizer.GetStrings(const Strings: TStrings; Offset : integer; Positions : array of integer);
var
  buffer : array[0..MaxBuffer] of char;
  ls : integer;
  idx : integer;
begin
  Strings.Clear;
  for idx := Low(Positions) to High(Positions) do
  begin
    ls := LoadString(hInstance, Offset + Positions[idx], buffer, sizeof(buffer));
    if ls <> 0 then
    begin
      Strings.Add(buffer);
    end;
  end;
end;

function IsWindows81:boolean;
var
  r: TRegistry;
  CurrentVersion, CurrentBuild: string;
begin
  Result:=False;

  try
    r := TRegistry.Create;
    try
      r.RootKey:=HKEY_LOCAL_MACHINE;
      if r.OpenKeyReadOnly('Software\Microsoft\Windows NT\CurrentVersion') then
      begin
        CurrentVersion := r.ReadString('CurrentVersion'); //6.3
        CurrentBuild := r.ReadString('CurrentBuildNumber'); //9431
        if (CurrentVersion = '6.3')and(StrToInt(CurrentBuild) >= 9431)  then
        begin
          if StrToInt(CurrentBuild) >= 9600 then //if RTM
            IsWin81RTM := True;
          Result := True;
        end;

      end;
    finally
      r.Free;
    end;
  except
  end;

end;

function GetSpecialFolderPath(Folder: Integer; CanCreate: Boolean): string;

// Gets path of special system folders
//
// Call this routine as follows:
// GetSpecialFolderPath (CSIDL_PERSONAL, false)
//        returns folder as result
//
var
   FilePath: array [0..MAX_PATH] of char;

begin
 SHGetSpecialFolderPath(0, @FilePath[0], FOLDER, CanCreate);
 Result := FilePath;
end;

(*
Ajusta en relación a la imagen redimensionada de imgview32
Sólo funcionará con esa imagen redimensionada, nada de scrollbars
o zooms.
*)
procedure TSeleccionador.GetResize(Sender: TObject;
  const OldLocation: TFloatRect;
  var NewLocation: TFloatRect;
  DragState: TDragState;
  Shift: TShiftState);
var
  frame: TRect;
begin
  //evitamos que se extienda mucho el ancho
  frame:=Form1.ImgView321.GetBitmapRect; //obtiene  los márgenes relativos de la imagen

  if NewLocation.Left < Frame.Left then
  begin
    NewLocation.Right := NewLocation.Right+Abs(Frame.Left-NewLocation.Left);
    NewLocation.Left := Frame.Left;
  end;

  if NewLocation.Top < Frame.Top then
  begin
    NewLocation.Bottom := NewLocation.Bottom+Abs(Frame.Top-NewLocation.Top);
    NewLocation.Top := Frame.Top;
  end;

  if NewLocation.Right > Frame.Left+Frame.Width then //Form1.ImgView321.Width then
  begin
    NewLocation.Left := NewLocation.Left - (NewLocation.Right - (Frame.Left+Frame.Width)); //Form1.ImgView321.Width);
    NewLocation.Right := Frame.Left+Frame.Width;//Form1.ImgView321.Width;
  end;

  if NewLocation.Bottom > Frame.Top+Frame.Height then //Form1.ImgView321.Height then
  begin
    NewLocation.Top := NewLocation.Top - (NewLocation.Bottom - (Frame.Top+Frame.Height) );//Form1.ImgView321.Height);
    NewLocation.Bottom := frame.Top+Frame.Height; //Form1.ImgView321.Height;
  end;


end;

procedure IsElevated;
const
  TokenElevationType = 18;
  TokenElevation     = 20;
  TokenElevationTypeDefault = 1;
  TokenElevationTypeFull    = 2;
  TokenElevationTypeLimited = 3;

var token: NativeUINT;
//    ElevationType: Integer;
//    Elevation: DWord;
    dwSize: Cardinal;
begin
  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, token) then
    try
      GetTokenInformation(token, TTokenInformationClass(TokenElevationType), @ElevationType, SizeOf(ElevationType), dwSize);
      (*if GetTokenInformation(token, TTokenInformationClass(TokenElevationType), @ElevationType, SizeOf(ElevationType), dwSize) then
        case ElevationType of
          TokenElevationTypeDefault:  ShowMessage('elevation type default');
          TokenElevationTypeFull:     ShowMessage('elevation type full');
          TokenElevationTypeLimited:  ShowMessage('elevation type limited');
        else
          ShowMessage('elevation type unknown');
        end
      else
        ShowMessage(SysErrorMessage(GetLastError));*)

      GetTokenInformation(token, TTokenInformationClass(TokenElevation), @Elevation, SizeOf(Elevation), dwSize);
      (*if GetTokenInformation(token, TTokenInformationClass(TokenElevation), @Elevation, SizeOf(Elevation), dwSize) then begin
        if Elevation = 0 then
          ShowMessage('token does NOT have elevate privs')
        else
          ShowMessage('token has elevate privs');
      end else
        ShowMessage(SysErrorMessage(GetLastError));*)
    finally
      CloseHandle(token);
    end
  else
    ShowMessage(SysErrorMessage(GetLastError));
end;


{
A new method to handle multiple monitors
}

function GetRectOfPrimaryMonitor(const WorkArea: Boolean): TRect;
begin
  if not WorkArea or
     not SystemParametersInfo(SPI_GETWORKAREA, 0, @Result, 0) then
    Result := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
end;

function UsingMultipleMonitors: Boolean;
{ Returns True if the system has more than one display monitor configured. }
var
  NumMonitors: Integer;
begin
  NumMonitors := GetSystemMetrics(80 {SM_CMONITORS});
  Result := (NumMonitors <> 0) and (NumMonitors <> 1);
  { ^ NumMonitors will be zero if not running Win98, NT 5, or later }
end;


type
  TMultiMonApis = record
    funcMonitorFromRect: function(lprcScreenCoords: PRect; dwFlags: DWORD): HMONITOR; stdcall;
    funcMonitorFromPoint: function(ptScreenCoords: TPoint; dwFlags: DWORD): HMONITOR; stdcall;
    funcMonitorFromWindow: function(hWnd: HWND; dwFlags: DWORD): HMONITOR; stdcall;
    funcGetMonitorInfoA: function(hMonitor: HMONITOR; lpMonitorInfo: PMonitorInfoA): BOOL; stdcall;
  end;

{ Under D4 I could be using the MultiMon unit for the multiple monitor
  function imports, but its stubs for MonitorFromRect and MonitorFromPoint
  are seriously bugged... So I chose to avoid the MultiMon unit entirely. }

function InitMultiMonApis(var Apis: TMultiMonApis): Boolean;
var
  User32Handle: THandle;
begin
  User32Handle := GetModuleHandle(user32);
  Apis.funcMonitorFromRect := GetProcAddress(User32Handle, 'MonitorFromRect');
  Apis.funcMonitorFromPoint := GetProcAddress(User32Handle, 'MonitorFromPoint');
  Apis.funcMonitorFromWindow := GetProcAddress(User32Handle, 'MonitorFromWindow');
  Apis.funcGetMonitorInfoA := GetProcAddress(User32Handle, 'GetMonitorInfoA');
  Result := Assigned(Apis.funcMonitorFromRect) and
    Assigned(Apis.funcMonitorFromPoint) and Assigned(Apis.funcGetMonitorInfoA);
end;

function GetRectOfMonitorContainingRect(const R: TRect;
  const WorkArea: Boolean): TRect;
{ Returns the work area of the monitor which the rectangle R intersects with
  the most, or the monitor nearest R if no monitors intersect. }
var
  Apis: TMultiMonApis;
  M: HMONITOR;
  MonitorInfo: TMonitorInfoA;
begin
  if UsingMultipleMonitors and InitMultiMonApis(Apis) then begin
    M := Apis.funcMonitorFromRect(@R, MONITOR_DEFAULTTONEAREST);
    MonitorInfo.cbSize := SizeOf(MonitorInfo);
    if Apis.funcGetMonitorInfoA(M, @MonitorInfo) then begin
      if not WorkArea then
        Result := MonitorInfo.rcMonitor
      else
        Result := MonitorInfo.rcWork;
      Exit;
    end;
  end;
  Result := GetRectOfPrimaryMonitor(WorkArea);
end;

function GetRectOfMonitorContainingPoint(const P: TPoint;
  const WorkArea: Boolean): TRect;
{ Returns the screen area of the monitor containing the point P, or the monitor
  nearest P if P isn't in any monitor's work area. }
var
  Apis: TMultiMonApis;
  M: HMONITOR;
  MonitorInfo: TMonitorInfoA;
begin
  if UsingMultipleMonitors and InitMultiMonApis(Apis) then begin
    M := Apis.funcMonitorFromPoint(P, MONITOR_DEFAULTTONEAREST);
    MonitorInfo.cbSize := SizeOf(MonitorInfo);
    if Apis.funcGetMonitorInfoA(M, @MonitorInfo) then begin
      if not WorkArea then
        Result := MonitorInfo.rcMonitor
      else
        Result := MonitorInfo.rcWork;
      Exit;
    end;
  end;
  Result := GetRectOfPrimaryMonitor(WorkArea);
end;

function GetRectOfMonitorContainingWindow(const W: HWND;
  const WorkArea: Boolean): TRect;
var
  Apis: TMultiMonApis;
  M: HMONITOR;
  MonitorInfo: TMonitorInfoA;
begin
  if UsingMultipleMonitors and InitMultiMonApis(Apis) then begin
    M := Apis.funcMonitorFromWindow(W, MONITOR_DEFAULTTONEAREST);
    MonitorInfo.cbSize := SizeOf(MonitorInfo);
    if Apis.funcGetMonitorInfoA(M, @MonitorInfo) then begin
      if not WorkArea then
        Result := MonitorInfo.rcMonitor
      else
        Result := MonitorInfo.rcWork;
      Exit;
    end;
  end;
  Result := GetRectOfPrimaryMonitor(WorkArea);
end;


//get resolution of screen with multimonitor support
function ScreenWidth:integer;
var
  StartScreenHWND: HWND;
  r: TRect;
begin
  StartScreenHWND:=FindWindow('ImmersiveLauncher',nil);
  if StartScreenHWND <> 0 then
  begin
    r := GetRectOfMonitorContainingWindow(StartScreenHWND,false);
    Result:=r.Width;
  end
  else
    Result:= Screen.Width;
end;

function ScreenHeight:integer;
var
  StartScreenHWND: HWND;
  r: TRect;
begin
  StartScreenHWND:=FindWindow('ImmersiveLauncher',nil);
  if StartScreenHWND <> 0 then
  begin
    r := GetRectOfMonitorContainingWindow(StartScreenHWND,false);
    Result:=r.Height;
  end
  else
    Result:= Screen.Height;
end;

(*
 Returns: 0 or 32 or 64 values to tell if Imageres.dll is a valid DLL and which bit version is
*)
function ImageresVersion:integer;
var
  fs: TFileStream;
  signature: DWORD;
  dos_header: IMAGE_DOS_HEADER;
  pe_header: IMAGE_FILE_HEADER;
begin
  // let's find out if the IMAGERES.DLL is 32bit/64bit
  fs:= TFileStream.Create(gSysnative+'imageres.dll',fmOpenRead or fmShareDenyNone);
  try
    fs.Read(dos_header, SizeOf(dos_header));
    if dos_header.e_magic <> IMAGE_DOS_SIGNATURE then
    exit;

    fs.Seek(dos_header._lfanew,soFromBeginning);
    fs.Read(signature, SizeOf(signature));
    if signature <> IMAGE_NT_SIGNATURE then
    begin
      raise Exception.Create('Invalid PE Header');
      exit;
    end;
    fs.Read(pe_header,SizeOf(pe_header));

    Result:=0;
    case pe_header.Machine of
      IMAGE_FILE_MACHINE_I386:  Result:=32;
      IMAGE_FILE_MACHINE_IA64:  Result:=64;
      IMAGE_FILE_MACHINE_AMD64: Result:=64;
    end;


  finally
    fs.Free;
  end;

end;

function BitsForPixel(const AColorType,  ABitDepth: Byte): Integer;
begin
  case AColorType of
    COLOR_GRAYSCALEALPHA: Result := (ABitDepth * 2);
    COLOR_RGB:  Result := (ABitDepth * 3);
    COLOR_RGBALPHA: Result := (ABitDepth * 4);
    COLOR_GRAYSCALE, COLOR_PALETTE:  Result := ABitDepth;
  else
      Result := 0;
  end;
end;

(*
Used only once since this value requires to be taken into account only when
windows new session is done, i.e. it requires to logoff in order to see changes
*)
function IsWin8DpiScalingOn:boolean;
var
  R : TRegistry;
begin
  Result := False ; //assuming is Windows 8
  //and if is Win81
  if IsWin81 then //including windows 8.1 beta
  begin
    R:=TRegistry.Create;
    try
      R.RootKey := HKEY_CURRENT_USER;
      R.OpenKeyReadOnly('Control Panel\Desktop');
      if R.ReadInteger('Win8DpiScaling')=0 then //is enabled
      Result := True
      else Result := False;
    finally
      R.Free;
    end;
  end;
end;

function Is64BitOS: Boolean;
type
  TIsWow64Process = function(Handle:THandle; var IsWow64 : BOOL) : BOOL; stdcall;
var
  hKernel32 : Integer;
  IsWow64Process : TIsWow64Process;
  IsWow64 : BOOL;
begin
  // we can check if the operating system is 64-bit by checking whether
  // we are running under Wow64 (we are 32-bit code). We must check if this
  // function is implemented before we call it, because some older versions
  // of kernel32.dll (eg. Windows 2000) don't know about it.
  // see http://msdn.microsoft.com/en-us/library/ms684139%28VS.85%29.aspx
  Result := False;
  hKernel32 := LoadLibrary('kernel32.dll');
  if (hKernel32 = 0) then RaiseLastOSError;
  @IsWow64Process := GetProcAddress(hkernel32, 'IsWow64Process');
  if Assigned(IsWow64Process) then begin
    IsWow64 := False;
    if (IsWow64Process(GetCurrentProcess, IsWow64)) then begin
      Result := IsWow64;
    end
    else RaiseLastOSError;
  end;
  FreeLibrary(hKernel32);
end;



function GetWindowsDir: string;
const
  (* The length of the directory buffer. Usually 64 or even 16 is enough
    **
    ** Must be DWORD type.
  *)
dwLength: DWORD = MAX_PATH;
var
pcWinDir: PChar;
begin
  GetMem(pcWinDir, dwLength);
  //GetSystemDirectory(pcWinDir, dwLength);
  GetWindowsDirectory(pcWinDir,dwLength);
  Result := string(pcWinDir)+'\';
  FreeMem(pcWinDir, dwLength);
end;

//http://graphics32.general.free-usenet.eu/Very-Fast-Gaussian-Blur_T25484099_S3
procedure FastBlur(Dst: TBitmap32; Radius: Integer; Passes: Integer = 3);
type
  PARGB32 = ^TARGB32;
  TARGB32 = packed record
  B: Byte;
  G: Byte;
  R: Byte;
  A: Byte;
  end;
  TLine32 = array[0..MaxInt div SizeOf(TARGB32)-1] of TARGB32;
  PLine32 = ^TLine32;

  PSumRecord = ^TSumRecord;
  TSumRecord = packed record
  saB, saG, saR, saA: Cardinal;
  end;
var
  J,X,Y,w,h,ny,tx,ty: integer;
  ptrD: integer;
  s1: PLine32;
  C: TColor32;
  sa: array of TSumRecord;
  sr1, sr2: TSumRecord;
  n: Cardinal;
begin
  if Radius = 0 then Exit;
  n:=Fixed(1/((Radius*2)+1));
  w:=Dst.Width - 1;
  h:=Dst.Height - 1;

  SetLength(sa,w+1+(radius*2));

  s1:=PLine32(Dst.PixelPtr[0,0]);
  ptrD:=Integer(Dst.PixelPtr[0,1])-integer(s1);

  ny:=integer(s1);
  for Y := 0 to H do
  begin
    for J := 1 to Passes do
    begin
      X := -Radius;
      while X<=w+radius do
      begin
        tx:=X;
        if tx<0 then tx:=0 else if tx>=w then tx:=w;
        sr1 := sa[X+Radius-1];
        C:=PColor32(ny + tx shl 2)^;
        with sa[X + Radius] do
        begin
          saA := sr1.saA + C shr 24;
          saR := sr1.saR + C shr 16 and $FF;
          saG := sr1.saG + C shr 8 and $FF;
          saB := sr1.saB + C and $FF;
        end;
        inc(X);
      end;
      for X := 0 to w do
      begin
        tx := X + Radius;
        sr1 := sa[tx + Radius];
        sr2 := sa[tx - 1 - Radius];
        PColor32(ny + X shl 2)^ := (sr1.saA - sr2.saA)*n shl 8 and $FF000000 or
        (sr1.saR - sr2.saR)*n and $FF0000 or
        (sr1.saG - sr2.saG)*n shr 8 and $FF00 or
        (sr1.saB - sr2.saB)*n shr 16;
      end;
    end;
    inc(ny, ptrD);
  end;

  SetLength(sa, h + 1 + (Radius*2));
  for X := 0 to w do
  begin
    for J := 1 to Passes do
    begin
      ny := Integer(s1);
      Y := -Radius;
      while Y <= h + Radius do
      begin
        if (Y > 0)and(Y < h) then inc(ny, ptrD);
        sr1 := sa[Y + Radius - 1];
        C := PColor32(ny + X shl 2)^;
        with sa[Y + Radius] do
        begin
          saA := sr1.saA + C shr 24;
          saR := sr1.saR + C shr 16 and $FF;
          saG := sr1.saG + C shr 8 and $FF;
          saB := sr1.saB + C and $FF;
        end;
        inc(Y);
      end;
      ny := Integer(s1);
      for Y := 0 to h do
      begin
        ty := Y + Radius;
        sr1 := sa[ty + Radius];
        sr2 := sa[ty - 1 - Radius];
        PColor32(ny + X shl 2)^ := (sr1.saA - sr2.saA)*n shl 8 and $FF000000 or
        (sr1.saR - sr2.saR)*n and $FF0000 or
        (sr1.saG - sr2.saG)*n shr 8 and $FF00 or
        (sr1.saB - sr2.saB)*n shr 16;
        inc(ny, ptrD);
      end;
    end;
  end;
  SetLength(sa, 0);
end;

function LoadPNGFromResource(const ResID: integer; var Img:TImage; restype:string = 'PNG'):boolean;
var
  png: TPngImage;
  rs: TResourceStream;
  h: HINST;
begin
  Result:=False;

  if FileExists(gSystem32+'imageres.dll')
  then
  begin
    h:=LoadLibrary(pchar( gSystem32+'imageres.dll') );
    try
      if h <> 0 then
      begin
          rs:=TResourceStream.CreateFromID(h,INT_PTR(ResID),pchar(Restype));
          rs.Position:=0;
          png:=TPngImage.Create;
          try
            png.LoadFromStream(rs);
            Img.Picture.Assign(png);
            Result:=True;
          finally
            png.Free;
          end;
      end;
    finally
      FreeLibrary(h);
    end;
  end
end;

procedure RegAutoStart;
var
key: string;
reg: TRegIniFile;
begin
key:='\Software\Microsoft\Windows\CurrentVersion\Run';
reg:=TRegIniFile.Create;
try
  reg.RootKey:=HKEY_CURRENT_USER;
  reg.CreateKey(key);
  if reg.OpenKey(Key,False) then reg.WriteString(key,'Win8StartScreen',pchar('"'+ParamStr(0)+'" -hidden'));
finally
  reg.Free;
end;
end;

procedure UnRegAutoStart;
var key: string;
     Reg: TRegIniFile;
begin
  key := '\Software\Microsoft\Windows\CurrentVersion\Run';
  Reg:=TRegIniFile.Create;
try
  Reg.RootKey:=HKEY_CURRENT_USER;
  if Reg.OpenKey(Key,False) then Reg.DeleteValue('Win8StartScreen');
  finally
  Reg.Free;
  end;
end;

procedure SetStartScreenBackground( Picture: TBitmap32; default:boolean = false);
var
  BlendFunc: TBlendFunction;
  bmppos: tpoint;
  bmpsize: tsize;
  src: TBitmap32;
  StartScreenHWND,TilesHWND: THandle;
  //r: TRect;
begin
  StartScreenHWND:=FindWindow('ImmersiveLauncher',nil);
  TilesHWND:=FindWindowEx(StartScreenHWND,0,'DirectUIHWND',nil);

  if StartScreenHWND <> 0 then
  begin

    //GetWindowRect(StartScreenHWND,r);

    bmppos:=point(0,0);

    bmpsize.cx:=picture.Width;
    bmpsize.cy:=picture.Height;

    BLENDFUNC.BlendOp:=AC_SRC_OVER;
    BLENDFUNC.BlendFlags:=0;
    BLENDFUNC.SourceConstantAlpha:=Form1.TrackBar1.Position;
    BLENDFUNC.AlphaFormat:=0;

    //it restores to original non alpha window to the start screen
    if default then
    begin
      src:=TBitmap32.Create;
      try
        //src.SetSize(Screen.Width,Screen.Height);
        src.SetSize(ScreenWidth, ScreenHeight);
        //src.FillRect(0,0,Screen.Width,Screen.Height,color32(0,0,0,0));
        src.FillRect(0,0,ScreenWidth,ScreenHeight,color32(0,0,0,0));

        //bmpsize.cx:=Screen.Width;
        bmpsize.cx:=ScreenWidth;
        //bmpsize.cy:=Screen.Height;
        bmpsize.cy:=ScreenHeight;

        //disable desktop wallpaper and slidesho
        WallpaperAsBG:=False;
        SlideshoOn:=False;

        UpdateLayeredWindow(
          StartScreenHWND,0,nil,@Bmpsize,
          src.Handle,@bmppos,0,@blendfunc,ULW_ALPHA);

        SetWindowLong(TilesHWND, GWL_EXSTYLE, GetWindowLong(TilesHWND, GWL_EXSTYLE) and not WS_EX_LAYERED);
      finally
        src.Free;
      end;
    end
    else
    begin
      //fix if not layered window set
      SetWindowLong(StartScreenHWND, GWL_EXSTYLE, GetWindowLong(StartScreenHWND, GWL_EXSTYLE) Or WS_EX_LAYERED);
       SetLayeredWindowAttributes(StartScreenHWND,0,Form1.TrackBar1.Position, LWA_ALPHA);

      UpdateLayeredWindow(
        StartScreenHWND,0,nil,@Bmpsize,
        picture.Handle,@bmppos,0,@blendfunc,ULW_ALPHA);

      //fit to screen
      //SetWindowPos(TilesHWND, StartScreenHWND, 0,0,r.Width,r.Height,SWP_NOACTIVATE);
    end;

  end;
end;
(* sin optimizar *)
(* procedure SetStartScreenBackground( Picture: TBitmap32; default:boolean = false);
var
  BlendFunc: TBlendFunction;
  BMP: TBitmap;
  bmppos: tpoint;
  bmpsize: tsize;
begin
  bmp:=TBitmap.Create;
  try
    bmp.PixelFormat:=pf32bit;
    bmp.SetSize(screen.Width,screen.Height);
    bmp.Canvas.Brush.Color:=clred;
    Picture.DrawTo(bmp.Canvas.Handle,0,0);

//    bmp.Canvas.FillRect(rect(0,0,bmp.Width,bmp.Height));
    bmppos:=point(0,0);
    if default then
    begin
      bmpsize.cx:=1;
      bmpsize.cy:=1;
    end
    else
    begin
      bmpsize.cx:=bmp.Width;
      bmpsize.cy:=bmp.Height;
    end;

    BLENDFUNC.BlendOp:=AC_SRC_OVER;
    BLENDFUNC.BlendFlags:=0;
    BLENDFUNC.SourceConstantAlpha:=Form1.TrackBar1.Position;
    BLENDFUNC.AlphaFormat:=0;

//    UpdateLayeredWindow(FindWindow('ImmersiveLauncher',nil),0,nil,@Bmpsize,bmp.Canvas.Handle,@bmppos,0,@blendfunc, ULW_ALPHA);
    UpdateLayeredWindow(
      FindWindow('ImmersiveLauncher',nil),
      0,
      nil,
      @Bmpsize,
      picture.BitmapHandle,
      @bmppos,
      0,
      @blendfunc,
       ULW_ALPHA);

  finally
    bmp.Free;
  end;
end; *)


procedure ChangeModernUIBackground(const value:integer);
var
  r: tregistry;
begin
  r:=TRegistry.Create;
  try
    r.RootKey:=HKEY_CURRENT_USER;
    if r.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\Accent',false) then
    begin
      if IsWin81 then
        r.WriteInteger('MotionAccentId_v1.00',value)
      else
        r.WriteInteger('AccentId_v8.00',value);
      Form1.Label1.Caption:='ModernUI Start Screen Background changed!';
      Form1.Timer1.Enabled:=True;
    end;
  finally
    r.Free;
  end;

  SetStartScreenBackground(form1.ImgView321.Bitmap,true);

(*  if FindWindow('ImmersiveLauncher',nil)<>0 then
  begin
    SetWindowLong(
      FindWindow('ImmersiveLauncher',nil),
      GWL_EXSTYLE,
      GetWindowLong(FindWindow('ImmersiveLauncher',nil), GWL_EXSTYLE) and not WS_EX_LAYERED);
    RedrawWindow(FindWindow('ImmersiveLauncher',nil),nil,0,RDW_ERASE or RDW_INVALIDATE or RDW_FRAME or RDW_ALLCHILDREN);
  end;*)

end;

function RunAsAdmin(hWnd: HWND; filename: string; Parameters: string): Boolean;
{
    See Step 3: Redesign for UAC Compatibility (UAC)
    http://msdn.microsoft.com/en-us/library/bb756922.aspx
}
var
    sei: TShellExecuteInfo;
begin
    if (ElevationType = 2) and (Elevation <> 0)then
    begin
      //is running as admin with full privileges
      ShellExecute(hWnd,'OPEN',PChar(filename),PChar(Parameters),nil,SW_HIDE);
      Result:=True;
    end
    else
    begin

    ZeroMemory(@sei, SizeOf(sei));
    sei.cbSize := SizeOf(TShellExecuteInfo);
    sei.Wnd := hwnd;
    sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
    sei.lpVerb := PChar('runas');
    sei.lpFile := PChar(Filename); // PAnsiChar;
    if parameters <> '' then
        sei.lpParameters := PChar(parameters); // PAnsiChar;
    sei.nShow := SW_HIDE;// SW_SHOWNORMAL; //Integer;

    Result := ShellExecuteEx(@sei);
    end;
end;

procedure ChangeModernUIColor(const value:integer);
var
  r: tregistry;
begin
  r:=TRegistry.Create;
  try
    r.RootKey:=HKEY_CURRENT_USER;
    if r.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\Accent',false) then
    begin
      r.WriteInteger('ColorSet_Version3',value-1);
      Form1.Label1.Caption:='ModernUI Start Screen Color changed ['+inttostr(value)+'], changes will be on next logon.';
      Form1.Timer1.Enabled:=True;
//      SendMessage(HWND_BROADCAST,WM_WININICHANGE,0,longint(pchar('ColorSet_Version3')));
//      SHChangeNotify(int_ptr($8000000),int_ptr($0),0,0);
//      SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_IDLIST,nil,nil);
//      KillProcess(FindWindow('ImmersiveLauncher',nil));

    end;
  finally
    r.Free;
  end;
end;


function Isit_INTResource(ResID: Integer): Boolean;
var
  i: Integer;
begin
  i := ResID shr 16;
  Result := i = 0;
end;

{
Usage:
UpdateResource('c:\windows\system32\imageres.dll','c:\mypics\newpic.png','PNG',PChar(10000));
}
function UpdateResourceBin(const ModulePath, FileName: string; ResourceType, ResourceName: PChar):boolean;
var
  hUpdate: THandle;
  fs: TFileStream;
  Data: Pointer;
begin
  Result:=True;
  if FileExists(FileName) then
  begin
    Data := nil;
    hUpdate := BeginUpdateResource(PChar(ModulePath), False);
    try
      if hUpdate <> 0 then
      begin      
        fs := TFileStream.Create(FileName, fmOpenRead);

        Data := AllocMem(fs.Size);
        fs.Read(Data^, fs.Size);

        if UpdateResource(hUpdate,MAKEINTRESOURCE(ResourceType), Pchar(ResourceName), ResLanguage, Data, fs.Size) then
        begin
          Result:=EndUpdateResource(hUpdate, False);
        end
        else Result:=False;
      end
      else Result:=False;
    finally
      if Data <> nil then
        FreeMem(Data);

      FreeAndNil(fs);
    end;
  end
  else Result:=False; //no file
end;



{function ProcessImages(Parameter: pointer): integer;
begin
  Result:=0;
  msgPtr:=Parameter;
  //aquí procesamos y luego enviamos mensaje de que terminó
  if UpdatePNGResource(customIcon,PChar(msgPtr.resourceID)) then
    PostMessage(Form1.Handle,TH_MESSAGE,TH_SUCCESS,0)
  else
    PostMessage(Form1.Handle,TH_MESSAGE,TH_ERROR,0);
  EndThread(0);
end;}

procedure RunAndWaitShell(Ejecutable,
                            Argumentos:string
                            ;Visibilidad:integer);
  var
     Info:TShellExecuteInfo;
     pInfo: PShellExecuteInfoW;// ^TShellExecuteInfo;
     exitCode:DWord;
  begin
     {Puntero a Info}
     {Pointer to Info}
     pInfo:=@Info;
     {Rellenamos Info}
     {Fill info}
     with Info do
     begin
      cbSize:=SizeOf(Info);
      fMask:=SEE_MASK_NOCLOSEPROCESS;
      //wnd:=Handle;
      lpVerb:=nil;
      lpFile:=PChar(Ejecutable);
      {Parametros al ejecutable}
      {Executable parameters}
      lpParameters:=Pchar(Argumentos+#0);
      lpDirectory:=pchar(temapath);
      nShow:=Visibilidad;
      hInstApp:=0;
     end;
     {Ejecutamos}
     {Execute}
     ShellExecuteEx(pInfo);

     {Esperamos que termine}
     {Wait to finish}
     repeat
      exitCode := WaitForSingleObject(Info.hProcess,500);
      Application.ProcessMessages;
     until (exitCode <> WAIT_TIMEOUT);
  end;


Function GetUserFromWindows: string;
Var
   UserName : string;
   UserNameLen : Dword;
Begin
   UserNameLen := 255;
   SetLength(userName, UserNameLen) ;
   If GetUserName(PChar(UserName), UserNameLen) Then
     Result := Copy(UserName,1,UserNameLen - 1)
   Else
     Result := 'Administrator';
End;

procedure PressWinI;
begin
        //enviamos ALT +ESC
      keybd_event(VK_LWIN,MapVirtualKey(VK_LWIN,0),0,0);
      Sleep(10);
      keybd_event(ord('I'),MapVirtualKey(ord('I'),0),0,0);
      Sleep(10);
      keybd_event(ord('I'),MapVirtualKey(ord('I'),0),KEYEVENTF_KEYUP,0);
      Sleep(100);
      keybd_event(VK_LWIN,MapVirtualKey(VK_LWIN,0),KEYEVENTF_KEYUP,0);
      Sleep(100);

end;

procedure PressWinC;
begin
        //enviamos ALT +ESC
      keybd_event(VK_LWIN,MapVirtualKey(VK_LWIN,0),0,0);
      Sleep(10);
      keybd_event(ord('C'),MapVirtualKey(ord('C'),0),0,0);
      Sleep(10);
      keybd_event(ord('C'),MapVirtualKey(ord('C'),0),KEYEVENTF_KEYUP,0);
      Sleep(100);
      keybd_event(VK_LWIN,MapVirtualKey(VK_LWIN,0),KEYEVENTF_KEYUP,0);
      Sleep(100);

end;

procedure PressEnd;
begin
      keybd_event(VK_END,MapVirtualKey(VK_END,0),0,0);
      Sleep(10);
      keybd_event(VK_END,MapVirtualKey(VK_END,0),KEYEVENTF_KEYUP,0);
      Sleep(100);
end;
procedure PressEnter;
begin
      //enviamos Enter
      keybd_event(VK_RETURN,0,0,0);
      Sleep(100);
      keybd_event(VK_RETURN,0,KEYEVENTF_KEYUP,0);
      Sleep(100);

end;


function GetDesktopWallpaper:string;
var
  r: TRegistry;
begin
  r := TRegistry.Create;
  try
    r.RootKey:=HKEY_CURRENT_USER;
    if r.OpenKeyReadOnly('\Control Panel\Desktop') then
    begin
      result:=r.ReadString('Wallpaper');
    end
    else
      result:='not found';
  finally
    r.Free;
  end;
end;

(*******************************************************************************
***********************************FORM*****************************************
********************************************************************************
*******************************************************************************)

procedure TForm1.ReadIni;
var
ini: TMemIniFile;
begin
// Leemos datos de inicialización
//usamos tmeminifile para almacenar nombres de archivos unicode
//thanks to http://stackoverflow.com/questions/16364869/how-do-i-read-a-utf8-encoded-ini-file
ini:=TMemIniFile.Create(ConfigFilePath, TEncoding.UTF8);

try
  if not FileExists(ConfigFilePath)then
  begin
    ini.WriteString('Settings','Picture','');
    ini.WriteInteger('Settings','Left',0);
    ini.WriteInteger('Settings','Top',0);
    ini.WriteInteger('Settings','Width',0);
    ini.WriteInteger('Settings','Height',0);
    ini.WriteInteger('Settings','Opacity',255);
    ini.WriteInteger('Settings','TilesOpacity',TrackBar2.Max);

    ini.WriteBool('Extra','UseDesktopWallpaper',False);
    ini.WriteBool('Extra','Gaussianblur',False);
    ini.WriteInteger('Extra','GaussianblurRatio',3);
    ini.WriteBool('Extra','Slideshow',False);
    ini.WriteInteger('Extra','SlideshowInterval',10);
    ini.WriteBool('Extra','Random',False);
    ini.WriteString('Settings','Language','English');
  end
  else
  begin
    bgpic:=ini.ReadString('Settings','Picture','');

    if FileExists(bgpic) then
    begin
      ImgView321.Bitmap.LoadFromFile(bgpic);

      //detect if this an animated gif file
      if UpperCase(ExtractFileExt(bgpic))='.GIF' then
      begin
        gif.LoadFromFile(bgpic);
        if gif.Images.Count > 1 then
        begin
          ImgView321.Bitmap.Width := gif.Width;
          ImgView321.Bitmap.Height := gif.Height;
          if gir <> nil then
            gir.Free;
          gir := TGIFRenderer.Create(gif);
          tmrgif.Interval := gif.AnimationSpeed;
          tmrgif.Enabled := True;
          gifon := True;
          chkGaussianBlur.Enabled := False;
          spinGaussian.Enabled := False;
        end
        else
        begin
          tmrgif.Enabled := False;
          gifon := False;
          chkGaussianBlur.Enabled := True;
          spinGaussian.Enabled := True;
        end;
      end
      else
      begin
        gifon := False;
        chkGaussianBlur.Enabled := True;
        spinGaussian.Enabled := True;
      end;

        //fix according to screen ratio
        Seleccionador.Location:=FloatRect(
          ini.ReadInteger('Settings','Left',0),
          ini.ReadInteger('Settings','Top',0),
          ini.ReadInteger('Settings','Left',0)+ini.ReadInteger('Settings','Width',160),
          ini.ReadInteger('Settings','Top',0)+
          (
          ini.ReadInteger('Settings','Width',160)
          )*(screenHeight/screenWidth)
        );

        Seleccionador.Visible:=True;

        if ImgView321.GetBitmapRect.Width >=ImgView321.GetBitmapRect.Height then
        begin
          Seleccionador.MaxWidth:=ImgView321.GetBitmapRect.Width;
          Seleccionador.MaxHeight:=Seleccionador.MaxWidth*(screenHeight/screenWidth);
        end
        else
        begin
          Seleccionador.MaxHeight:=ImgView321.GetBitmapRect.Height;
          Seleccionador.MaxWidth:=Seleccionador.MaxHeight*(screenWidth/screenHeight);
        end;
    end;

        TrackBar1.Position:=ini.ReadInteger('Settings','Opacity',255);
        TrackBar1Change(self);
        TrackBar2.Position:=ini.ReadInteger('Settings','TilesOpacity',TrackBar2.Max);
        TrackBar2Change(self);
        //let's load extra preferences
        chkDesktopWallpaper.Checked:=ini.ReadBool('Extra','UseDesktopWallpaper',False);
        chkGaussianBlur.Checked:=ini.ReadBool('Extra','Gaussianblur',False);
        spinGaussian.Value:=ini.ReadInteger('Extra','GaussianblurRatio',3);
        chkSlideShow.Checked:=ini.ReadBool('Extra','Slideshow',False);
        spinSlideInterval.Value:=ini.ReadInteger('Extra','SlideshowInterval',10);
        chkRandom.Checked:=ini.ReadBool('Extra','Random',False);

        cbLanguage.ItemIndex:=cbLanguage.Items.IndexOf(ini.ReadString('Settings','Language','English'));

        if not ImgView321.Bitmap.Empty  then
          btnPreviewClick(self);


  end;
finally
  ini.UpdateFile;
  ini.Free;
end;
end;


procedure TForm1.Iconito(var msg: TMessage);
var
p: TPoint;
begin
  if msg.LParam = WM_RBUTTONDOWN THen begin
    GetCursorPos(p);
    SystrayPopupMenu.Popup(p.X,p.Y );
    PostMessage(handle,WM_NULL,0,0)
  end
//  else if (msg.LParam = WM_LBUTTONDBLCLK)  and (Showing = false )then  Show//Modal
  else if (msg.LParam = WM_LBUTTONUP) and (Showing = False) then
  begin
    Show;
    ShowWindow(self.Handle,SW_SHOWNORMAL);
    SwitchToThisWindow(self.Handle,True);
  end;
end;

procedure TForm1.WriteIni;
var
ini: TMemIniFile;
begin

ini:=TMemIniFile.Create(ConfigFilePath, TEncoding.UTF8);
try
  ini.WriteString('Settings','Picture',bgpic);
  ini.WriteInteger('Settings','Left',trunc(Seleccionador.Location.Left));
  ini.WriteInteger('Settings','Top',trunc(Seleccionador.Location.Top));
  ini.WriteInteger('Settings','Width',trunc(Seleccionador.Location.Right-Seleccionador.Location.Left));
  ini.WriteInteger('Settings','Height',trunc(Seleccionador.Location.Bottom-Seleccionador.Location.Top));
  ini.WriteInteger('Settings','Opacity',TrackBar1.Position);
  ini.WriteInteger('Settings','TilesOpacity',TrackBar2.Position);
  ini.WriteString('Settings','Language',cbLanguage.Items[cbLanguage.ItemIndex]);

  ini.WriteBool('Extra','UseDesktopWallpaper',chkDesktopWallpaper.Checked);
  ini.WriteBool('Extra','Gaussianblur',chkGaussianBlur.Checked);
  ini.WriteInteger('Extra','GaussianblurRatio',spinGaussian.Value);
  ini.WriteBool('Extra','Slideshow',chkSlideShow.Checked);
  ini.WriteInteger('Extra','SlideshowInterval',spinSlideInterval.Value);
  ini.WriteBool('Extra','Random',chkRandom.Checked);

finally
  ini.UpdateFile;
  ini.Free;
end;
end;

procedure TForm1.ReadSlidesFromINI;
var
  Ini: TMemIniFile;
  list: string;
  i: Integer;
begin
  // Leemos datos de inicialización
  ini:=TMemIniFile.Create(ConfigFilePath, TEncoding.UTF8);
  try
    SlideshowPath:=ini.ReadString('Slideshow','Path','');
    list:=ini.ReadString('Slideshow','Pictures','');
    //parse to slideshowlist
    list:=StringReplace(list,' ','?',[rfReplaceAll]);
    SlideshowList.Clear;
    SlideshowList.Delimiter:='*';
    SlideshowList.DelimitedText:=list;
    for I := 0 to SlideshowList.Count-1 do
    begin
      SlideshowList[I]:=StringReplace(SlideshowList[I],'?',' ',[rfReplaceAll]);
    end;

    //apply extra preferences
    if chkDesktopWallpaper.Checked then
    begin
      tmrDesktop.Enabled:=True;
      WallpaperAsBG:=True;
      tmrSlideshow.Enabled:=False;
      SlideshoOn:=False;
      chkSlideShow.Checked:=False;
      chkDesktopWallpaperClick(self);
      btnPreviewClick(self);
    end
    else if chkSlideShow.Checked then
    begin
      tmrDesktop.Enabled:=False;
      WallpaperAsBG:=False;
      tmrSlideshow.Enabled:=True;
      SlideshoOn:=True;
      chkSlideShowClick(self);
      btnPreviewClick(self);
    end;

  finally
    ini.Free;
  end;
end;

procedure TForm1.ReadRegistry;
var
  R: TRegistry;
begin
  R:=TRegistry.Create;
  try
    R.RootKey:=HKEY_CURRENT_USER;
  finally
    if R.OpenKeyReadOnly('\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\Grid') then
    begin
      try
        SpinEdit1.Value:=R.ReadInteger('Layout_MaximumRowCount');
      except
        btnTilesRowRestore.Enabled:=False;
        SpinEdit1.Value:=4;
      end;
      R.CloseKey;
    end
    else
    begin
      MessageDlg('Your Windows 8 Registry has been altered, please fix it!',mtError,[mbOK],0);
    end;
    R.Free;
  end;
end;

procedure TForm1.SaveRegistry;
var
  R: TRegistry;
begin
  R:=TRegistry.Create;
  try
    R.RootKey:=HKEY_CURRENT_USER;
  finally
    if R.OpenKey('\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\Grid',True) then
    begin
      try
        R.WriteInteger('Layout_MaximumRowCount',SpinEdit1.Value);
        btnTilesRowRestore.Enabled:=True;
      except

      end;
      R.CloseKey;
    end
    else
    begin
      MessageDlg('Your Windows 8 Registry has been altered, please fix it!',mtError,[mbOK],0);
    end;
    R.Free;
  end;
end;

procedure TForm1.spinGaussianChange(Sender: TObject);
begin
  if chkGaussianBlur.Checked then
    chkGaussianBlurClick(self);
end;

procedure TForm1.AutoStartState;
var key: string;
     Reg: TRegIniFile;
begin
  key := '\Software\Microsoft\Windows\CurrentVersion\Run';
  Reg:=TRegIniFile.Create;
try
  Reg.RootKey:=HKEY_CURRENT_USER;
  if reg.ReadString(key,'Win8StartScreen','')=pchar('"'+ParamStr(0)+'" -hidden') then
  chkStartup.Checked:=true;
  finally
  Reg.Free;
  end;
end;

procedure TForm1.RestoreRegistry;
var
  R: TRegistry;
begin
  R:=TRegistry.Create;
  try
    R.RootKey:=HKEY_CURRENT_USER;
  finally
    if R.OpenKey('\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\Grid',True) then
    begin
      try
        R.DeleteValue('Layout_MaximumRowCount');
        btnTilesRowRestore.Enabled:=False;
      except

      end;
      R.CloseKey;
    end
    else
    begin
      MessageDlg('Your Windows 8 Registry has been altered, please fix it!',mtError,[mbOK],0);
    end;
    R.Free;
  end;
end;

procedure TForm1.ApplyChanges;
begin
  SHChangeNotify(134217728, 0, 0, 0);
  Sleep(1000);
  keybd_event(VK_LWIN,MapVirtualKey(VK_LWIN,0),0,0);
  Sleep(10);
  keybd_event(ord('Q'),MapVirtualKey(ord('Q'),0),0,0);
  Sleep(10);
  keybd_event(ord('Q'),MapVirtualKey(ord('Q'),0),KEYEVENTF_KEYUP,0);
  Sleep(100);
  keybd_event(VK_LWIN,MapVirtualKey(VK_LWIN,0),KEYEVENTF_KEYUP,0);
  Sleep(450);
  if FindWindow('SearchPane',nil)<>0 then
  begin
    PostMessage(handle,WM_SYSCOMMAND,SC_TASKLIST,0);
  end;
end;

procedure TForm1.WMDisplayChange(var Msg: TMessage);
begin
  //update background picture
  if FindWindow('ImmersiveLauncher',nil)<>0 then
    begin
      SetWindowLong(
        FindWindow('ImmersiveLauncher',nil),
        GWL_EXSTYLE,
        GetWindowLong(FindWindow('ImmersiveLauncher',nil), GWL_EXSTYLE) and not WS_EX_LAYERED);
      RedrawWindow(FindWindow('ImmersiveLauncher',nil),nil,0,RDW_ERASE or RDW_INVALIDATE or RDW_FRAME or RDW_ALLCHILDREN);

     SetWindowLong(FindWindow('ImmersiveLauncher',nil), GWL_EXSTYLE, GetWindowLong(FindWindow('ImmersiveLauncher',nil), GWL_EXSTYLE) Or WS_EX_LAYERED);
     SetLayeredWindowAttributes(FindWindow('ImmersiveLauncher',nil),0,TrackBar1.Position, LWA_ALPHA);
    end;

  btnPreviewClick(self);
  inherited;
end;

function ShowModalDimmed(Form, ParentForm: TForm): TModalResult;
var
  Back: TForm;
  i: Byte;
begin
  Back := TForm.Create(nil);
  try
    Back.Position := ParentForm.Position;
    Back.BorderStyle := bsnone;//ParentForm.BorderStyle;
    Back.BorderIcons := [];
    Back.AlphaBlend := true;
    Back.AlphaBlendValue := 0;
    Back.Color := clBlack;
    with ParentForm do Back.SetBounds(Left, Top, Width, Height);
    Back.Show;
    Back.Canvas.Brush.Color:=clBlack;
    Back.Canvas.FillRect(rect(0,0,ParentForm.Width,ParentForm.Height));
    for i := 1 to 100 do
    begin
      Back.AlphaBlendValue := i;
      Sleep(2)
    end;
    Form.Left := ParentForm.left + ((ParentForm.Width - Form.Width) div 2);
    Form.Top := ParentForm.Top + ((ParentForm.Height - Form.height) div 2);
    Result := Form.ShowModal
  finally
    Back.Free;
    ParentForm.BringToFront
  end
end;

procedure TForm1.MainFormModalShow(Sender: TObject);
begin
//  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) Or WS_EX_LAYERED);
//  SetLayeredWindowAttributes(Handle,0,180, LWA_ALPHA);
end;

procedure TForm1.MainFormModalHide(Sender: TObject);
begin
//  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) and not WS_EX_LAYERED);
end;

procedure TForm1.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WinClassName:='Win8StartScreen';
end;

procedure TForm1.WndProc(var Msg: TMessage);
begin
  if msg.Msg=fwm_TaskbarRestart then
  begin
    Shell_NotifyIcon(NIM_ADD,@icondata);
  end;
  inherited WndProc(Msg);
end;

procedure SaveTo8bitPNG(var bmp: TBitmap32;const filename: string);
var
  img: TImage;
  png: TPngImage;
  gif: TGIFImage;
begin
    //let's save it as png of 8bit
    img:=TImage.Create(Form1);
    try
      img.Picture.Assign(bmp);
      gif:=TGIFImage.Create;
      try
        gif.ColorReduction:=rmQuantizeWindows;
        gif.DitherMode:=dmFloydSteinberg;
        gif.Assign(img.Picture.Bitmap);
        img.Picture.Bitmap.PixelFormat:=pf8bit;
        img.Picture.Bitmap.Assign(gif.Bitmap);
      finally
        gif.Free;
      end;

      bmp.Assign(img.Picture);
      png:=TPngImage.Create;
      try
        png.Assign(img.Picture.Bitmap);
        png.SaveToFile(filename);
      finally
        png.Free;
      end;
    finally
      img.Free;
    end;
end;

procedure TForm1.btnCloseLogClick(Sender: TObject);
begin
  pnlLog.Visible:=False;
end;

procedure TForm1.btnExitClick(Sender: TObject);
type
  DEVICE_SCALE_FACTOR = (
    SCALE_100_PERCENT = 100,
    SCALE_140_PERCENT = 140,
    SCALE_180_PERCENT = 180
  );
var
  a,x,y : cardinal;
begin
//  GetScaleFactorForMonitor(MonitorFromWindow(FindWindow('ImmersiveLauncher',nil),MONITOR_DEFAULTTONEAREST),a);
//  showmessage(IntToStr(a));
 // GetDpiForMonitor(MonitorFromWindow(handle,MONITOR_DEFAULTTONEAREST),MONITOR_DPI_TYPE.MDT_Effective_DPI,x,y);
//  showmessage(IntToStr(x));
  close
end;

procedure TForm1.btnLoadPictureClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    bgpic:=OpenPictureDialog1.FileName;
    if FileExists(bgpic) then
    begin
      chkSlideShow.Checked:=False;
      chkDesktopWallpaper.Checked:=False;

      ImgView321.Bitmap.LoadFromFile(bgpic);

      //detect if this an animated gif file
      tmrgif.Enabled := False;
      if UpperCase(ExtractFileExt(bgpic))='.GIF' then
      begin
        gif.LoadFromFile(bgpic);
        if gif.Images.Count > 1 then
        begin
          ImgView321.Bitmap.Width := gif.Width;
          ImgView321.Bitmap.Height := gif.Height;
          if gir <> nil then
            gir.Free;
          gir := TGIFRenderer.Create(gif);
          tmrgif.Interval := gif.AnimationSpeed;
          tmrgif.Enabled := True;
          gifon := True;
          chkGaussianBlur.Enabled := False;
          spinGaussian.Enabled := False;
        end
        else
        begin
          tmrgif.Enabled := False;
          gifon := False;
          chkGaussianBlur.Enabled := True;
          spinGaussian.Enabled := True;
        end;
      end
      else
      begin
        gifon := False;
        chkGaussianBlur.Enabled := True;
        spinGaussian.Enabled := True;
      end;



      if (ImgView321.Bitmap.BoundsRect.Width < 160)
      or (ImgView321.Bitmap.BoundsRect.Height < 32*2) //just in case we want a full pic
      then
      begin
        MessageDlg('This picture is too small, select another one.',mtError,[mbOK],0);
        ImgView321.Bitmap:=nil;
        exit;
      end;

        Seleccionador.Location:=FloatRect(
          ImgView321.GetBitmapRect.Left,
          ImgView321.GetBitmapRect.Top,
          ImgView321.GetBitmapRect.Left+160,
          ImgView321.GetBitmapRect.Top+(screenHeight/screenWidth*160)
        );
        Seleccionador.Visible:=True;

        if ImgView321.GetBitmapRect.Width >=ImgView321.GetBitmapRect.Height then
        begin
          Seleccionador.MaxWidth:=ImgView321.GetBitmapRect.Width;
          Seleccionador.MaxHeight:=Seleccionador.MaxWidth*(screenHeight/screenWidth);
        end
        else
        begin
          Seleccionador.MaxHeight:=ImgView321.GetBitmapRect.Height;
          Seleccionador.MaxWidth:=Seleccionador.MaxHeight*(screenWidth/screenHeight);
        end;

    end;
  end;
end;



procedure TForm1.btnHideClick(Sender: TObject);
begin
  Hide;
  ShowWindow(Self.Handle,SW_HIDE);
end;

procedure TForm1.btnTilesRowApplyClick(Sender: TObject);
begin
  SaveRegistry;
  ApplyChanges;
end;

procedure TForm1.btnTilesRowRestoreClick(Sender: TObject);
begin
  RestoreRegistry;
  ReadRegistry;
  ApplyChanges;
end;

procedure TForm1.btnSlideshowClick(Sender: TObject);
begin
  frmMain.SetBounds(ImgView321.Left,ImgView321.Top,ImgView321.Width,ImgView321.Height);
  frmMain.Position:=poMainFormCenter;
    //update choose folder data
    frmMain.rkSmartPath1.Path:=SlideshowPath;
    frmMain.ListBox1.Items:=SlideshowList;
  //frmMain.ShowModal;
  ShowModalDimmed(frmMain,Self);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ShellExecute(handle,'OPEN',pchar('rundll32.exe'),pchar('shell32.dll,Control_RunDLL desk.cpl,,@desktop'),nil,SW_SHOWNORMAL);
end;

procedure TForm1.cbLanguageChange(Sender: TObject);
var
  LanguageIndex : integer;
  LanguageResOffset : integer;
begin
  //locate selected item (exit if not assigned)
  LanguageIndex := cbLanguage.ItemIndex;
  if LanguageIndex = -1 then Exit;

  //get language ofsset
  LanguageResOffset := Integer(cbLanguage.Items.Objects[LanguageIndex]);

  //change button caption
  btnLoadPicture.Caption := TResourceLocalizer.GetString(LanguageResOffset,1);
  btnPreview.Caption := TResourceLocalizer.GetString(LanguageResOffset,2);
  btnHide.Caption := TResourceLocalizer.GetString(LanguageResOffset,3);
  btnExit.Caption := TResourceLocalizer.GetString(LanguageResOffset,4);
  pageControl1.Pages[0].Caption := TResourceLocalizer.GetString(LanguageResOffset,5);
  pageControl1.Pages[1].Caption := TResourceLocalizer.GetString(LanguageResOffset,6);
  chkDesktopWallpaper.Caption := TResourceLocalizer.GetString(LanguageResOffset,7);
  chkGaussianBlur.Caption := TResourceLocalizer.GetString(LanguageResOffset,8);
  btnSlideshow.Caption := TResourceLocalizer.GetString(LanguageResOffset,9);
  chkSlideshow.Caption := TResourceLocalizer.GetString(LanguageResOffset,10);
  chkRandom.Caption := TResourceLocalizer.GetString(LanguageResOffset,11);
  lblInterval.Caption := TResourceLocalizer.GetString(LanguageResOffset,12);
  chkStartup.Caption := TResourceLocalizer.GetString(LanguageResOffset,13);
  lblStartScreenOpacityTB.Caption := TResourceLocalizer.GetString(LanguageResOffset,14);
  lblTilesOpacityTB.Caption := TResourceLocalizer.GetString(LanguageResOffset,15);
  img320x240.Hint:=TResourceLocalizer.GetString(LanguageResOffset,16);
  lblLike.Caption := TResourceLocalizer.GetString(LanguageResOffset,17);
  imgLike.Left := lblLike.Left+lblLike.Width + 10;
  lblSupport.Caption := TResourceLocalizer.GetString(LanguageResOffset,18);
  frmMain.Caption := TResourceLocalizer.GetString(LanguageResOffset,19);
  frmMain.btnSave.Caption := TResourceLocalizer.GetString(LanguageResOffset,20);
  frmMain.btnCancel.Caption := TResourceLocalizer.GetString(LanguageResOffset,21);
  lblLanguage.Caption := TResourceLocalizer.GetString(LanguageResOffset,22);
  lblRowsNumber.Caption := TResourceLocalizer.GetString(LanguageResOffset,23);
  btnTilesRowApply.Caption := TResourceLocalizer.GetString(LanguageResOffset,24);
  btnTilesRowRestore.Caption := TResourceLocalizer.GetString(LanguageResOffset,25);

  //messages
  msgHelp := TResourceLocalizer.GetString(LanguageResOffset,26);
end;

procedure TForm1.chkStartupClick(Sender: TObject);
begin
  if chkStartup.Checked then
    RegAutoStart
  else
    UnRegAutoStart;
end;

procedure TForm1.chkSlideShowClick(Sender: TObject);
begin
  if chkSlideShow.Checked then
  begin
    chkDesktopWallpaper.Checked:=False;
    chkDesktopWallpaperClick(self);
    Seleccionador.Visible:=False;
    //lets disable gif animation
    if gifon then
    begin
      tmrgif.Enabled := False;
      chkGaussianBlur.Enabled := True;
      spinGaussian.Enabled := True;
    end;

    if SlideshowList.Count > 0 then
    begin
      tmrSlideshow.Enabled:=chkSlideShow.Checked;
      tmrSlideshow.Interval:=spinSlideInterval.Value*1000; //in seconds
      startpos:=0;
      if chkRandom.Checked then
      begin
        //startpos:=Random(SlideshowList.Count-1);
        startpos:= RandomRange(0,SlideshowList.Count-1);
      end;
      //ImgView321.Bitmap.LoadFromFile(SlideshowPath+SlideshowList[startpos]);
      tmrSlideshowTimer(self);
    end
    else
    begin
      MessageDlg('You didn''t select the pictures yet.',mtInformation,[mbok],0);
      chkSlideShow.Checked:=False;
    end;
  end
  else
  begin

    Seleccionador.Visible:=True;

    if FileExists(bgpic) then
    begin
        ImgView321.Bitmap.LoadFromFile(bgpic);
        if gifon then
        begin
          tmrgif.Enabled := True;
          chkGaussianBlur.Enabled := False;
          spinGaussian.Enabled := False;
        end;
    end;
  end;
end;

function WindowSnap(eHandle: HWND;bmp:tbitmap):boolean;
var
  r:trect;
begin
  GetWindowRect(eHandle,r);
  bmp.Width:=r.Width;
  bmp.Height:=r.Height;
  bmp.Canvas.Lock;
  try
    result:=PrintWindow(eHandle, bmp.Canvas.Handle,0);
  finally
    bmp.Canvas.Unlock;
  end;
end;

function _disabled_WhichMonitorIsMain:integer;
var
  I: Integer;
begin
  for I := 0 to Screen.MonitorCount-1 do
  begin
    if (Screen.Monitors[I].Left=0) and (screen.Monitors[I].Top=0)then
    result:=I;
  end;
end;

procedure TForm1.ApplyWallpaper;
var
  r:trect;
  bmp: TBitmap;
  desktop:TBitmap32;
begin
  GetWindowRect(GetShellWindow,r);
    bmp:=TBitmap.Create;
    try
      WindowSnap(GetShellWindow,bmp);
      desktop:=TBitmap32.Create;
      try

        //desktop.SetSize(screen.Monitors[WhichMonitorIsMain].Width,screen.Monitors[WhichMonitorIsMain].Height);
        desktop.SetSize(ScreenWidth,ScreenHeight);
        //desktop.Canvas.CopyRect(rect(0,0,desktop.Width,desktop.Height),bmp.canvas, rect(abs(r.Left),abs(r.top),abs(r.left)+desktop.Width,abs(r.Top)+desktop.Height));
        desktop.Canvas.CopyRect(rect(0,0,desktop.Width,desktop.Height),bmp.canvas,
          rect(abs(r.Left),abs(r.top),abs(r.left)+desktop.Width,abs(r.Top)+desktop.Height));

        if chkGaussianBlur.Checked then
        begin
          //desktop.pixelformat:=pf24bit;
          //GBlur(desktop,spinGaussian.value,nil);
          FastBlur(desktop,spinGaussian.Value);
        end;

        ImgView321.Bitmap.Assign(desktop);

      finally
        desktop.Free;
      end;
    finally
      bmp.Free;
    end;
end;

procedure TForm1.chkDesktopWallpaperClick(Sender: TObject);
begin

  tmrDesktop.Enabled:=chkDesktopWallpaper.Checked;

  if chkDesktopWallpaper.Checked then
  begin

    chkSlideShow.Checked:=False;
    seleccionador.visible:=false;
    if gifon then
    begin
      tmrgif.Enabled := False;
      chkGaussianBlur.Enabled := True;
      spinGaussian.Enabled := True;
    end;

    ApplyWallpaper;
  end
  else
  begin
    WallpaperAsBG:=chkDesktopWallpaper.Checked;
    seleccionador.visible:=True;
    if FileExists(bgpic) then
    begin
      ImgView321.Bitmap.LoadFromFile(bgpic);
      if gifon then
      begin
        tmrgif.Enabled := True;
        chkGaussianBlur.Enabled := False;
        spinGaussian.Enabled := False;
      end;
    end;
  end;

//lets get picture straight from the desktop
{  if chkDesktopWallpaper.Checked then
  begin
    if FileExists(GetDesktopWallpaper) then
    ImgView321.Bitmap.LoadFromFile(GetDesktopWallpaper);
  end
  else
  begin
    if FileExists(bgpic) then
    begin
      ImgView321.Bitmap.LoadFromFile(bgpic);
    end;
  end;}
end;

procedure TForm1.chkGaussianBlurClick(Sender: TObject);
var
  bmp: tbitmap32;
begin
  if chkGaussianBlur.checked then
  begin
    bmp:=TBitmap32.create;
    try
      bmp.assign(imgview321.bitmap);
      //bmp.pixelformat:=pf24bit;
      //GBlur(bmp,spinGaussian.value,nil);
      FastBlur(bmp, spinGaussian.Value);
      imgview321.bitmap.assign(bmp);
    finally
      bmp.free;
    end;
  end
  else
  begin
    if chkDesktopWallpaper.Checked then
    begin
      chkDesktopWallpaperClick(self);
    end
    else
    if FileExists(bgpic) then
    begin
      ImgView321.Bitmap.LoadFromFile(bgpic);
    end;
  end;
end;

procedure TForm1.btnPreviewClick(Sender: TObject);
var
  src: TBitmap32;
  xr,yr: Single;
  selectesize: tfloatrect;
  k: TKernelResampler;
  d: TDraftResampler;

  xzr,yzr: Single;
  xdif,ydif:single; //difference
  nWidth,nHeight: single; //new width,height
begin
  //--to find out the resolution of the monitor where the start screen is located

  //let's see if wallpaper is bg
  WallpaperAsBG:=chkDesktopWallpaper.Checked;
  SlideshoOn:=chkSlideShow.Checked;

(* Let's generate our base picture *)
  if ImgView321.Bitmap.Empty then
  begin
    MessageDlg('Please load a picture first!',mtInformation,[mbOK],0);
    Exit;
  end;

  //boundsrect = real size | width = relative size

  //get relative size [x=width] [y=height]
  //xr = 1920/971=1.977342945417096
  xr:=ImgView321.Bitmap.BoundsRect.Width / ImgView321.GetBitmapRect.Width;
  yr:=ImgView321.Bitmap.BoundsRect.Height / ImgView321.GetBitmapRect.Height;


  selectesize:= Seleccionador.GetAdjustedLocation;

  src:=TBitmap32.Create;
  try
    (*if Win81DPIOn then
    begin
      if screen.Width = 1707 then
        src.SetSize(2560,1440);
    end
    else*)

    //src.SetSize(screen.Width,screen.Height);
    src.SetSize(ScreenWidth, ScreenHeight);

    d := TDraftResampler.Create(ImgView321.Bitmap);
//    d.Kernel := TLanczosKernel.Create;

    //let's adjust respecting current screen ratio
    (*if (ScreenWidth/ScreenHeight) <> (selectesize.right-selectesize.Left)/(selectesize.bottom-selectesize.Top) then
    begin
      //let's fix it
        xzr:=(selectesize.right-selectesize.Left)/(selectesize.bottom-selectesize.Top);
        //ratio to get the height with the width
        //yr:=Screen.Monitors[WhichMonitorIsMain].Height/Screen.Monitors[WhichMonitorIsMain].Width;
        yzr:=(selectesize.bottom-selectesize.Top)/(selectesize.right-selectesize.Left);
        //let's find which one is better
        xdif:=(selectesize.Right-selectesize.Left)-xzr*(selectesize.Bottom-selectesize.Top);
        ydif:=(selectesize.Bottom-selectesize.Top)-yzr*(selectesize.Right-selectesize.Left);
        if xdif>=0 then
        begin
          //this is great [we keep the ]
          //don't touch the height, use the width
          nHeight:=(selectesize.Bottom-selectesize.Top) / 2;
          nWidth:=(xzr*(selectesize.Bottom-selectesize.Top)) / 2;
        end
        else if ydif>=0 then
        begin
          //this one is better
          //don't touch the width, use the height
          nWidth:=(selectesize.Right-selectesize.Left) / 2;
          nHeight:=(yzr*(selectesize.Right-selectesize.Left)) / 2;
        end;
      ImgView321.Bitmap.DrawTo(src,src.BoundsRect,
      Rect(
        trunc( (selectesize.Left-ImgView321.GetBitmapRect.Left+nWidth)*xr),
        trunc( (selectesize.Top-ImgView321.GetBitmapRect.Top+nHeight)*yr),
        trunc( (selectesize.Right-ImgView321.GetBitmapRect.Left-nWidth)*xr),
        trunc( (selectesize.Bottom-ImgView321.GetBitmapRect.Top-nHeight)*yr))
      );
    end
    else*)
    begin
      xzr:=ScreenWidth/ScreenHeight;
      yzr:=ScreenHeight/ScreenWidth;
      //let's find which one is better
      xdif:=(selectesize.Right-selectesize.Left)-xzr*(selectesize.Bottom-selectesize.Top);
      ydif:=(selectesize.Bottom-selectesize.Top)-yzr*(selectesize.Right-selectesize.Left);
      if xdif>=0 then
      begin
        //this is great [we keep the ]
        //don't touch the height, use the width
        nHeight:=(selectesize.Bottom-selectesize.Top) / 2;
        nWidth:=(xzr*(selectesize.Bottom-selectesize.Top)) / 2;
      end
      else if ydif>=0 then
      begin
        //this one is better
        //don't touch the width, use the height
        nWidth:=(selectesize.Right-selectesize.Left) / 2;
        nHeight:=(yzr*(selectesize.Right-selectesize.Left)) / 2;
      end;

      (*ImgView321.Bitmap.DrawTo(src,src.BoundsRect,
      Rect(
        trunc( ( selectesize.Left-ImgView321.GetBitmapRect.Left  )*xr),
        trunc( ( selectesize.Top-ImgView321.GetBitmapRect.Top    )*yr),
        trunc( ( selectesize.Right-ImgView321.GetBitmapRect.Left )*xr),
        trunc( ( selectesize.Bottom-ImgView321.GetBitmapRect.Top )*yr))
      );*)
      ImgView321.Bitmap.DrawTo(src,src.BoundsRect,
      Rect(
        trunc( ( (selectesize.Left-ImgView321.GetBitmapRect.Left +selectesize.Right-ImgView321.GetBitmapRect.Left) / 2 - nWidth )*xr),
        trunc( ( (selectesize.Top-ImgView321.GetBitmapRect.Top + selectesize.Bottom-ImgView321.GetBitmapRect.Top) / 2 - nHeight  )*yr),
        trunc( ( (selectesize.Left-ImgView321.GetBitmapRect.Left +selectesize.Right-ImgView321.GetBitmapRect.Left) / 2 + nWidth )*xr),
        trunc( ( (selectesize.Top-ImgView321.GetBitmapRect.Top + selectesize.Bottom-ImgView321.GetBitmapRect.Top) / 2 + nHeight )*yr))
      );
    end;
//    k.Kernel.Free;
//    k.Free;
    //lets paint on desktop canvas
    Desk := TDesktopCanvas.Create;
    try
    //ImgView321.Bitmap.DrawTo(Desk.DC);
    Desk.FloodFill(0,0,clRed, fsSurface);
    finally
      Desk.Free;
    end;

    if chkDesktopWallpaper.checked or chkSlideShow.Checked then
    begin
    //needs to resize according to monitor resolution
    //...
        SetStartScreenBackground(imgview321.bitmap);
    end
    else
        SetStartScreenBackground(src);
    if Sender = btnPreview then
      PostMessage(Handle,WM_SYSCOMMAND,SC_TASKLIST,0);
    WriteINI;

  finally
    src.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SetPriorityClass(GetCurrentProcess, $4000);//below normal al parecer mejor de IDLE
//  SetProcessDPIAware;
  fwm_TaskbarRestart:=RegisterWindowMessage('TaskbarCreated');
  caption:='Windows 8 Start Screen Customizer '+AppVersion;
  //caption := 'StartScreen8 ' + AppVersion;

  lblSupport.Caption:='If you like this tool, maybe you would want to show your support :) ';

  if not CheckWin32Version(6,2) then
  begin
    ShowMessage('This tool is only for Windows 8');
    Application.Terminate;
  end;

//  ShowMessage(IntToStr(RealScreenWidthResolution));
  //check if is running windows 8.1
  IsWin81 := IsWindows81;  //RTM is set to on if finds build 9600

  //disable things that we won't use on win8.1
  if IsWin81 then
  begin
    //see if dpi is on
    Win81DPIOn := IsWin8DpiScalingOn;

    if not IsWin81RTM then
    begin
    Image15.Enabled := False;
    Image16.Enabled := False;
    Image17.Enabled := False;
    Image18.Enabled := False;
    Image19.Enabled := False;
    end;
    Image20.Enabled := False;
    Image502x52.Visible := False;

    // disable row changer since it won't work now that win81 has bigger tiles
    Shape1.Visible := False;
    lblRowsNumber.Visible := False;
    SpinEdit1.Visible := False;
    btnTilesRowApply.Visible := False;
    btnTilesRowRestore.Visible := False;
  end;

  IsElevated;

  //load languages
  TResourceLocalizer.GetLanguages(cbLanguage.Items);


  if (ElevationType = 2)and(Elevation<>0) then
    MessageDlg('There is no need to start this application as admin.',mtWarning,[mbok],0);

  Position:=poScreenCenter;

  if (ParamCount=1) and (ParamStr(1)='-hidden') then
  Application.ShowMainForm:=False;
  if Pos(GetSpecialFolderPath(CSIDL_PROGRAM_FILESX86,False),ExtractFilePath(ParamStr(0)))=1 then
  begin
    //it is running from program files directory
    if not DirectoryExists(GetSpecialFolderPath(CSIDL_APPDATA,False)+'\Win8StartMenuCustomizer') then
      CreateDir(GetSpecialFolderPath(CSIDL_APPDATA,False)+'\Win8StartMenuCustomizer');
    ConfigFilePath:=GetSpecialFolderPath(CSIDL_APPDATA,False)+'\Win8StartMenuCustomizer\config.ini';
  end
  else
    ConfigFilePath:=ExtractFilePath(ParamStr(0))+'config.ini';

  //slideshow list
  SlideshowList:=TStringList.Create;
  //load global paths
  IsWin8x64 := Is64BitOS;
  gAppDir:=ExtractFilePath(ParamStr(0));
  gTempDir:=gAppDir+'temp\';

  if Is64BitOS then
  begin
    gSysnative:=GetWindowsDir+'sysnative\'; //sysnative = system32
  end
  else
  begin
    gSysnative:=GetWindowsDir+'system32\';
  end;
  gSystem32:=GetWindowsDir+'system32\'; //it links to syswow64 if 64bit otherwise remains system32

(*  if not DirectoryExists(gTempDir) then
    if not CreateDir(gTempDir) then
    begin
      MessageDlg('Place this executable in a writable directory.',mtError,[mbok],0);
      Application.Terminate;
    end;*)


  if IsWin81 and not IsWin81RTM then
  begin
    LoadPNGFromResource(Themes81[1],Image1);
    LoadPNGFromResource(Themes81[2],Image2);
    LoadPNGFromResource(Themes81[3],Image3);
    LoadPNGFromResource(Themes81[4],Image4);
    LoadPNGFromResource(Themes81[5],Image5);
    LoadPNGFromResource(Themes81[6],Image6);
    LoadPNGFromResource(Themes81[7],Image7);
    LoadPNGFromResource(Themes81[8],Image8);
    LoadPNGFromResource(Themes81[9],Image9);
    LoadPNGFromResource(Themes81[10],Image10);
    LoadPNGFromResource(Themes81[11],Image11);
    LoadPNGFromResource(Themes81[12],Image12);
    LoadPNGFromResource(Themes81[13],Image13);
    LoadPNGFromResource(Themes81[14],Image14);

    Panel2.Top := Panel2.Top - 70;
  end
  else if IsWin81RTM then
  begin
    LoadPNGFromResource(Themes81RTM[1], Image1);
    LoadPNGFromResource(Themes81RTM[2], Image2);
    LoadPNGFromResource(Themes81RTM[3], Image3);
    LoadPNGFromResource(Themes81RTM[4], Image4);
    LoadPNGFromResource(Themes81RTM[5], Image5);
    LoadPNGFromResource(Themes81RTM[6], Image6);
    LoadPNGFromResource(Themes81RTM[7], Image7);
    LoadPNGFromResource(Themes81RTM[8], Image8);
    LoadPNGFromResource(Themes81RTM[9], Image9);
    LoadPNGFromResource(Themes81RTM[10], Image10);
    LoadPNGFromResource(Themes81RTM[11], Image11);
    LoadPNGFromResource(Themes81RTM[12], Image12);
    LoadPNGFromResource(Themes81RTM[13], Image13);
    LoadPNGFromResource(Themes81RTM[14], Image14);
    LoadPNGFromResource(Themes81RTM[15], Image15);
    LoadPNGFromResource(Themes81RTM[16], Image16);
    LoadPNGFromResource(Themes81RTM[17], Image17);
    LoadPNGFromResource(Themes81RTM[18], Image18);
    LoadPNGFromResource(Themes81RTM[19], Image19);
  end
  else
  begin
    LoadPNGFromResource(Themes[1],Image1);
    LoadPNGFromResource(Themes[2],Image2);
    LoadPNGFromResource(Themes[3],Image3);
    LoadPNGFromResource(Themes[4],Image4);
    LoadPNGFromResource(Themes[5],Image5);
    LoadPNGFromResource(Themes[6],Image6);
    LoadPNGFromResource(Themes[7],Image7);
    LoadPNGFromResource(Themes[8],Image8);
    LoadPNGFromResource(Themes[9],Image9);
    LoadPNGFromResource(Themes[10],Image10);
    LoadPNGFromResource(Themes[11],Image11);
    LoadPNGFromResource(Themes[12],Image12);
    LoadPNGFromResource(Themes[13],Image13);
    LoadPNGFromResource(Themes[14],Image14);
    LoadPNGFromResource(Themes[15],Image15);
    LoadPNGFromResource(Themes[16],Image16);
    LoadPNGFromResource(Themes[17],Image17);
    LoadPNGFromResource(Themes[18],Image18);
    LoadPNGFromResource(Themes[19],Image19);
    LoadPNGFromResource(Themes[20],Image20);
  end;

  LoadPNGFromResource(4800,Image502x52,'IMAGE');

  if IsWin81 then
  LoadPNGFromResource(Themes81[1],img320x240)
  else
  LoadPNGFromResource(Themes[1]+4,img320x240);

  Label1.Caption:='';

  temapath:=gAppDir; //set to app folder
  apppath:=gAppDir; //set to app folder


  Constraints.MinHeight:=Height;
  Constraints.MinWidth:=Width;

  Seleccionador:=TSeleccionador.Create(ImgView321.Layers);
  Seleccionador.MinHeight:=32;
  Seleccionador.MinWidth:=160;
  Seleccionador.Location := FloatRect(0, 0, 160 - 1, 32 - 1);
  Seleccionador.FillColor:=Color32(49,101,185);
  Seleccionador.Handles:=Seleccionador.Handles-[rhSides];
//  Seleccionador.Scaled:=true;
  Seleccionador.Options:= [roProportional, roConstrained];

{  with ImgView321.PaintStages[0]^ do
    if Stage = PST_CLEAR_BACKGND then Stage:=PST_CUSTOM;
  ImgView321.RepaintMode:=rmOptimizer;}
  Seleccionador.OnResizing:=Seleccionador.GetResize;
//  Seleccionador.OnConstrain:=Seleccionador.Limitando;
  Seleccionador.Visible:=False;
  Seleccionador.HandleSize:=3;
//  Seleccionador.Scaled:=True;

  ImgView321.ScaleMode:=smOptimalScaled;

  ReadRegistry;

  with IconData do
begin
  cbSize:=IconData.SizeOf;
//  sizeof(IconData);
  wnd:=handle;
  Uid:=100;
  uFlags:=NIF_MESSAGE+NIF_ICON+NIF_TIP;
  uCallbackMessage:=WM_USER+1;
  hIcon:=Application.Icon.Handle;
  StrPCopy(szTip,'Windows 8 Start Screen Customizer')
end;
  Shell_NotifyIcon(NIM_ADD,@IconData);

  //GIF
  gif := TGIFImage.Create;
  gif.OnProgress := OnProgress;

  AutoStartState;
  ReadSlidesFromINI;
  ReadINI;


  //modal show
  Application.OnModalBegin:=MainFormModalShow;
  Application.OnModalEnd:=MainFormModalHide;


end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE,@IconData);
  SlideshowList.Free;
  if gir <> nil then
    gir.Free;
  gif.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
        cbLanguageChange(self);
end;

procedure TForm1.Image10Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(204);
    LoadPNGFromResource(Themes81[10],img320x240);
  end
  else begin
    ChangeModernUIBackground(109);
    LoadPNGFromResource(Themes[10]+4,img320x240);
  end;
end;

procedure TForm1.Image11Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(210);
    LoadPNGFromResource(Themes81[11],img320x240);
  end
  else begin
    ChangeModernUIBackground(110);
    LoadPNGFromResource(Themes[11]+4,img320x240);
  end;
end;

procedure TForm1.Image12Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(202);
    LoadPNGFromResource(Themes81[12],img320x240);
  end
  else begin
    ChangeModernUIBackground(111);
    LoadPNGFromResource(Themes[12]+4,img320x240);
  end;
end;

procedure TForm1.Image13Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(201);
    LoadPNGFromResource(Themes81[13],img320x240);
  end
  else begin
    ChangeModernUIBackground(112);
    LoadPNGFromResource(Themes[13]+4,img320x240);
  end;
end;

procedure TForm1.Image14Click(Sender: TObject);
begin
  if IsWin81 and not IsWin81RTM then
  begin
    ChangeModernUIBackground(218);
    LoadPNGFromResource(Themes81[14],img320x240);
  end
  else if IsWin81RTM then
  begin
    ChangeModernUIBackground(214);
    LoadPNGFromResource(Themes81RTM[14],img320x240);
  end
  else begin
    ChangeModernUIBackground(113);
    LoadPNGFromResource(Themes[14]+4,img320x240);
  end;
end;

procedure TForm1.Image15Click(Sender: TObject);
begin
  if IsWin81RTM then
  begin
    ChangeModernUIBackground(215);
    LoadPNGFromResource(Themes81RTM[15],img320x240);
  end
  else begin
    ChangeModernUIBackground(114);
    LoadPNGFromResource(Themes[15]+4,img320x240);
  end;
end;

procedure TForm1.Image16Click(Sender: TObject);
begin
  if IsWin81RTM then
  begin
    ChangeModernUIBackground(216);
    LoadPNGFromResource(Themes81RTM[16],img320x240);
  end
  else begin
    ChangeModernUIBackground(115);
    LoadPNGFromResource(Themes[16]+4,img320x240);
  end;
end;

procedure TForm1.Image17Click(Sender: TObject);
begin
  if IsWin81RTM then
  begin
    ChangeModernUIBackground(220);
    LoadPNGFromResource(Themes81RTM[17],img320x240);
  end
  else begin
    ChangeModernUIBackground(116);
    LoadPNGFromResource(Themes[17]+4,img320x240);
  end;
end;

procedure TForm1.Image18Click(Sender: TObject);
begin
  if IsWin81RTM then
  begin
    ChangeModernUIBackground(221);
    LoadPNGFromResource(Themes81RTM[18],img320x240);
  end
  else begin
    ChangeModernUIBackground(117);
    LoadPNGFromResource(Themes[18]+4,img320x240);
  end;
end;

procedure TForm1.Image19Click(Sender: TObject);
begin
  if IsWin81RTM then
  begin
    ChangeModernUIBackground(222);
    LoadPNGFromResource(Themes81RTM[19],img320x240);
  end
  else begin
    ChangeModernUIBackground(118);
    LoadPNGFromResource(Themes[19]+4,img320x240);
  end;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(217);
    LoadPNGFromResource(Themes81[1],img320x240);
  end
  else begin
    ChangeModernUIBackground(100);
    LoadPNGFromResource(Themes[1]+4,img320x240);
  end;
end;

procedure TForm1.Image20Click(Sender: TObject);
begin
  ChangeModernUIBackground(119);
  LoadPNGFromResource(Themes[20]+4,img320x240);
end;

procedure TForm1.imgLikeClick(Sender: TObject);
begin
  lblLikeClick(Self);
end;

procedure TForm1.img320x240Click(Sender: TObject);
begin
  PostMessage(handle,WM_SYSCOMMAND,SC_TASKLIST,0);
end;

procedure TForm1.imgBtnDonateClick(Sender: TObject);
var
durl : AnsiString;
begin
//any amount by default
    //durl := 'DGTZ4YZSMWKLJ';
    durl := 'XEM9D85W8TE9Y';

  if cbDonate.ItemIndex = 0 then
    //3 dollars
    //durl := '6S34CNXAKM69G'
    durl := 'WGXYFUJKFDTB8'
  else if cbDonate.ItemIndex = 1 then
    //5 dollars
    //durl := 'Q73PT6CD3APWQ'
    durl := 'LDH3P9UGN7CTQ'
  else if cbDonate.ItemIndex = 2 then
    //10 dollars
    //durl := '8FNYMAD2HPAA6'
    durl := 'KBWCV2Y58F72S'
  else if cbDonate.ItemIndex = 3 then
    //20 dollars
    durl := 'ZES9QCMJDSQMA'
  else if cbDonate.ItemIndex = 4 then
    //50 dollars
    durl := 'FRK23VWVQDX3W'
  else if cbDonate.ItemIndex = 5 then
    //100 dollars
    durl := 'VJEM7T6S4ST2W'
  else if cbDonate.ItemIndex = 6 then
    //any amount
    //durl := 'DGTZ4YZSMWKLJ';
    durl := 'XEM9D85W8TE9Y';

    ShellExecuteA(Handle, 'open', PAnsiChar('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id='+durl), nil, nil, SW_SHOW);
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(206);
    LoadPNGFromResource(Themes81[2],img320x240);
  end
  else begin
    ChangeModernUIBackground(101);
    LoadPNGFromResource(Themes[2]+4,img320x240);
  end;
end;

procedure TForm1.Image3Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(212);
    LoadPNGFromResource(Themes81[3],img320x240);
  end
  else begin
    ChangeModernUIBackground(102);
    LoadPNGFromResource(Themes[3]+4,img320x240);
  end;
end;

procedure TForm1.Image4Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(208);
    LoadPNGFromResource(Themes81[4],img320x240);
  end
  else begin
    ChangeModernUIBackground(103);
    LoadPNGFromResource(Themes[4]+4,img320x240);
  end;
end;

procedure TForm1.Image502x52Click(Sender: TObject);
var
  curpos: TPoint;
  x: integer;
  d: integer;
  v: integer;
begin
//lets launch pc settings app
//  WinExec('C:\WINDOWS\ImmersiveControlPanel\SystemSettings.exe -ServerName:microsoft.windows.immersivecontrolpanel',SW_NORMAL);
  PressWinI;
  PressEnd;
  PressEnter;

  exit;
  try
    curpos:=ScreenToClient(Mouse.CursorPos);
  except
    //break
    exit;
  end;
  x:=CurPos.X - Image502x52.Left;
  d:= Image502x52.Width div 25;
  v:=Ceil(x/d);
  ChangeModernUIColor(v);

end;

procedure TForm1.Image5Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(209);
    LoadPNGFromResource(Themes81[5],img320x240);
  end
  else begin
    ChangeModernUIBackground(104);
    LoadPNGFromResource(Themes[5]+4,img320x240);
  end;
end;

procedure TForm1.Image6Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(205);
    LoadPNGFromResource(Themes81[6],img320x240);
  end
  else begin
    ChangeModernUIBackground(105);
    LoadPNGFromResource(Themes[6]+4,img320x240);
  end;
end;

procedure TForm1.Image7Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(203);
    LoadPNGFromResource(Themes81[7],img320x240);
  end
  else begin
    ChangeModernUIBackground(106);
    LoadPNGFromResource(Themes[7]+4,img320x240);
  end;
end;

procedure TForm1.Image8Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(213);
    LoadPNGFromResource(Themes81[8],img320x240);
  end
  else begin
    ChangeModernUIBackground(107);
    LoadPNGFromResource(Themes[8]+4,img320x240);
  end;
end;

procedure TForm1.Image9Click(Sender: TObject);
begin
  if IsWin81 then
  begin
    ChangeModernUIBackground(200);
    LoadPNGFromResource(Themes81[9],img320x240);
  end
  else begin
    ChangeModernUIBackground(108);
    LoadPNGFromResource(Themes[9]+4,img320x240);
  end;
end;






procedure TForm1.lblLikeClick(Sender: TObject);
begin
  lblLike.Visible:=False;
  imgLike.Visible:=False;
  Form1.pnlLog.Visible:=True;
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  ShellExecute(Handle, 'OPEN',pchar('http://apps.codigobit.info'),nil,nil,SW_SHOWNORMAL);
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
  MessageDlg('Windows 8 Start Screen Customizer '+AppVersion+#13
              +msgHelp
              ,mtInformation,[mbok],0);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Label1.Caption:='';
  Timer1.Enabled:=False;
end;

procedure TForm1.tmrDesktopTimer(Sender: TObject);
var
  bmp: TBitmap;
  desktop:tbitmap32;
  r:trect;
  edad:int64;
begin
  edad:=FileAge(GetDesktopWallpaper);
//  caption:=inttostr(edad);
  if WallpaperAge <> edad then
  begin
    WallpaperAge:=edad;
    GetWindowRect(GetShellWindow,r);
    bmp:=TBitmap.Create;
    try
      WindowSnap(GetShellWindow,bmp);
      desktop:=TBitmap32.Create;
      try
        try
        //desktop.SetSize(screen.Monitors[WhichMonitorIsMain].Width,screen.Monitors[WhichMonitorIsMain].Height);
        desktop.SetSize(ScreenWidth,ScreenHeight);
        except
        desktop.SetSize(screenWidth,screenHeight); //v1.3.7
        end;
        desktop.Canvas.CopyRect(rect(0,0,desktop.Width,desktop.Height),bmp.canvas,
          rect(abs(r.Left),abs(r.top),abs(r.left)+desktop.Width,abs(r.Top)+desktop.Height));

        if chkGaussianBlur.Checked then
        begin
          //desktop.pixelformat:=pf24bit;
          //GBlur(desktop,spinGaussian.value,nil);
          FastBlur(desktop, spinGaussian.Value);
        end;
        ImgView321.Bitmap.Assign(desktop);

        if WallpaperAsBG then
        begin
          //lets apply
          btnPreviewClick(self);
        end;
      finally
        desktop.Free;
      end;
    finally
      bmp.Free;
    end;
   end;
end;

procedure TForm1.tmrfixsizeTimer(Sender: TObject);
var
  wnd: HWND;
  r: TRect;
begin
  wnd := FindWindow('ImmersiveLauncher',nil);
  if (wnd <>0) and not ImgView321.Bitmap.Empty then
  begin
    GetWindowRect(wnd,r);
    if (scrWith <> r.Width) or (scrHeight <> r.Height) then
    begin
      //update
      scrWith := r.Width;
      scrHeight := r.Height;
       //caption:='changed '+ inttostr(random(123));
      if chkDesktopWallpaper.Checked then
        applywallpaper
      else if chkSlideShow.Checked then
        applySlide
      else
        btnPreviewClick(self);

      //update tiles container to make it fit perfectly

    end;

  end;
end;

procedure TForm1.tmrgifTimer(Sender: TObject);
begin
  try
  gir.Draw(ImgView321.Bitmap.Canvas,ImgView321.Bitmap.Canvas.ClipRect);
  except
    //some weird thing happened with TCanvas memory pointing to unknown location
  end;
  ImgView321.Bitmap.ResetAlpha; //to fix blueish
  tmrgif.Interval := gir.FrameDelay; //to respect the original delay of each frame
  gir.NextFrame;


  //if focused the start screen, lets animate on there
  if (GetForegroundWindow = FindWindow('ImmersiveLauncher',nil))
//  and not chkSlideShow.Enabled
  then
  begin
    btnPreviewClick(self);
  end;
end;

procedure TForm1.ApplySlide;
var
  bmp: TBitmap32;
//  square: single; //to crop
  xr,yr:single; //screeratio
  xdif,ydif:single; //difference
  nWidth,nHeight: single; //new width,height
begin
  nWidth := 1;
  nHeight := 1;

//adjust to screen resolution
  if FileExists(SlideshowPath+SlideshowList[startpos]) then
  try
    ImgView321.Bitmap.LoadFromFile(SlideshowPath+SlideshowList[startpos]);
    bmp:=TBitmap32.Create;
    try


      //bmp.SetSize(screen.Monitors[WhichMonitorIsMain].Width,screen.Monitors[WhichMonitorIsMain].Height);
      bmp.SetSize(ScreenWidth,ScreenHeight);

      //let's first reduce workarea to a square, then we will be able to crop correctly
      //according to our screen resolution

      (*if ImgView321.Bitmap.BoundsRect.Width < ImgView321.Bitmap.BoundsRect.Height then
        square:=ImgView321.Bitmap.BoundsRect.Width
      else
        square:=ImgView321.Bitmap.BoundsRect.Height; *)

        //ratio to get the width with the height
        //xr:=Screen.Monitors[WhichMonitorIsMain].Width/Screen.Monitors[WhichMonitorIsMain].Height;
        xr:=ScreenWidth/ScreenHeight;
        //ratio to get the height with the width
        //yr:=Screen.Monitors[WhichMonitorIsMain].Height/Screen.Monitors[WhichMonitorIsMain].Width;
        yr:=ScreenHeight/ScreenWidth;
        //let's find which one is better
        xdif:=ImgView321.Bitmap.BoundsRect.Width-xr*ImgView321.Bitmap.BoundsRect.Height;
        ydif:=ImgView321.Bitmap.BoundsRect.Height-yr*ImgView321.Bitmap.BoundsRect.Width;
        if xdif>=0 then
        begin
          //this is great [we keep the ]
          //don't touch the height, use the width
          nHeight:=ImgView321.Bitmap.BoundsRect.Height / 2;
          nWidth:=(xr*ImgView321.Bitmap.BoundsRect.Height) / 2;
        end
        else if ydif>=0 then
        begin
          //this one is better
          //don't touch the width, use the height
          nWidth:=ImgView321.Bitmap.BoundsRect.Width / 2;
          nHeight:=(yr*ImgView321.Bitmap.BoundsRect.Width) / 2;
        end;
      ImgView321.Bitmap.DrawTo(bmp,bmp.BoundsRect,rect(
        trunc((ImgView321.Bitmap.BoundsRect.Width div 2)-nWidth),
        trunc((ImgView321.Bitmap.BoundsRect.Height div 2)-nHeight),
        trunc((ImgView321.Bitmap.BoundsRect.Width div 2)+nWidth),
        trunc((ImgView321.Bitmap.BoundsRect.Height div 2)+nHeight)
      ));
      if chkGaussianBlur.Checked then
      begin
        G32Blur(bmp,spinGaussian.value,nil);
      end;
      ImgView321.Bitmap.Assign(bmp);
      //if SlideshoOn then  //temporary fix TO ALLOW SLIDESHOW WITHOUT APPLY BUTTON
        btnPreviewClick(self);
    finally
      bmp.Free;
    end;
  except

  end;
end;


procedure TForm1.tmrSlideshowTimer(Sender: TObject);
begin

  if chkSlideShow.Checked (*and (GetForegroundWindow = FindWindow('ImmersiveLauncher',nil))*)then
  begin
    if SlideshowList.Count > 0 then
    begin
      tmrSlideshow.Enabled:=chkSlideShow.Checked;
      tmrSlideshow.Interval:=spinSlideInterval.Value*1000; //in seconds
      if startpos = SlideshowList.Count-1 then
        startpos:=0
      else
        Startpos:=Startpos+1;

      if chkRandom.Checked then
      begin
        startpos:=Random(SlideshowList.Count-1);
        // RandomRange(0,SlideshowList.Count-1);
      end;

      ApplySlide;

    end
    else
    begin
      MessageDlg('You didn''t select the pictures yet.',mtInformation,[mbok],0);
      chkSlideShow.Checked:=False;
    end;
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  StartScreenHWND: THandle;
begin
  lblStartScreenOpacity.Caption:=inttostr(TrackBar1.Position);
{  if TrackBar1.Position = 255 then
  begin
    if FindWindow('ImmersiveLauncher',nil)<>0 then
    begin
      SetWindowLong(
        FindWindow('ImmersiveLauncher',nil),
        GWL_EXSTYLE,
        GetWindowLong(FindWindow('ImmersiveLauncher',nil), GWL_EXSTYLE) and not WS_EX_LAYERED);
      RedrawWindow(FindWindow('ImmersiveLauncher',nil),nil,0,RDW_ERASE or RDW_INVALIDATE or RDW_FRAME or RDW_ALLCHILDREN);
    end;
  end
  else}
  begin
    StartScreenHWND:=FindWindow('ImmersiveLauncher',nil);
    if StartScreenHWND <>0 then
    begin
     SetWindowLong(StartScreenHWND, GWL_EXSTYLE, GetWindowLong(StartScreenHWND, GWL_EXSTYLE) Or WS_EX_LAYERED);
     SetLayeredWindowAttributes(StartScreenHWND,0,TrackBar1.Position, LWA_ALPHA);
  //   SetWindowPos(Handle,HWND_TOPMOST,Left,Top,Width, Height,SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOSIZE);

    end;

  end;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
var
  StartScreenHWND,TilesHWND: THandle;
begin
    StartScreenHWND:=FindWindow('ImmersiveLauncher',nil);
    if StartScreenHWND <>0 then
    begin
     //let's apply the same effect to icons
     TilesHWND:=FindWindowEx(StartScreenHWND,0,'DirectUIHWND',nil);
     if TilesHWND<>0 then
     begin
      if TrackBar2.Position=TrackBar2.Max then
      begin
        SetWindowLong(TilesHWND, GWL_EXSTYLE, GetWindowLong(TilesHWND, GWL_EXSTYLE) and not WS_EX_LAYERED);
        lblTilesOpacity.Caption:='OFF';
      end
      else
      begin
        SetWindowLong(TilesHWND, GWL_EXSTYLE, GetWindowLong(TilesHWND, GWL_EXSTYLE) Or WS_EX_LAYERED);
        lblTilesOpacity.Caption:=inttostr(TrackBar2.Position);
        if TrackBar2.Position > 180 then
        lblTilesOpacity.Caption:='DARK';
      end;
//      SetLayeredWindowAttributes(TilesHWND,clBlack,TrackBar2.Position,LWA_ALPHA or LWA_COLORKEY);
      SetLayeredWindowAttributes(TilesHWND,clBlack,TrackBar2.Position,LWA_ALPHA);
     end;
    end;
end;

procedure TForm1.OnProgress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
begin
  if Stage = psEnding then
  begin
    ProgressBar1.Visible := False;
    ProgressBar1.Position := 0;
  end
  else
  begin
    ProgressBar1.Visible := True;
    ProgressBar1.Position := PercentDone;
  end;

end;

end.
