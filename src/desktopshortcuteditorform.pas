unit DesktopShortcutEditorForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  FileCtrl, Menus, Unix, LCLIntf, DesktopShortcutTextEditor, AboutForm;
type

  { TFrmDesktopShortcutEditor }

  TFrmDesktopShortcutEditor = class(TForm)
    btnUsrShare: TButton;
    btnUsrLocal: TButton;
    btnDotLocal: TButton;
    btnAdd: TButton;
    btnEditFile: TButton;
    edtSearch: TEdit;
    edtFilename: TEdit;
    fileListBox: TfileListBox;
    lblAddFilename: TLabel;
    lblLocation: TLabel;
    miAbout: TMenuItem;
    miWebsite: TMenuItem;
    miHelp: TMenuItem;
    miFile: TMenuItem;
    miExit: TMenuItem;
    mnuMainMenu: TMainMenu;

    procedure btnAddClick(Sender: TObject);
    procedure BtnEditFileClick(Sender: TObject);
    procedure ChangeFileListBoxLocation;
    procedure EdtFilenameChange(Sender: TObject);
    procedure EdtSearchChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnDotLocalClick(Sender: TObject);
    procedure BtnUsrLocalClick(Sender: TObject);
    procedure BtnUsrShareClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miWebsiteClick(Sender: TObject);
  private
    const
  	   usrShareLocation: string = '/usr/share/applications';
  		 usrLocalLocation: string = '/usr/local/share/applications';
      websiteUrl: string = 'https://www.yahoo.com';
    var
      dotLocalLocation: string;
      isNormalUserFile: boolean;

  public

  end;

var
  FrmDesktopShortcutEditor: TFrmDesktopShortcutEditor;

implementation

{$R *.lfm}

{ TFrmDesktopShortcutEditor }

procedure TFrmDesktopShortcutEditor.ChangeFileListBoxLocation;
begin
  // Select first line on fileListBox if files are listed in it.
  if fileListBox.Items.Count > 0 then
  begin
    fileListBox.ItemIndex := 0;
    btnEditFile.Enabled := True;
  end else
    btnEditFile.Enabled := False; // No file to edit diasable the button
end;

procedure TFrmDesktopShortcutEditor.EdtFilenameChange(Sender: TObject);
begin
  if (Length(edtFilename.Text) >= 10) and
     (LowerCase(Copy(edtFilename.Text, Length(edtFilename.Text) - 7, 8)) = '.desktop') then
    btnAdd.Enabled := True
  else
    btnAdd.Enabled := False;
end;

procedure TFrmDesktopShortcutEditor.EdtSearchChange(Sender: TObject);
begin
  fileListBox.Mask := '*' + edtSearch.Text + '*.desktop';
  ChangeFileListBoxLocation;
end;

procedure TFrmDesktopShortcutEditor.FormShow(Sender: TObject);
begin
  dotLocalLocation := GetUserDir + '.local/share/applications';

  // Check that the applications directories exist and disable navigation buttons if they don't exist
  if not DirectoryExists(usrShareLocation) then
    begin
      btnUsrShare.Enabled := false;
      fileListBox.Directory := dotLocalLocation;
    end;
  if not DirectoryExists(usrLocalLocation) then
  	 btnUsrLocal.Enabled := false;
  // Create ~/.local/share/applications if it doesn't exist
  if not DirectoryExists(dotLocalLocation) then
  	 fpSystem('mkdir -p ' + dotLocalLocation);

  ChangeFileListBoxLocation;
  isNormalUserFile := False;
  edtSearch.SetFocus;
end;

procedure TFrmDesktopShortcutEditor.BtnEditFileClick(Sender: TObject);
begin
  // Stops the fileListBox double click from executing when no items exist
  if fileListBox.Items.Count > 0 then
  	 EditFileInTextEditor(fileListBox.FileName, isNormalUserFile);
end;

procedure TFrmDesktopShortcutEditor.btnAddClick(Sender: TObject);
var
  filename: string;
begin
  filename := lblLocation.Caption + '/' + edtFilename.Text;
  AddDesktopFile(filename, isNormalUserFile);
end;

procedure TFrmDesktopShortcutEditor.BtnUsrShareClick(Sender: TObject);
begin
  lblLocation.Caption := usrShareLocation;
  lblAddFileName.Caption := lblLocation.Caption;
  fileListBox.Directory := usrShareLocation;
  ChangeFileListBoxLocation;
  isNormalUserFile := False;
  edtSearch.SetFocus;
end;

procedure TFrmDesktopShortcutEditor.miAboutClick(Sender: TObject);
begin
  frmAbout := TFrmAbout.Create(Self);
  try
    frmAbout.ShowModal;
  finally
    frmAbout.Free;
  end
end;

procedure TFrmDesktopShortcutEditor.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmDesktopShortcutEditor.miWebsiteClick(Sender: TObject);
begin
  OpenURL(websiteUrl);
end;

procedure TFrmDesktopShortcutEditor.BtnUsrLocalClick(Sender: TObject);
begin
  lblLocation.Caption := usrLocalLocation;
  lblAddFileName.Caption := lblLocation.Caption;
  fileListBox.Directory := usrLocalLocation;
  ChangeFileListBoxLocation;
  isNormalUserFile := False;
  edtSearch.SetFocus;
end;

procedure TFrmDesktopShortcutEditor.BtnDotLocalClick(Sender: TObject);
begin
  lblLocation.Caption := dotLocalLocation;
  lblAddFileName.Caption := lblLocation.Caption;
  fileListBox.Directory := dotLocalLocation;
  ChangeFileListBoxLocation;
  isNormalUserFile := True;
  edtSearch.SetFocus;
end;

end.

