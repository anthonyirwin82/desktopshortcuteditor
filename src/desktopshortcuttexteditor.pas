unit DesktopShortCutTextEditor;

{$mode ObjFPC}{$H+}

interface
uses
  Classes, SysUtils, Forms, Dialogs;

procedure AddDesktopFile(const aFilename: string; aIsNormalUserFile: boolean);
procedure EditFileInTextEditor(const aFilename: string; aIsNormalUserFile: boolean);

implementation
uses
  Process, Unix, LCLType, Controls;
var
  // Use gtk or qt editors first based on widget set being built for
  {$IF DEFINED(LCLQT5) or DEFINED(LCLQT6)}
  editors: array[0..5] of string = ('kwrite', 'kate', 'gedit', 'pluma', 'leafpad', 'mousepad');
  {$ENDIF}
  {$IF DEFINED(LCLGTK2) or DEFINED(LCLGTK3)}
  editors: array[0..5] of string = ('gedit', 'pluma', 'leafpad', 'mousepad', 'kwrite', 'kate');
  {$ENDIF}
  i: Integer;
  env, runCommandOutput: string;

procedure CreateDesktopFile(aDesktopFile, aFilename: string; aIsNormalUserFile: boolean);
var
  cmd: string = '';
begin
  for i := 0 to High(editors) do
  begin
    if RunCommand('which', [editors[i]], runCommandOutput) then
    begin
      cmd := 'sh -c "' + 'echo -e ''' + aDesktopFile + ''' > ''' + aFilename + ''' && ' +
      		     env + ' ' + editors[i] + ' ''' + aFilename + '''"';

      if not aIsNormalUserFile then
        // Requires root privileges to save system files as normal user
        fpsystem('pkexec ' + cmd)
      else
      	 fpsystem(cmd);

      Exit;
    end;
  end;
  ShowMessage('Text editors not found. Please install one of the following: kwrite, kate, gedit');
end;

procedure AddDesktopFile(const aFilename: string; aIsNormalUserFile: boolean);
var
  desktopFile: string = '';
begin
  desktopFile := '[Desktop Entry]\n' +
                 '# e.g. Gimp\n' +
  								'Name=\n' +
                 '# e.g. Image Editor\n' +
                 'GenericName=\n' +
                 '# e.g. A free cross platform image editor\n' +
                 'Comment=\n' +
                 '# the name of the icon\n' +
                 'Icon=\n' +
                 'Path=\n' +
                 'Exec=\n' +
                 'Terminal=false\n' +
                 'Type=Application\n' +
                 'e.g. Graphics;2DGraphics;RasterGraphics;GTK;\n' +
                 'Categories=\n';

  if FileExists(aFilename) then
  begin
    if MessageDlg('File Exists', 'The file "' + aFilename + '" already exists. Overwrite it?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                    CreateDesktopFile(desktopFile, aFilename, aIsNormalUserFile);
  end else
  	 CreateDesktopFile(desktopFile, aFilename, aIsNormalUserFile);
end;

procedure EditFileInTextEditor(const aFilename: string; aIsNormalUserFile: boolean);
begin
  for i := 0 to High(editors) do
  begin
    if RunCommand('which', [editors[i]], runCommandOutput) then
    begin
      if not aIsNormalUserFile then
        // Requires root privileges to save system files as normal user
        fpsystem('pkexec ' + env + ' ' + editors[i] + ' "' + aFilename + '"')
      else
      	 RunCommand(editors[i], aFilename, runCommandOutput);

      Exit;
    end;
  end;
  ShowMessage('Text editors not found. Please install one of the following: kwrite, kate, gedit');
end;

initialization
  // Environment variables required on some setups for pkexec to work correctly
  if GetEnvironmentVariable('DISPLAY') <> '' then
  	 env := 'env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY'
  else if GetEnvironmentVariable('WAYLAND_DISPLAY') <> '' then
    env := 'env WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR QT_QPA_PLATFORM=wayland'
  else // no environment variables for x11 or wayland are setup on the system
  	 env := '';
end.

