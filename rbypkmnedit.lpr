program rbypkmnedit;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, Main, LResources;

{$IFDEF WINDOWS}{$R project1.rc}{$ENDIF}

begin
  {$I rbypkmnedit.lrs}
  Application.Title:='RBY Wild Pokémon Editor';
  Application.Initialize;
  Application.CreateForm(TPokeEdit, PokeEdit);
  Application.Run;
end.

