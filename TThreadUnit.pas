unit TThreadUnit;

interface

uses
  Classes, Windows, SysUtils, ExtCtrls, Graphics,Jpeg, GIFimg, PNGimage, ModernUIStartScreen_src, GR32, Math;

const
  TH_CROP = 1;
  TH_CHANGE = 2;
type
  TMyThread = class(TThread)
  private
    FForm: TForm1;
    FPicture: TBitmap32;
    FPicArea: TRect; //gui viewer picture size not real pic size
    FCropArea: TFloatRect;
    FArchivo: String; //file to process
    FAction: Integer; //constans to use, 0: cortar y crear PNG,1:cambiar png en la DLL
    FStep: Integer;
    FNextStep: Integer;
    procedure SetArchivo(const Value: String);
    procedure SetAction(const Value: Integer);
    procedure SetStep(const Value: Integer);
    procedure SetNextStep(const Value: Integer);
  protected
    procedure Execute; override;
  public
    constructor Create(const AForm: TForm1);
    procedure SetPicture(const Pic: TBitmap32);
    procedure SetCropArea(const CropArea: TFloatRect);
    procedure SetPicArea(const PicArea: TRect);
    property Archivo: String read FArchivo write SetArchivo;
    property Action: Integer read FAction write SetAction;
    property Step: Integer read FStep write SetStep;
    property NextStep: Integer read FNextStep write SetNextStep;
  end;

implementation

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TMyThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end;
    
    or 
    
    Synchronize( 
      procedure 
      begin
        Form1.Caption := 'Updated in thread via an anonymous method'
      end
      )
    );

  where an anonymous method is passed.
  
  Similarly, the developer can call the Queue method with similar parameters as 
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.
    
}


procedure SaveTo8bitPNG(var bmp: TBitmap32;const filename: string);
var
  img: TImage;
  png: TPngImage;
  gif: TGIFImage;
begin
    //let's save it as png of 8bit
    img:=TImage.Create(nil);
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

{ TMyThread }

constructor TMyThread.Create(const AForm: TForm1);
begin
  //
  inherited Create(True);
  FreeOnTerminate:= True;
  FForm:=AForm;
end;

procedure TMyThread.Execute;
var
  xr,yr: single; //aspect ratio
  tmp: TBitmap32;
  colors: array [0..5] of TColor32;
begin
  NameThreadForDebugging('Procesador');
  { Place thread code here }
  case FAction of
    TH_CROP:
    begin
      //real cropping
      xr:=FPicture.BoundsRect.Width / FPicArea.Width;
      yr:=FPicture.BoundsRect.Height / FPicArea.Height;

      case FStep of
        CROP_ICON:
        begin
          tmp:=TBitmap32.Create;
          try
            tmp.SetSize(105,105);
            FPicture.DrawTo(tmp,tmp.BoundsRect,
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (FCropArea.Top-FPicArea.Top)*yr),
                     trunc( (FCropArea.Left-FPicArea.Left+
                     (FCropArea.Bottom - FCropArea.Top))*yr),
                     trunc( (FCropArea.Bottom-FPicArea.Top)*yr)) );
            SaveTo8bitPNG(tmp,gTempDir+'pic_icon.png');
          finally
            tmp.Free;
          end;
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,FNextStep),
                      LongInt(PChar('Cropped Icon PNG')));
        end;
        CROP_PREVIEW:
        begin
          tmp:=TBitmap32.Create;
          try
            tmp.SetSize(896,674); //preview pic
            FPicture.DrawTo(tmp,tmp.BoundsRect,
              Rect( trunc((FCropArea.Left-FPicArea.Left)*xr ),
                    trunc((FCropArea.Top-FPicArea.Top)*yr),
                    trunc((FCropArea.Left-FPicArea.Left+
                     896/674*(FCropArea.Bottom - FCropArea.Top))*yr),
                    trunc( (FCropArea.Bottom-FPicArea.Top)*yr)
            ));
                  //lets paint a watermark :P ... just for testing purposes

              with tmp do
              begin
                //lets create our colors
                colors[0]:=Color32(0,153,171); //verde celestudo
                colors[1]:=Color32(44,135,239); //celeste
                colors[2]:=Color32(96,60,187); //violeta
                colors[3]:=Color32(0,164,0); //verde
                colors[4]:=Color32(37,160,219); //celeste opaco
                colors[5]:=Color32(218,84,44); //naranja

                //first tile
                FillRect(104,156,104+274,156+132,Colors[math.RandomRange(0,5)]);

                //2nd tile
                FillRect(104,298,104+132,298+132,Colors[math.RandomRange(0,5)]);

                //3rd tile
                FillRect(246,298,246+132,298+132,Colors[math.RandomRange(0,5)]);

                //4th tile
                FillRect(104,440,104+132,440+132,Colors[math.RandomRange(0,5)]);

                //5th tile
                FillRect(246,440,246+132,440+132,Colors[math.RandomRange(0,5)]);

                //6th tile
                FillRect(388,156,388+274,156+132,Colors[math.RandomRange(0,5)]);

                //7th tile
                FillRect(388,298,388+274,298+132,Colors[math.RandomRange(0,5)]);

                //8th tile
                FillRect(388,440,388+274,440+132,Colors[math.RandomRange(0,5)]);

                //9th tile
                FillRect(672,156,672+132,156+132,Colors[math.RandomRange(0,5)]);

                //10th tile
                FillRect(672,298,672+132,298+132,Colors[math.RandomRange(0,5)]);

                //11th tile
                FillRect(672,440,672+132,440+132,Colors[math.RandomRange(0,5)]);
              end;
            SaveTo8bitPNG(tmp,gTempDir+'pic_preview.png');
          finally
            tmp.Free;
          end;
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,FNextStep),
                      LongInt(PChar('Cropped Preview PNG')));
        end;
        CROP_SMALL:
        begin
          tmp:=TBitmap32.Create;
          try
            tmp.SetSize(2000,400);
            if fullpic then
            begin
              FPicture.DrawTo(tmp,
                rect(0,0,2000,292),
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (FCropArea.Top-FPicArea.Top)*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                     trunc( (
                              (FCropArea.Top-FPicArea.Top)
                              +((FCropArea.Bottom-FPicArea.Top)
                              -(FCropArea.Top-FPicArea.Top))/2*0.73
                             )*yr))
                );
              FPicture.DrawTo(tmp,
                rect(0,292,2000,400),
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (
                              (FCropArea.Bottom-FPicArea.Top)
                              -((FCropArea.Bottom-FPicArea.Top)
                              -(FCropArea.Top-FPicArea.Top))/2*0.27
                             )*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                     trunc( (FCropArea.Bottom-FPicArea.Top)*yr)) );
            end
            else
              FPicture.DrawTo(tmp,tmp.BoundsRect,
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (FCropArea.Top-FPicArea.Top)*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                     trunc( (FCropArea.Bottom-FPicArea.Top)*yr)) );
            SaveTo8bitPNG(tmp,gTempDir+'pic_2000x400.png');
          finally
            tmp.Free;
          end;
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,FNextStep),
                      LongInt(PChar('Cropped Small (2000x400) PNG')));
        end;
        CROP_MEDIUM:
        begin
          tmp:=TBitmap32.Create;
          try
            tmp.SetSize(3000,600);
            if fullpic then
            begin
              FPicture.DrawTo(tmp,
                rect(0,0,3000,438),
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (FCropArea.Top-FPicArea.Top)*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                     trunc( (
                              (FCropArea.Top-FPicArea.Top)
                              +((FCropArea.Bottom-FPicArea.Top)
                              -(FCropArea.Top-FPicArea.Top))/2*0.73
                             )*yr))
                );
              FPicture.DrawTo(tmp,
                rect(0,438,3000,600),
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (
                              (FCropArea.Bottom-FPicArea.Top)
                              -((FCropArea.Bottom-FPicArea.Top)
                              -(FCropArea.Top-FPicArea.Top))/2*0.27
                             )*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                     trunc( (FCropArea.Bottom-FPicArea.Top)*yr)) );
            end
            else
              FPicture.DrawTo(tmp,tmp.BoundsRect,
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (FCropArea.Top-FPicArea.Top)*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                     trunc( (FCropArea.Bottom-FPicArea.Top)*yr)) );
            SaveTo8bitPNG(tmp,gTempDir+'pic_3000x600.png');
          finally
            tmp.Free;
          end;
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,FNextStep),
                      LongInt(PChar('Cropped Small (3000x600) PNG')));
        end;
        CROP_LARGE:
        begin
          tmp:=TBitmap32.Create;
          try
            tmp.SetSize(3500,800);
            if fullpic then
            begin
              FPicture.DrawTo(tmp,
                rect(0,0,3500,584),
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (FCropArea.Top-FPicArea.Top)*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                                          trunc( (
                              (FCropArea.Top-FPicArea.Top)
                              +((FCropArea.Bottom-FPicArea.Top)
                              -(FCropArea.Top-FPicArea.Top))/2*0.73
                             )*yr))
                );
              FPicture.DrawTo(tmp,
                rect(0,584,3500,800),
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (
                              (FCropArea.Bottom-FPicArea.Top)
                              -((FCropArea.Bottom-FPicArea.Top)
                              -(FCropArea.Top-FPicArea.Top))/2*0.27
                             )*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                     trunc( (FCropArea.Bottom-FPicArea.Top)*yr)) );
            end
            else
              FPicture.DrawTo(tmp,tmp.BoundsRect,
                Rect(trunc( (FCropArea.Left-FPicArea.Left)*xr ),
                     trunc( (FCropArea.Top-FPicArea.Top)*yr),
                     trunc( (FCropArea.Right-FPicArea.Left)*xr),
                     trunc( (FCropArea.Bottom-FPicArea.Top)*yr)) );
            SaveTo8bitPNG(tmp,gTempDir+'pic_3500x800.png');
          finally
            tmp.Free;
          end;
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,FNextStep),
                      LongInt(PChar('Cropped Small (3500x800) PNG')));
        end;
      end;
    end;
    TH_CHANGE:
    begin
      // when we are going to replace DLL resource
      case (Step-11000) div 8 of //0:icons,1:smalls,2:mediums,3:larges,4:previews
        0: //icons
        begin
          if FForm.chkIcon.Checked then
          begin
            try
              UpdateResourceBin(gImageRes,customIcon,'PNG',PChar(DLLs[Step-11000]));
              processed:=True;
              SendMessage(FForm.Handle,
                          TH_MESSAGE,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Changed Icon resource: '
                                          +inttostr(DLLs[Step-11000])
//                                          +' - next step='+IntToStr(FNextStep)
                          )));
            except
              SendMessage(FForm.Handle,
                          TH_ERROR,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Couldn''t replace resource'
                          )));
            end;
          end
          else
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,11008),
                      LongInt(PChar( 'Trying with Small'
                      )));
        end;
        1: //smalls
        begin
          if FForm.chkSmall.Checked then
          begin
            try
              UpdateResourceBin(gImageRes,customSmall,'PNG',PChar(DLLs[Step-11000]));
              processed:=True;
              SendMessage(FForm.Handle,
                          TH_MESSAGE,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Changed Small resource: '
                                          +inttostr(DLLs[Step-11000])
  //                                        +' - next step='+IntToStr(FNextStep)
                          )));
            except
              SendMessage(FForm.Handle,
                          TH_ERROR,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Couldn''t replace resource'
                          )));
            end;
          end
          else
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,11016),
                      LongInt(PChar( 'Trying with Medium'
                      )));
        end;
        2: // mediums
        begin
          if FForm.chkMedium.Checked then
          begin
            try
              UpdateResourceBin(gImageRes,customMedium,'PNG',PChar(DLLs[Step-11000]));
              processed:=True;
              SendMessage(FForm.Handle,
                          TH_MESSAGE,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Changed Medium resource: '
                                          +inttostr(DLLs[Step-11000])
//                                          +' - next step='+IntToStr(FNextStep)
                          )));
            except
              SendMessage(FForm.Handle,
                          TH_ERROR,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Couldn''t replace resource'
                          )));
            end;
          end
          else
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,11024),
                      LongInt(PChar( 'Trying with Large'
                      )));
        end;
        3: // larges
        begin
          if FForm.chkLarge.Checked then
          begin
            try
              UpdateResourceBin(gImageRes,customLarge,'PNG',PChar(DLLs[Step-11000]));
              processed:=True;
              SendMessage(FForm.Handle,
                          TH_MESSAGE,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Changed Large resource: '
                                          +inttostr(DLLs[Step-11000])
//                                          +' - next step='+IntToStr(FNextStep)
                          )));
            except
              SendMessage(FForm.Handle,
                          TH_ERROR,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Couldn''t replace resource'
                          )));
            end;
          end
          else
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,11032),
                      LongInt(PChar( 'Trying with Preview'
                      )));
        end;
        4: // previews
        begin
          if FForm.chkPreview.Checked then
          begin
            try
              UpdateResourceBin(gImageRes,customPreview,'PNG',PChar(DLLs[Step-11000]));
              processed:=True;
              SendMessage(FForm.Handle,
                          TH_MESSAGE,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Changed Preview resource: '
                                          +inttostr(DLLs[Step-11000])
//                                          +' - next step='+IntToStr(FNextStep)
                          )));
            except
              SendMessage(FForm.Handle,
                          TH_ERROR,
                          MakeWParam(TH_SUCCESS,FNextStep),
                          LongInt(PChar( 'Couldn''t replace resource'
                          )));
            end;
          end
          else
          SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,11040),
                      LongInt(PChar( 'Finishing...'
                      )));
        end;
        5:
         SendMessage(FForm.Handle,
                      TH_MESSAGE,
                      MakeWParam(TH_SUCCESS,DLL_LAST),
                      LongInt(PChar('Completed: '+inttostr(DLLs[Step-11000]))));
      end;
    end;
  end;

end;

procedure TMyThread.SetArchivo(const Value: String);
begin
  FArchivo:=Value;
end;

procedure TMyThread.SetAction(const Value: Integer);
begin
  FAction:=Value;
end;

procedure TMyThread.SetStep(const Value: Integer);
begin
  FStep:=Value;
end;

procedure TMyThread.SetNextStep(const Value: Integer);
begin
  FNextStep:=Value;
end;

procedure TMyThread.SetPicture(const Pic: TBitmap32);
begin
  FPicture:=Pic;
end;

procedure TMyThread.SetCropArea(const CropArea: TFloatRect);
begin
  FCropArea:=CropArea;
end;

procedure TMyThread.SetPicArea(const PicArea: TRect);
begin
  FPicArea:=PicArea;
end;

end.
