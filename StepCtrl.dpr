program StepCtrl;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  libusb in 'libusb.pas',
  motor_control in 'motor_control.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
