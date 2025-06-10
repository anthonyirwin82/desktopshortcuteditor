program DesktopShortcutEditor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, DesktopShortcutEditorForm, DesktopShortCutTextEditor, AboutForm
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title := 'Desktop Shortcut Editor';
  Application.Scaled := True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TfrmDesktopShortcutEditor, frmDesktopShortcutEditor);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.

