unit Viewer_src;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus;

type
  TForm2 = class(TForm)
    Image1: TImage;
    ScrollBox1: TScrollBox;
    PopupMenu1: TPopupMenu;
    Close1: TMenuItem;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Close1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure ScrollWheel(var msg: TMessage);
  public
    { Public declarations }
  end;
type
  Comodin = class(TControl);
var
  Form2: TForm2;

implementation

{$R *.dfm}


procedure TForm2.Close1Click(Sender: TObject);
begin
close
end;

procedure TForm2.ScrollWheel(var msg: TMessage);
var
  cant: short;
  i:integer;
begin
  if msg.Msg = WM_MOUSEWHEEL then
  begin
    cant:=HiWord(msg.WParam);
    cant:=cant div 120;
    ScrollBox1.HorzScrollBar.Smooth:=True;

//    ScrollBox1.ScrollBy(cant*10,0);
    ScrollBox1.HorzScrollBar.Position:=ScrollBox1.HorzScrollBar.Position-cant*50;
{    for I := 1 to abs(cant) do
    begin
      if cant>0 then
      begin
        //prior
        ScrollBox1.ScrollBy(cant,0);
      end
      else if cant <1 then
      begin
        //next
        ScrollBox1.ScrollBy(-cant,0);
      end;
    end;  }
  end
  else
  Comodin(Form2).WndProc(msg);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Self.WindowProc:=ScrollWheel;
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = chr(27) then
  close;
end;

procedure TForm2.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//  ReleaseCapture;
//  Perform(WM_SYSCOMMAND,$F012,nil);

end;

end.
