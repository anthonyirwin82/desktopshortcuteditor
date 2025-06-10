unit AboutForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, LCLIntf;
const
  appImage: string = 'DESKTOP-SHORTCUT-EDITOR-ICON-128X128';
  appAuthor: string = 'Anthony Irwin';
  appAuthorWebsite: string = 'https://anthonyirwin.com';
  appWebsite: string = 'https://desktopshortcuteditor.anthonyirwin.com';
  appRepo: string = 'https://github.com/anthonyirwin82/desktopshortcuteditor';
  appDescription: string = 'Desktop Shortcut Editor allows you to easily add, search and edit desktop entry files.';
type

  { TFrmAbout }

  TFrmAbout = class(TForm)
    btnSoftware: TButton;
    btnRepo: TButton;
    btnAuthor: TButton;
    btnClose: TButton;
    imgApp: TImage;
    lblDescription: TLabel;
    lblAuthor: TLabel;
    lblAppName: TLabel;
    Panel: TPanel;
    procedure btnAuthorClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnRepoClick(Sender: TObject);
    procedure btnSoftwareClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmAbout: TFrmAbout;

implementation

{$R *.lfm}

{ TFrmAbout }

procedure TFrmAbout.FormCreate(Sender: TObject);
begin
  imgApp.Picture.LoadFromResourceName(HInstance, appImage);
  lblAppName.Caption := Application.Title;
  lblAuthor.Caption := 'Developed by: ' + appAuthor;
  lblDescription.Caption := appDescription;
end;

procedure TFrmAbout.btnSoftwareClick(Sender: TObject);
begin
  OpenURL(appWebsite);
end;

procedure TFrmAbout.btnRepoClick(Sender: TObject);
begin
  OpenURL(appRepo);
end;

procedure TFrmAbout.btnAuthorClick(Sender: TObject);
begin
  OpenURL(appAuthorWebsite);
end;

procedure TFrmAbout.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

