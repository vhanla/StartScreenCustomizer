{
VideoMonitor - Copyright 2002-2005, eSite Media, Inc.
http://www.videomonitor.ca

This file is part of VideoMonitor.

VideoMonitor is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

VideoMonitor is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VideoMonitor; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit GBlur2;

interface

uses Windows, Graphics, Gr32;

const MaxKernelSize = 100;

type
   TProgressEvent = procedure(Sender: TObject; PercentDone: Byte) of object;
   TKernelSize = 1..MaxKernelSize;
   TKernel = record
     Size: TKernelSize;
     Weights: array[-MaxKernelSize..MaxKernelSize] of single;
  end;
//the idea is that when using a TKernel you ignore the Weights
//except for Weights in the range -Size..Size.

procedure GBlur(theBitmap: TBitmap; radius: double; Progress: TProgressEvent);
procedure G32Blur(theBitmap: TBitmap32;radius:double;Progress: TProgressEvent);
implementation

uses SysUtils;

type
    PRGBTriple = ^TRGBTriple;
    TRGBTriple = packed record
     b: byte; //easier to type than rgbtBlue...
     g: byte;
     r: byte;
    end;

    PRow = ^TRow;
    TRow = array[0..1000000] of TRGBTriple;

    PPRows = ^TPRows;
    TPRows = array[0..1000000] of PRow;

procedure MakeGaussianKernel(var K: TKernel; radius: double;
                            MaxData, DataGranularity: double);
// makes K into a gaussian kernel with standard deviation = radius.
// for the current application you set MaxData = 255,
// DataGranularity = 1. Now the procedure sets the value of
// K.Size so that when we use K we will ignore the Weights
// that are so small they can't possibly matter. (Small Size
// is good because the execution time is going to be
// propertional to K.Size.)
var
 j: integer;
 temp, delta: double;
 KernelSize: TKernelSize;
begin
  for j:= Low(K.Weights) to High(K.Weights) do
  begin
    temp:= j/radius;
    K.Weights[j]:= exp(- temp*temp/2);
  end;
  temp := 0;        //now divide by constant so sum(Weights) = 1:
  for j:= Low(K.Weights) to High(K.Weights) do
     temp:= temp + K.Weights[j];
  for j:= Low(K.Weights) to High(K.Weights) do
     K.Weights[j] := K.Weights[j] / temp;

  //now discard (or rather mark as ignorable by setting Size)
  //the entries that are too small to matter -
  //this is important, otherwise a blur with a small radius
  //will take as long as with a large radius...
  KernelSize:= MaxKernelSize;
  delta:= DataGranularity / (2*MaxData);
  temp:= 0;
  while (temp < delta) and (KernelSize > 1) do
  begin
    temp:= temp + 2 * K.Weights[KernelSize];
    dec(KernelSize);
  end;
  K.Size:= KernelSize;
  //now just to be correct go back and jiggle again so the
  //sum of the entries we'll be using is exactly 1:
  temp:= 0;
  for j:= -K.Size to K.Size do temp:= temp + K.Weights[j];
  for j:= -K.Size to K.Size do K.Weights[j]:= K.Weights[j] / temp;
end;

function TrimInt(Lower, Upper, theInteger: integer): integer;
begin
 if (theInteger <= Upper) and (theInteger >= Lower) then
  result:= theInteger
 else
  if theInteger > Upper then
   result:= Upper
    else
     result:= Lower;
end;

function TrimReal(Lower, Upper: integer; x: double): integer;
begin
 if (x < upper) and (x >= lower) then
  result:= trunc(x)
 else
  if x > Upper then
   result:= Upper
    else
     result:= Lower;
end;

procedure BlurRow(var theRow: array of TRGBTriple; K: TKernel; P: PRow);
var
 j, n, LocalRow: integer;
 tr, tg, tb: double;   //  temp Red, temp Green, temp blue
 w: double;
begin
  for j:= 0 to High(theRow) do
  begin
    tb:= 0;
    tg:= 0;
    tr:= 0;
    for n:= -K.Size to K.Size do
    begin
      w:= K.Weights[n];
      // the TrimInt keeps us from running off the edge of the row...
      with theRow[TrimInt(0, High(theRow), j - n)] do
      begin
        tb:= tb + w * b;
        tg:= tg + w * g;
        tr:= tr + w * r;
      end;
    end;
    with P[j] do
    begin
      b:= TrimReal(0, 255, tb);
      g:= TrimReal(0, 255, tg);
      r:= TrimReal(0, 255, tr);
    end;
  end;
  Move(P[0], theRow[0], (High(theRow) + 1) * Sizeof(TRGBTriple));
end;

procedure GBlur(theBitmap: TBitmap; radius: double; Progress: TProgressEvent);
var
  Row, Col: integer;
  theRows: PPRows;
  K: TKernel;
  ACol: PRow;
  P: PRow;
begin
  if (theBitmap.HandleType <> bmDIB) or (theBitmap.PixelFormat <> pf24Bit) then
  raise exception.Create('GBlur only works for 24-bit bitmaps');
  MakeGaussianKernel(K, radius, 255, 1);
  GetMem(theRows, theBitmap.Height * SizeOf(PRow));
  GetMem(ACol, theBitmap.Height * SizeOf(TRGBTriple));
  //record the location of the bitmap data:
  for Row:= 0 to theBitmap.Height - 1
    do theRows[Row]:= theBitmap.Scanline[Row];

  //  blur each row
  P:= AllocMem(theBitmap.Width*SizeOf(TRGBTriple));
  for Row:= 0 to theBitmap.Height - 1 do
    begin
       BlurRow(Slice(theRows[Row]^, theBitmap.Width), K, P);
      if Assigned(Progress) then
        Progress(nil,Row*50 div (theBitmap.Height-1));
    end;

  // blur each column
  ReAllocMem(P, theBitmap.Height*SizeOf(TRGBTriple));
  for Col:= 0 to theBitmap.Width - 1 do
  begin
    //  first read the column into a TRow:
    for Row:= 0 to theBitmap.Height - 1 do ACol[Row]:= theRows[Row][Col];
    BlurRow(Slice(ACol^, theBitmap.Height), K, P);
    //now put that row, um, column back into the data:
    for Row:= 0 to theBitmap.Height - 1 do theRows[Row][Col]:= ACol[Row];
    if Assigned(Progress) then
      Progress(nil,50+Col*50 div (theBitmap.Width-1));
  end;
  FreeMem(theRows);
  FreeMem(ACol);
  ReAllocMem(P, 0);
end;

procedure G32Blur(theBitmap: TBitmap32;radius:double;Progress: TProgressEvent);
var
  bmp: TBitmap;
begin
  bmp:=TBitmap.Create;
  try
    bmp.Assign(theBitmap);
    bmp.PixelFormat:=pf24bit;
    GBlur(bmp,radius,progress);
    theBitmap.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

end.
