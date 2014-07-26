unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Math, motor_control, ComCtrls;

type
  TForm1 = class(TForm)
    debug: TMemo;
    motorsettings_box: TGroupBox;
    stepping_box: TComboBox;
    units_box: TComboBox;
    mmperrev_label: TLabel;
    mmperrev: TEdit;
    stepsperrev_label: TLabel;
    stepsperrev: TEdit;
    current_label: TLabel;
    current: TEdit;
    idelcurrent_label: TLabel;
    idlecurrent: TEdit;
    ma_label_1: TLabel;
    ma_label_2: TLabel;
    motorcontrol_box: TGroupBox;
    accel_label: TLabel;
    accel: TEdit;
    accel_unit_label: TLabel;
    decel_label: TLabel;
    decel: TEdit;
    decel_unit_label: TLabel;
    velocity_label: TLabel;
    velocity: TEdit;
    velocity_unit_label: TLabel;
    position_label: TLabel;
    position: TEdit;
    position_unit_label: TLabel;
    set_position: TButton;
    stop: TButton;
    brake: TButton;
    move_label: TLabel;
    move: TEdit;
    move_unit_label: TLabel;
    go: TButton;
    rotation: TTrackBar;
    position_timer: TTimer;
    deg0_label: TLabel;
    deg360_label: TLabel;
    deg180_label: TLabel;
    deg90_label: TLabel;
    deg270_label: TLabel;
    reset_motor: TButton;
    enable_motor: TCheckBox;
    sleep_motor: TCheckBox;
    canbox: TGroupBox;
    canid_label: TLabel;
    canid: TEdit;
    canrtr: TCheckBox;
    Label1: TLabel;
    cansize: TComboBox;
    cansend: TButton;
    candata: TEdit;
    candata_label: TLabel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure units_boxChange(Sender: TObject);
    procedure stepping_boxChange(Sender: TObject);
    procedure stepsperrevKeyPress(Sender: TObject; var Key: Char);
    procedure currentKeyPress(Sender: TObject; var Key: Char);
    procedure goClick(Sender: TObject);
    procedure set_positionClick(Sender: TObject);
    procedure stopClick(Sender: TObject);
    procedure brakeClick(Sender: TObject);
    procedure position_timerTimer(Sender: TObject);
    procedure rotationChange(Sender: TObject);
    procedure accelKeyPress(Sender: TObject; var Key: Char);
    procedure decelKeyPress(Sender: TObject; var Key: Char);
    procedure velocityKeyPress(Sender: TObject; var Key: Char);
    procedure idlecurrentKeyPress(Sender: TObject; var Key: Char);
    procedure enable_motorClick(Sender: TObject);
    procedure sleep_motorClick(Sender: TObject);
    procedure reset_motorClick(Sender: TObject);
    procedure moveKeyPress(Sender: TObject; var Key: Char);
    procedure cansizeChange(Sender: TObject);
    procedure cansendClick(Sender: TObject);
    procedure candataKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  motor: TMotor;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
    motor := TMotor.create($4B57, $4D43, 200, 1);

    motor.current := 200;
    motor.idle_current := 100;

    motor.acceleration := 2000;
    motor.deceleration := 2000;
    motor.velocity := 200;

//    motor.debug := debug;

    stepping_box.ItemIndex := 0;
    units_box.ItemIndex := 0;

//    position_timer.enabled := true;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    motor.destroy();
end;

procedure TForm1.set_positionClick(Sender: TObject);
var
    pos : real;
begin
    if (motor.units = muSteps) then
        pos := strtofloat(InputBox('Set Position', 'Enter Position in ' + UNIT_NAMES[motor.units] + ' : ', formatfloat('+0;-0', motor.position)))
    else
        pos := strtofloat(InputBox('Set Position', 'Enter Position in ' + UNIT_NAMES[motor.units] + ' : ', formatfloat('+0.00;-0.00', motor.position)));

    motor.position := pos;
end;

procedure TForm1.moveKeyPress(Sender: TObject; var Key: Char);
begin
    if (key = chr(13)) then begin
        motor.move(strtofloat(move.text));
        move.Enabled := false;
    end;
end;

procedure TForm1.goClick(Sender: TObject);
var
    pos : real;
begin
    if (motor.units = muSteps) then
        pos := strtofloat(InputBox('Move to Position', 'Enter new Position in ' + UNIT_NAMES[motor.units] + ' : ', formatfloat('+0;-0', motor.position)))
    else
        pos := strtofloat(InputBox('Move to Position', 'Enter new Position in ' + UNIT_NAMES[motor.units] + ' : ', formatfloat('+0.00;-0.00', motor.position)));

    motor.move_to(pos);
end;


procedure TForm1.rotationChange(Sender: TObject);
var
    u : TMotorUnits;
    f : integer;
    r : real;
begin
{
    position_timer.Enabled := false;

    u := motor.units;
    motor.units := muDegrees;

    f := round(motor.position) div 360; // Number of full rotations
    r := motor.position - f * 360;

    debug.lines.add(
        inttostr(f) + ' ' +
        formatfloat('0.00', r) + ' : ' +
        formatfloat('0.00', r - rotation.position) + ' ' +
        formatfloat('0.00', f + (r - rotation.position))
    );

    motor.position := f + (r - rotation.position);

    motor.units := u;
    position_timer.Enabled := true;
}
end;

procedure TForm1.stopClick(Sender: TObject);
begin
    motor.stop;
end;

procedure TForm1.brakeClick(Sender: TObject);
begin
    motor.brake;
end;

procedure TForm1.position_timerTimer(Sender: TObject);
var
    pos : real;
    rem : real;
    deg : real;
begin
    pos := motor.position;
    rem := motor.remaining;

    if (motor.units = muSteps) then
    begin
        position.Text := formatfloat('+0;-0', pos);

        if (move.Enabled = false) then
            move.Text := formatfloat('+0;-0', rem);
    end else
    begin
        position.Text := formatfloat('+0.00;-0.00', pos);

        if (move.Enabled = false) then
            move.Text := formatfloat('+0.00;-0.00', rem);
    end;

    deg := motor.steps2units(motor.units2steps(pos, motor.units), muDegrees);

    if deg < 0 then
        rotation.Position := 360 - round(abs(deg)) mod 360
    else
        rotation.Position := round(deg) mod 360;


    if (rem = 0) then
        move.Enabled := true;
end;

procedure TForm1.stepping_boxChange(Sender: TObject);
begin
    motor.stepping := TMotorStepping(stepping_box.ItemIndex);
    
    units_boxChange(self); // Update Values in case Rotations is selected
end;

procedure TForm1.stepsperrevKeyPress(Sender: TObject; var Key: Char);
var
    itemindex : integer;
begin
    if (key = chr(13)) then
    begin
        try
            motor.fspr := strtoint(stepsperrev.text)
        except
            stepsperrev.text := '200';
            motor.fspr := 200;
        end;

        itemindex := stepping_box.itemindex;

        stepping_box.items.strings[0] := 'Full Steps      [' + inttostr(motor.fspr *  1) + ']';
        stepping_box.items.strings[1] := 'Half Steps      [' + inttostr(motor.fspr *  2) + ']';
        stepping_box.items.strings[2] := 'Quarter Steps   [' + inttostr(motor.fspr *  4) + ']';
        stepping_box.items.strings[3] := 'Sixteenth Steps [' + inttostr(motor.fspr * 16) + ']';

        stepping_box.itemindex := itemindex;

        units_boxChange(self); // Update Values in case Rotations is selected
    end;
end;

procedure TForm1.units_boxChange(Sender: TObject);
begin
    motor.units := TMotorUnits(units_box.ItemIndex);

    if (motor.units = muMillimeters) then
        mmperrev.Enabled := true
    else
        mmperrev.enabled := false;

    position_unit_label.Caption := UNIT_SYMBOLS[motor.units];
    move_unit_label.Caption     := UNIT_SYMBOLS[motor.units];

    accel_unit_label.Caption    := UNIT_SYMBOLS[motor.units] + ' / s²';
    decel_unit_label.Caption    := UNIT_SYMBOLS[motor.units] + ' / s²';
    velocity_unit_label.Caption := UNIT_SYMBOLS[motor.units] + ' / s';

    if (motor.units = muSteps) then
    begin
        position.Text := formatfloat('+0;-0', motor.position);

        accel.text    := formatfloat('0', motor.acceleration);
        decel.text    := formatfloat('0', motor.deceleration);
        velocity.text := formatfloat('0', motor.velocity);
    end else
    begin
        position.Text := formatfloat('+0.00;-0.00', motor.position);

        accel.text := formatfloat('0.00', motor.acceleration);
        decel.text := formatfloat('0.00', motor.deceleration);
        velocity.text := formatfloat('0.00', motor.velocity);
    end;
end;

procedure TForm1.currentKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = chr(13)) then
    begin
        try
            motor.current := abs(strtoint(current.text))
        except
            motor.current := 200;
        end;
        current.text := inttostr(motor.current);
    end;
end;

procedure TForm1.idlecurrentKeyPress(Sender: TObject; var Key: Char);
begin
    if (key = chr(13)) then
    begin
        try
            motor.idle_current := abs(strtoint(idlecurrent.text))
        except
            motor.idle_current := 100;
        end;
        idlecurrent.text := inttostr(motor.idle_current);
    end;
end;

procedure TForm1.accelKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = chr(13)) then
    begin
        try
            motor.acceleration := abs(strtofloat(accel.text))
        except
            motor.acceleration := motor.steps2units(2000, motor.units);
        end;

        if (motor.units = muSteps) then
            accel.text := formatfloat('0', motor.acceleration)
        else
            accel.text := formatfloat('0.00', motor.acceleration)
    end;
end;

procedure TForm1.decelKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = chr(13)) then
    begin
        try
            motor.deceleration := abs(strtofloat(decel.text))
        except
            motor.deceleration := motor.steps2units(2000, motor.units);
        end;

        if (motor.units = muSteps) then
            decel.text := formatfloat('0', motor.deceleration)
        else
            decel.text := formatfloat('0.00', motor.deceleration)

    end;
end;

procedure TForm1.velocityKeyPress(Sender: TObject; var Key: Char);
begin
   if (key = chr(13)) then
    begin
        try
            motor.velocity := abs(strtofloat(velocity.text))
        except
            motor.velocity := motor.steps2units(200, motor.units);
        end;

        if (motor.units = muSteps) then
            velocity.text := formatfloat('0', motor.velocity)
        else
            velocity.text := formatfloat('0.00', motor.velocity)
    end;
end;

procedure TForm1.enable_motorClick(Sender: TObject);
begin
    motor.enabled := enable_motor.Checked;
end;

procedure TForm1.sleep_motorClick(Sender: TObject);
begin
    motor.sleeping := sleep_motor.Checked;
end;

procedure TForm1.reset_motorClick(Sender: TObject);
begin
    motor.reset();
end;

procedure TForm1.cansizeChange(Sender: TObject);
begin
    candata.MaxLength := cansize.ItemIndex;
    candata.Text := copy(candata.text, 0, candata.maxlength);
end;

procedure TForm1.cansendClick(Sender: TObject);
var
    data : TByteArray;
    b : integer;
begin
    SetLength(data, cansize.itemindex);

    for b := 0 to cansize.itemindex - 1 do
        data[b] := ord(candata.text[b + 1]);

    motor.can_msg_send(strtoint('$' + canid.text), canrtr.Checked, cansize.ItemIndex, data); 
end;

procedure TForm1.candataKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if (key = 13) then
        cansend.Click()
     else
        cansize.ItemIndex := length(candata.text);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    debug.lines.add(inttostr(motor.current));
end;

end.
