program ModernUIStartScreen;

{$IFOPT D-}{$WEAKLINKRTTI ON}{$ENDIF}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

uses
  Vcl.Forms,
  Windows,
  Dialogs,
  ModernUIStartScreen_src in 'ModernUIStartScreen_src.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  ChooseFolder_src in 'ChooseFolder_src.pas' {frmMain},
  GBlur2 in 'GBlur2.pas';


{$R *.res}
{$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED}

begin
  if (FindWindow('Win8StartScreen',nil)>0) then
  begin
//    MessageDlg('Application is already running in systray.',mtInformation,[mbok],0);
    ShowWindow(FindWindow('Win8StartScreen',nil),SW_SHOWNORMAL);
    SwitchToThisWindow(FindWindow('Win8StartScreen',nil),True);
    exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Light');
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
