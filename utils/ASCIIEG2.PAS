program SaveASCIItoFileTurboPascal7;
uses Graph, Crt;

var
  Gd, Gm: Integer;
  F: Text;
  x, y, i, j, xs, ys: Integer;
  pixel: Byte;
  binaryStr: string;
  symbol: Char;

{ ��楤�� ��� ������ ᨬ���� � 䠩� � �����? �?��୨� �浪?� }
procedure SaveSymbolToFile(asciiCode: Integer; binaryData: array of string);
var
  k: Integer;
begin
  WriteLn(F, '    ; ������ ', asciiCode, ': ', symbol);  { ������� ��� ᨬ���� � ���� �।�⠢����� }
  for k := 0 to 7 do
    WriteLn(F, '    db ', binaryData[k], 'b');  { ������� ����� �?��୨� �冷� }
  WriteLn(F);
end;

{ ��楤�� ��� ���㢠��� �?�ᥫ?� ᨬ���� � �� ���⢮७�� � �?��୨� �ଠ� }
procedure GetSymbolPixels(asciiCode: Integer; xss: Integer; yss: Integer);
var
  binaryData: array[0..7] of string;
  pixelValue: Integer;
  asciiCodeStr: String;
  ii: Integer;
begin
  symbol := Chr(asciiCode);  { ���⢮��� ��� ASCII � ᨬ��� }
  Str(asciiCode, asciiCodeStr);  { ���⢮��� ��� ᨬ���� � �冷� ��� ��������� }
  
  { �������� ��� ᨬ���� � ����쮬� �?���� ���? ��࠭� }
  SetColor(15);
  OutTextXY(0, 0, asciiCodeStr);
  
  { ��⠭����� �⨫� ⥪��� � �������� ᨬ��� �� �����?� (xss, yss) }
  SetTextStyle(DefaultFont, 0, 1);
  OutTextXY(xss, yss, symbol);

  { ���� ��ᨢ ��� ����?����� �?��୨� �浪?� }
  for ii := 0 to 7 do
    binaryData[ii] := '';

  { ����� �?�ᥫ? � ������? 8x8 ������� ᨬ���� � ���� �?��୨� �冷� }
  for y := 0 to 7 do
  begin
    for x := 0 to 7 do
    begin
      pixelValue := GetPixel(xss + x, yss + y);  { ����� ���祭�� �?�ᥫ� }
      if pixelValue > 0 then
        binaryData[y] := binaryData[y] + '1'  { ������� '1', �� �?�ᥫ� ��⨢��� }
      else
        binaryData[y] := binaryData[y] + '0';  { ������� '0', �� �?�ᥫ� ����⨢��� }
    end;
  end;

  { ������� ��⠭? �?���? ���? � 䠩� }
  SaveSymbolToFile(asciiCode, binaryData);

  { ���� ��࠭ �?� ���� ᨬ���� }
  SetColor(0);
  OutTextXY(0, 0, asciiCodeStr);
end;

begin
  { ?�?�?��?���?� ���?筮�� ०��� ��� EGA/VGA }
  Gd := Detect;
  InitGraph(Gd, Gm, '');  { ������ ��� �� �ࠩ���?� ���?��, �� �����?��� }

  if GraphResult <> grOk then
  begin
    WriteLn('Graphics error: ', GraphErrorMsg(GraphResult));
    Halt(1);
  end;

  { �?��ਢ�� 䠩� ��� ������ }
  Assign(F, 'cp866.asm');
  Rewrite(F);
  
  xs := 0;  { ���⪮�� ���न��� x ��� ��������� ᨬ���� }
  ys := 20; { ���⪮�� ���न��� y ��� ��������� ᨬ���� }

  { ��室��� ��? ASCII ᨬ���� �?� 0 �� 255 }
  for i := 0 to 255 do
  begin
    GetSymbolPixels(i, xs, ys);  { ��஡��� ����� ᨬ��� ? ����� ���� �?�ᥫ? }
    
    xs := xs + 8;  { ��६?���� �� ����㯭� �����?� �� ��? x }
    if xs + 8 > 640 then  { ��� ���� �?��� ��࠭� �� ��? x, ��७�ᨬ� �� ����㯭�� �冷� }
    begin
      xs := 0;
      ys := ys + 8;
    end;
  end;

  ReadLn;  { ��?��� ���᪠��� ����?�? ��। �����襭�� }
  
  { ���ਢ�� 䠩� ? ���?筨� ०�� }
  Close(F);
  CloseGraph;
end.
