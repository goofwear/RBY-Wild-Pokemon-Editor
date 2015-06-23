unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Spin, Menus, ComCtrls;

type
  TPointer = packed record
    First:  Byte;
    Second: Byte;
  end;

  TPokemon = packed record
    Level:  Byte;
    Number: Byte;
  end;

  TLandWildPkmn = packed record
    Rate: Byte;
    Pkmn: array [0..9] of TPokemon;
  end;

  TWaterWildPkmn = packed record
    Rate: Byte;
    Pkmn: array [0..9] of TPokemon;
  end;

  { TPokeEdit }

  TPokeEdit = class(TForm)
    Exit1: TMenuItem;
    About1: TMenuItem;
    GLabel: TLabel;
    Gload: TLabel;
    NoPkmnLabel1: TLabel;
    LandOffset2: TLabel;
    LandOffset1: TLabel;
    PkmnControl1: TPageControl;
    LandSheet1: TTabSheet;
    WaterSheet1: TTabSheet;
    WaterOffset1: TLabel;
    WaterOffset2: TLabel;
    N1: TMenuItem;
    OpenRomDialog1: TOpenDialog;
    Save1: TMenuItem;
    Open1: TMenuItem;
    WER25: TLabel;
    LER_1: TLabel;
    WER10_1: TLabel;
    WER10_2: TLabel;
    WER10_3: TLabel;
    WER15_1: TLabel;
    WER15_2: TLabel;
    WER1: TLabel;
    LER_4_1: TLabel;
    WER4: TLabel;
    LER_5_2: TLabel;
    LER_5_1: TLabel;
    LER_10_3: TLabel;
    LER_10_2: TLabel;
    LER_10_1: TLabel;
    LER_15_2: TLabel;
    LER_15_1: TLabel;
    LER25: TLabel;
    WER5_1: TLabel;
    WER5_2: TLabel;
    WaterLvlEdit1: TSpinEdit;
    WaterLvlGroup1: TGroupBox;
    WaterReplaceBtn1: TButton;
    WaterLvlBox1: TListBox;
    LandPercent1: TLabel;
    WaterPercent1: TLabel;
    WaterPkmnBox1: TListBox;
    WaterPkmnCombo1: TComboBox;
    WaterPkmnGroup1: TGroupBox;
    WaterRateGroup1: TGroupBox;
    LandRateGroup1: TGroupBox;
    LandReplaceBtn1: TButton;
    LandLvlGroup1: TGroupBox;
    LandPkmnCombo1: TComboBox;
    LandPkmnGroup1: TGroupBox;
    LandPkmnBox1: TListBox;
    LandLvlBox1: TListBox;
    MainMenu1: TMainMenu;
    MapCombo1: TComboBox;
    LandLvlEdit1: TSpinEdit;
    File1: TMenuItem;
    LandRateTrack1: TTrackBar;
    WaterRateTrack1: TTrackBar;
    MapGroup1: TGroupBox;
    WildPkmnBox: TGroupBox;
    procedure LandLvlBox1Click(Sender: TObject);
    procedure LandPkmnBox1Click(Sender: TObject);
    procedure LandRateTrack1Change(Sender: TObject);
    procedure LandReplaceBtn1Click(Sender: TObject);
    procedure MapCombo1Change(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SavePkmn;
    procedure LoadPkmn(Map: Byte);
    procedure UpdatePkmn;
    procedure WaterLvlBox1Click(Sender: TObject);
    procedure WaterPkmnBox1Click(Sender: TObject);
    procedure WaterRateTrack1Change(Sender: TObject);
    procedure WaterReplaceBtn1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

const
  PokeHex: array[0..151] of Byte = (
  $00, $99, $09, $9A, $B0, $B2, $B4, $B1, $B3, $1C, $7B, $7C, $7D, $70, $71, $72,
  $24, $96, $97, $A5, $A6, $05, $23, $6C, $2D, $54, $55, $60, $61, $0F, $A8, $10,
  $03, $A7, $07, $04, $8E, $52, $53, $64, $65, $6B, $82, $B9, $BA, $BB, $6D, $2E,
  $41, $77, $3B, $76, $4D, $90, $2F, $80, $39, $75, $21, $14, $47, $6E, $6F, $94,
  $26, $95, $6A, $29, $7E, $BC, $BD, $BE, $18, $9B, $A9, $27, $31, $A3, $A4, $08,
  $25, $AD, $36, $40, $46, $74, $3A, $78, $0D, $88, $17, $8B, $19, $93, $0E, $22,
  $30, $81, $4E, $8A, $06, $8D, $0C, $0A, $11, $91, $2B, $2C, $0B, $37, $8F, $12,
  $01, $28, $1E, $02, $5C, $5D, $9D, $9E, $1B, $98, $2A, $1A, $48, $35, $33, $1D,
  $3C, $85, $16, $13, $4C, $66, $69, $68, $67, $AA, $62, $63, $5A, $5B, $AB, $84,
  $4A, $4B, $49, $58, $59, $42, $83, $15 );

var
  PokeEdit: TPokeEdit;
  LoadedMap: string = '';
  Game:      string;
  Rom: TMemoryStream = nil;
  PkmnStart: Integer;
  Modified:  Boolean;
  Pointer:   TPointer;
  Ready:     Boolean;
  LandPkmn:  TLandWildPkmn;
  WaterPkmn: TWaterWildPkmn;
  Location:  string;

implementation

{ TPokeEdit }


procedure TPokeEdit.Open1Click(Sender: TObject);
var
  Version: Byte;
begin
  if OpenRomDialog1.Execute then
    begin
      if Rom = nil then
        Rom := TMemoryStream.Create;

      Rom.LoadFromFile(OpenRomDialog1.FileName);
      Rom.Position := $13C;
      Rom.Read(Version,SizeOf(Version));
      case Version of
        $42: Game := 'Blue';
        $52: Game := 'Red';
        $59: Game := 'Yellow';
        end;

      Modified := False;
      Save1.Enabled := True;

      //MapCombo1.ItemIndex := 0;
      // MapCombo1Change(Sender);
      MapCombo1.Enabled := True;
      Gload.Caption := Game;
    end;
end;

procedure TPokeEdit.Save1Click(Sender: TObject);
begin
  if PkmnStart > 0 then
    SavePkmn;

  Rom.SaveToFile(OpenRomDialog1.FileName);
  Modified := False;
end;

procedure TPokeEdit.Exit1Click(Sender: TObject);
begin
  if Modified then
    begin
      case MessageDlg('Save changes?',mtConfirmation,mbYesNoCancel,0) of
        mrYes: SavePkmn;
        mrCancel: Abort;
      end;
    end;
  Close;
end;

procedure TPokeEdit.SavePkmn;
begin
  if PkmnStart = 0 then
    Exit;

  if LandPkmn.Rate <> $00 then
    begin
      // Land Pokemon data exists
      Rom.Position := PkmnStart;
      Rom.Write(LandPkmn,SizeOf(TLandWildPkmn));
    end;
  if WaterPkmn.Rate <> $00 then
    begin
      if LandPkmn.Rate <> $00 then
        begin
          // Land Pokemon data also exists
          Rom.Position := PkmnStart + SizeOf(TLandWildPkmn);
          Rom.Write(WaterPkmn,SizeOf(TWaterWildPkmn));
        end
      else
        begin
          // Land Pokemon data doesn't exist
          Rom.Position := PkmnStart;
          Rom.Write(WaterPkmn,SizeOf(TWaterWildPkmn));
        end;
    end;
end;

procedure TPokeEdit.MapCombo1Change(Sender: TObject);
begin
  if Modified then
    begin
      case MessageDlg('Save changes?',mtConfirmation,mbYesNoCancel,0) of
        mrYes: SavePkmn;
        mrCancel: Abort;
      end;
    end;
  LoadPkmn(MapCombo1.ItemIndex);
  Modified := False;
end;

procedure TPokeEdit.LoadPkmn(Map: Byte);
var
  First:  string;
  Second: string;
begin
  PkmnStart := 0;
  LandPkmn.Rate  := $00;
  WaterPkmn.Rate := $00;
  LandPkmnBox1.Clear;
  WaterPkmnBox1.Clear;
  LandLvlBox1.Clear;
  WaterLvlBox1.Clear;
  LandPkmnCombo1.Text := '';
  LandLvlEdit1.Clear;
  WaterPkmnCombo1.Text := '';
  WaterLvlEdit1.Clear;
  NoPkmnLabel1.Visible := False;
  Ready := False;

  // Read the pointer from the ROM
  if Game = 'Yellow' then
    begin
      Rom.Position := $CB95 + (Map * 2);
    end
  else
    begin
      Rom.Position := $CEEB + (Map * 2);
    end;
  Rom.Read(Pointer,SizeOf(Pointer));

  // Translate the pointer into hex
  First    := IntToStr(Pointer.Second + $80);
  Second   := IntToStr(Pointer.First);
  Location := IntToHex(StrToInt(First),2) + IntToHex(StrToInt(Second),2);
  // Follow the translated pointer
  Rom.Position := StrToInt('$' + Location);
  Rom.Read(LandPkmn,SizeOf(TLandWildPkmn));
  LandOffset2.Caption := '$' + Location;

  if LandPkmn.Rate <> $00 then
    begin
      // Land data was found
      PkmnControl1.Show;
      PkmnStart := StrToInt('$' + Location);
      Rom.Position := StrToInt('$' + Location) + SizeOf(TLandWildPkmn);
      // Read water pkmn data
      Rom.Read(WaterPkmn,SizeOf(TWaterWildPkmn));
      WaterOffset2.Caption := '$' + IntToHex(StrToInt('$' + Location) + SizeOf(TLandWildPkmn),4);
    end
  else
    begin
      // No land data was found. Check for water data
      Rom.Position := StrToInt('$' + Location) + $01;
      Rom.Read(WaterPkmn,SizeOf(TWaterWildPkmn));
      WaterOffset2.Caption := '$' + IntToHex(StrToInt('$' + Location) + $01, 4);
      if WaterPkmn.Rate <> $00 then
        begin
          PkmnControl1.Show;
          PkmnControl1.ActivePage := WaterSheet1;
          PkmnStart := StrToInt('$' + Location) + $01;
        end;
    end;

  if (LandPkmn.Rate = $00) and (WaterPkmn.Rate = $00) then
    begin
      PkmnControl1.Hide;
      NoPkmnLabel1.Visible := True;
      LandRateTrack1.Enabled := False;
      WaterRateTrack1.Enabled := False;
      Exit;
    end;

  if LandPkmn.Rate <> $00 then
    begin
      LandSheet1.TabVisible   := True;
      PkmnControl1.ActivePage := LandSheet1;
      LandPkmnBox1.Enabled    := True;
      LandLvlBox1.Enabled     := True;
      LandPkmnCombo1.Enabled  := True;
      LandLvlEdit1.Enabled    := True;
      LandRateTrack1.Enabled  := True;
      LandReplaceBtn1.Enabled := True;
    end
  else
    begin
      LandSheet1.TabVisible   := False;
      LandPkmnBox1.Enabled    := False;
      LandLvlBox1.Enabled     := False;
      LandPkmnCombo1.Enabled  := False;
      LandLvlEdit1.Enabled    := False;
      LandRateTrack1.Enabled  := False;
      LandReplaceBtn1.Enabled := False;
    end;

  if WaterPkmn.Rate <> $00 then
    begin
      WaterSheet1.TabVisible   := True;
      WaterPkmnBox1.Enabled    := True;
      WaterLvlBox1.Enabled     := True;
      WaterPkmnCombo1.Enabled  := True;
      WaterLvlEdit1.Enabled    := True;
      WaterRateTrack1.Enabled  := True;
      WaterReplaceBtn1.Enabled := True;
    end
  else
    begin
      WaterSheet1.TabVisible   := False;
      WaterPkmnBox1.Enabled    := False;
      WaterLvlBox1.Enabled     := False;
      WaterPkmnCombo1.Enabled  := False;
      WaterLvlEdit1.Enabled    := False;
      WaterRateTrack1.Enabled  := False;
      WaterReplaceBtn1.Enabled := False;
    end;

  // NoPkmnLabel.Hide;
  LandRateTrack1.Position := LandPkmn.Rate;
  LandPercent1.Caption := IntToStr(LandPkmn.Rate) + '%';
  WaterRateTrack1.Position := WaterPkmn.Rate;
  WaterPercent1.Caption := IntToStr(WaterPkmn.Rate) + '%';
  UpdatePkmn;
  Ready := True;

end;

procedure TPokeEdit.UpdatePkmn;
var
  I, P: Integer;
begin
  LandPkmnBox1.Clear;
  WaterPkmnBox1.Clear;
  LandLvlBox1.Clear;
  WaterLvlBox1.Clear;

  if LandPkmn.Rate <> $00 then
    begin
      for I := 0 to 9 do
        begin
          for P := 0 to 151 do
            begin
              if LandPkmn.Pkmn[I].Number = PokeHex[P] then
                begin
                  LandPkmnBox1.Items.Add(LandPkmnCombo1.Items[P]);
                  LandLvlBox1.Items.Add(IntToStr(LandPkmn.Pkmn[I].Level));
                end;
            end;
        end;
    end;

  if WaterPkmn.Rate <> $00 then
    begin
      for I := 0 to 9 do
        begin
          for P := 0 to 151 do
            begin
              if WaterPkmn.Pkmn[I].Number = PokeHex[P] then
                begin
                  WaterPkmnBox1.Items.Add(WaterPkmnCombo1.Items[P]);
                  WaterLvlBox1.Items.Add(IntToStr(WaterPkmn.Pkmn[I].Level));
                end;
            end;
        end;
    end;

end;

procedure TPokeEdit.LandPkmnBox1Click(Sender: TObject);
var
  I: Integer;
begin
  LandLvlBox1.ItemIndex := LandPkmnBox1.ItemIndex;
  for I := 0 to 151 do
    begin
      if LandPkmn.Pkmn[LandPkmnBox1.ItemIndex].Number = PokeHex[I] then
        begin
          LandPkmnCombo1.ItemIndex := I;
          LandLvlEdit1.Value := LandPkmn.Pkmn[LandPkmnBox1.ItemIndex].Level;
        end;
    end;
end;

procedure TPokeEdit.LandLvlBox1Click(Sender: TObject);
begin
  LandPkmnBox1.ItemIndex := LandLvlBox1.ItemIndex;
  LandPkmnBox1Click(LandPkmnBox1);
end;

procedure TPokeEdit.WaterPkmnBox1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 151 do
    begin
      if WaterPkmn.Pkmn[WaterPkmnBox1.ItemIndex].Number = PokeHex [I] then
        begin
          WaterPkmnCombo1.ItemIndex := I;
          WaterLvlEdit1.Value := WaterPkmn.Pkmn[WaterPkmnBox1.ItemIndex].Level;
        end;
    end;
end;

procedure TPokeEdit.WaterLvlBox1Click(Sender: TObject);
begin
  WaterPkmnBox1.ItemIndex := WaterLvlBox1.ItemIndex;
  WaterPkmnBox1Click(WaterPkmnBox1);
end;

procedure TPokeEdit.LandReplaceBtn1Click(Sender: TObject);
begin
  LandPkmn.Pkmn[LandPkmnBox1.ItemIndex].Number := PokeHex[LandPkmnCombo1.ItemIndex];
  LandPkmn.Pkmn[LandPkmnBox1.ItemIndex].Level  := LandLvlEdit1.Value;
  UpdatePkmn;
  Modified := True;
end;

procedure TPokeEdit.WaterReplaceBtn1Click(Sender: TObject);
begin
  WaterPkmn.Pkmn[WaterPkmnBox1.ItemIndex].Number := PokeHex[WaterPkmnCombo1.ItemIndex];
  WaterPkmn.Pkmn[WaterPkmnBox1.ItemIndex].Level  := WaterLvlEdit1.Value;
  UpdatePkmn;
  Modified := True;
end;

procedure TPokeEdit.LandRateTrack1Change(Sender: TObject);
begin
  if Ready then
    begin
      LandPkmn.Rate := LandRateTrack1.Position;
      LandPercent1.Caption := IntToStr(LandRateTrack1.Position) + '%';
      Modified := True;
    end;
end;

procedure TPokeEdit.WaterRateTrack1Change(Sender: TObject);
begin
  if Ready then
    begin
      WaterPkmn.Rate := WaterRateTrack1.Position;
      WaterPercent1.Caption := IntToStr(WaterRateTrack1.Position) + '%';
      Modified := True;
    end;
end;



initialization
  {$I Main.lrs}

end.

