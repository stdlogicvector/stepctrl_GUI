unit motor_control;

//{$DEFINE DEBUG}
{$UNDEF DEBUG}

interface

uses Windows, SysUtils, Graphics, StdCtrls, Dialogs, Classes, LibUSB, ExtCtrls, Math;

const MOTOR_CONFIG = 1;
const MOTOR_STATUS_INTERFACE = 0;

const MOTOR_STATUS_EP = 2;

const USB_CMD_MOTOR_POSITION	  = $00;
const USB_CMD_MOTOR_REMSTEPS	  =	$01;
const USB_CMD_MOTOR_VELOCITY	  =	$02;
const USB_CMD_MOTOR_ACCEL		  =	$03;
const USB_CMD_MOTOR_DECEL		  =	$04;
const USB_CMD_MOTOR_CURRENT		  = $05;
const USB_CMD_MOTOR_IDLE_CURRENT  =	$06;
const USB_CMD_MOTOR_STEPPING	  =	$07;
const USB_CMD_MOTOR_GOTO		  =	$08;
const USB_CMD_MOTOR_MOVE		  =	$09;
const USB_CMD_MOTOR_BRAKE		  =	$0A;
const USB_CMD_MOTOR_STOP		  =	$0B;
const USB_CMD_MOTOR_STATE		  =	$0C;

const USB_CMD_CAN_SEND		      = $10;
const USB_CMD_CAN_RECV		      = $11;

const USB_CMD_IO_LED              = $20;

type
    TByteArray = array of byte;

    TMotorStepping  = (msFull, msHalf, msQuarter, msSixteenth);
    TMotorDirection = (mdClockWise, mdCounterClockWise);
    TMotorUnits     = (muSteps, muRotations, muDegrees, muRadians, muMillimeters);

    TMotorStatus = class(TThread)
      protected
        procedure Execute; override;

      private
        USB : TLIBUSB;
        ep2_buf : array[0..15] of byte;

        fInterval : integer;                    // Interval for requesting Motor Status (in ms)

        fPosition : integer;                    // 4 Byte
        fRemaining : integer;                   // 4 Byte

        fButton : array[0..2] of boolean;       // 1 Byte (3 Bit)
        fInput  : array[0..4] of boolean;       // 1 Byte (5 Bit)
        fAnalog : integer;                      // 4 byte

        procedure set_interval(value : integer);
        function  get_button(index : integer) : boolean;
        function  get_input(index : integer) : boolean;
        
      public
      constructor create(vid, pid : integer; interval : integer);
      destructor destroy();

      property interval  : integer read finterval write set_interval;
      property position  : integer read fPosition;
      property remaining : integer read fRemaining;
      property analog    : integer read fAnalog;

      property button[index : integer] : boolean read get_button;
      property input[index : integer]  : boolean read get_input;

    end;

    TMotor = class
      private
        USB : TLIBUSB;
        status : TMotorStatus;

        ep0_buf : array[0..63] of byte;
        ep1_buf : array[0..15] of byte;

        ffspr : integer;     // Full Steps per Rotation
        fgear_ratio : real;  // Gear-ratio (mm per Rotation)

        fFullRotation : real;   // One Rotation in currently selected Units

        fPosition     : integer;        // steps
        fRemaining    : integer;        // steps

        fVelocity     : integer;        // steps / s
        fAcceleration : integer;        // steps / s²
        fDeceleration : integer;        // steps / s²

        fCurrent : word;         // mA
        fIdleCurrent : word;     // mA

        fStepping : TMotorStepping;
        fDirection : TMotorDirection;

        fUnits : TMotorUnits;             // Selects Unit

        fEnabled : Boolean;
        fSleeping : Boolean;

        fLED : array[0..2] of boolean;

        procedure enable(value : boolean);
        procedure sleep(value : boolean);

        procedure set_real_prop(index : integer; value : real);
        function  get_real_prop(index : integer): real;

        procedure set_int_prop(index : integer; value : word);
        function  get_int_prop(index : integer): word;

        procedure set_stepping(const value : TMotorStepping);
        function  get_stepping(): TMotorStepping;

        procedure set_led(index : integer; value : boolean);

        function get_fullrotation() : real;

        procedure cmd_write(id : integer; const args : TByteArray);
        function cmd_read(id : integer; var len : integer): TByteArray;

        function word2bytes(value : word)   : TByteArray;
        function int2bytes(value : integer) : TByteArray;

        function bytes2word(bytes : TByteArray) : word;
        function bytes2int(bytes : TByteArray)  : integer;

       public
{$IFDEF DEBUG}
        debug : TMemo;
{$ENDIF}
        constructor create(vid, pid : integer; fullsteps_per_rev : integer; mm_per_rev : real);
        destructor destroy(); override;

        function steps2units(steps : integer; units : TMotorUnits) : real;
        function units2steps(value : real; units : TMotorUnits) : integer;

        property position     : real index USB_CMD_MOTOR_POSITION  read get_real_prop write set_real_prop;
        property remaining    : real index USB_CMD_MOTOR_REMSTEPS  read get_real_prop;
        property velocity     : real index USB_CMD_MOTOR_VELOCITY  read get_real_prop write set_real_prop;
        property acceleration : real index USB_CMD_MOTOR_ACCEL     read get_real_prop write set_real_prop;
        property deceleration : real index USB_CMD_MOTOR_DECEL     read get_real_prop write set_real_prop;
        
        property current      : word index USB_CMD_MOTOR_CURRENT      read get_int_prop write set_int_prop;
        property idle_current : word index USB_CMD_MOTOR_IDLE_CURRENT read get_int_prop write set_int_prop;

        property stepping     : TMotorStepping read get_stepping write set_stepping;
        property units        : TMotorUnits read fUnits write fUnits;
        property gear_ratio   : real read fgear_ratio write fgear_ratio;
        property fspr         : integer read ffspr write ffspr;
        
        property fullrotation : real read get_fullrotation;

        property enabled      : boolean read fEnabled write enable;
        property sleeping     : boolean read fSleeping write sleep;

        property led[index : integer] : boolean write set_led;

        procedure reset();

        procedure move_to(position : real);
        procedure move(distance : real);
        procedure stop();
        procedure brake();

        procedure can_msg_send(id : integer; rtr : boolean; size: integer; data: TByteArray);

        procedure control_msg();
    end;

const STEPPING_FACTOR  : array[TMotorStepping] of integer = (1, 2, 4, 16);
const DIRECTION_FACTOR : array[TMotorDirection] of integer = (+1, -1);
const UNIT_NAMES       : array[TMotorUnits] of string = ('Steps', 'Rotations', 'Degrees', 'Radians', 'Millimeters');
const UNIT_SYMBOLS     : array[TMotorUnits] of string = ('steps', 'r', 'deg', 'rad', 'mm');
                                                                   
implementation

{ TMotorStatus }

constructor TMotorStatus.create(vid, pid : integer; interval : integer);
begin
    inherited create(true);
    
    USBdevInit(USB);
    usb_set_debug(255);

    USB.VID := vid;
    USB.PID := pid;

    if not USBdevOpen(USB) then
    begin
        MessageDlg('Could not connect to USB Device.', mtError, [mbOK], 0);
        Halt;
    end;

    USB.dev := usb_set_configuration(USB.handle, MOTOR_CONFIG);

    // Claim Interface 0 with EP1 for bulk transfers

    if (usb_claim_interface(USB.handle, MOTOR_STATUS_INTERFACE) <> 0) then
    begin
        MessageDlg('Could not claim Interface' + inttostr(MOTOR_STATUS_INTERFACE) + '.', mtError, [mbOK], 0);
        Halt;
    end;

    fInterval := interval;
end;

destructor TMotorStatus.destroy;
begin
    try
        usb_release_interface(USB.handle, MOTOR_STATUS_INTERFACE);
    finally
        inherited;
    end;
end;

procedure TMotorStatus.Execute;
begin
  inherited;
  try
    while (not Terminated) do
    begin
        


        Sleep(fInterval);
    end;
  except
    on E: exception do begin

    end;
  end;
end;

function TMotorStatus.get_button(index: integer): boolean;
begin
    if (index >= 0) AND (index < 3) then
        Result := fButton[index]
    else
        Result := false;
end;

function TMotorStatus.get_input(index: integer): boolean;
begin
    if (index >= 0) AND (index < 5) then
        Result := fInput[index]
    else
        Result := false;
end;

procedure TMotorStatus.set_interval(value: integer);
begin
    if (value < 32) then value := 32;
    if (value > 10000) then value := 10000;

    fInterval := value;
end;

{ TMotor }

{---- Constructor & Destructor ----}

constructor TMotor.create(vid, pid: integer; fullsteps_per_rev : integer; mm_per_rev : real);
begin
    inherited create();

    USBdevInit(USB);
    usb_set_debug(255);

    USB.VID := vid;
    USB.PID := pid;

    if not USBdevOpen(USB) then
    begin
        MessageDlg('Could not connect to USB Device.', mtError, [mbOK], 0);
        Halt;
    end;

    USB.dev := usb_set_configuration(USB.handle, MOTOR_CONFIG);

    // Claim no Interface, only EP0 used for command transfers

    status := TMotorStatus.Create(vid, pid, 250);
    status.FreeOnTerminate := true;
//    status.Resume;

    fspr      := fullsteps_per_rev;
    fUnits    := muSteps;
    fStepping := msFull;

    if (mm_per_rev <> 0) then
        fgear_ratio := mm_per_rev
    else
        fgear_ratio := 1;
end;

destructor TMotor.destroy;
begin
    inherited;

    try
        status.Terminate;
    finally
        USBdevClose(USB);
    end;
end;

{---- USB Communication ----}

procedure TMotor.cmd_write(id: integer; const args: TByteArray);
var
    arg : integer;
    ret : integer;
    len : integer;
begin
{$IFDEF DEBUG}
    if (assigned(debug)) then begin
        debug.lines.add('CMD OUT');
        debug.lines.add('    ID    : ' + inttostr(id));
    end;
{$ENDIF}

    for arg := 0 to length(args) - 1 do begin
        ep0_buf[arg] := args[arg];
{$IFDEF DEBUG}
        if (assigned(debug)) then
            debug.lines.add('    ARG[' +  inttostr(arg) + '] : ' + inttostr(ep0_buf[arg]));
{$ENDIF}
    end;
{$IFDEF DEBUG}
    if (assigned(debug)) then
        debug.lines.add('');
{$ENDIF}

    for arg := length(args) to 15 do
        ep0_buf[arg] := 0;

    // Message needs one byte minimum
    if length(args) = 0 then
        len := 1
    else
        len := length(args);

    ret := usb_control_msg(USB.handle, USB_TYPE_VENDOR or USB_RECIP_ENDPOINT or USB_ENDPOINT_OUT, id, 0, 0 , ep0_buf, len, 500);

    if (ret < 0) then
        MessageDlg('Could not send Command to Device! (' + inttostr(ret) +')', mtError, [mbOK], 0);
        
    if (ret < len) then
        MessageDlg('Could not send all Data to Device! (' + inttostr(ret) +')', mtError, [mbOK], 0);
end;

function TMotor.cmd_read(id : integer; var len : integer): TByteArray;
var
    arg : integer;
    data : array[0..15] of byte;
    ret : integer;
begin
{$IFDEF DEBUG}
    if (assigned(debug)) then begin
        debug.lines.add('CMD IN');
        debug.lines.add('    ID    : ' + inttostr(id));
    end;
{$ENDIF}

    ret := usb_control_msg(USB.handle, USB_TYPE_VENDOR or USB_RECIP_ENDPOINT or USB_ENDPOINT_IN, id, 0, 0, data, len, 500);

    if (ret < 0) then
        MessageDlg('Could not receive Data from Device! (' + inttostr(ret) +')', mtError, [mbOK], 0);
        
    if (ret < len) then
        MessageDlg('Could not receive all Data from Device! (' + inttostr(ret) +')', mtError, [mbOK], 0);

    setLength(Result, len);

    for arg := 0 to len - 1 do begin
        Result[arg] := data[arg];
{$IFDEF DEBUG}
        if (assigned(debug)) then
            debug.lines.add('    ARG[' +  inttostr(arg) + '] : ' + inttostr(Result[arg]));
{$ENDIF}
    end;
{$IFDEF DEBUG}
    if (assigned(debug)) then
        debug.lines.add('');
{$ENDIF}
end;

{---- Conversion Functions ----}

function TMotor.steps2units(steps: integer; units: TMotorUnits): real;
begin
    case (units) of
        muSteps       : Result := steps;
        muRotations   : Result := (1           / (STEPPING_FACTOR[fStepping] * fspr)) * steps;
        muDegrees     : Result := (360         / (STEPPING_FACTOR[fStepping] * fspr)) * steps;
        muRadians     : Result := (2 * PI      / (STEPPING_FACTOR[fStepping] * fspr)) * steps;
        muMillimeters : Result := (fgear_ratio / (STEPPING_FACTOR[fStepping] * fspr)) * steps;
    end;
end;

function TMotor.units2steps(value: real; units: TMotorUnits): integer;
begin
    case (units) of
        muSteps       : Result := round(value);
        muRotations   : Result := round(((STEPPING_FACTOR[fStepping] * fspr) /           1) * value);
        muDegrees     : Result := round(((STEPPING_FACTOR[fStepping] * fspr) /         360) * value);
        muRadians     : Result := round(((STEPPING_FACTOR[fStepping] * fspr) /      2 * PI) * value);
        muMillimeters : Result := round(((STEPPING_FACTOR[fStepping] * fspr) / fgear_ratio) * value);
    end;
end;

function TMotor.int2bytes(value: integer): TByteArray;
begin
    setLength(Result, 4);
    Result[0] := (value shr 24) AND $FF;
    Result[1] := (value shr 16) AND $FF;
    Result[2] := (value shr  8) AND $FF;
    Result[3] := (value shr  0) AND $FF;
end;

function TMotor.word2bytes(value: word): TByteArray;
begin
    setLength(Result, 2);
    Result[0] := (value shr  8) AND $FF;
    Result[1] := (value shr  0) AND $FF;
end;

function TMotor.bytes2word(bytes: TByteArray): word;
begin
    Result := (bytes[0] shl 8) + bytes[1];
end;

function TMotor.bytes2int(bytes: TByteArray): integer;
begin
    Result := (bytes[0] shl 24) + (bytes[1] shl 16) + (bytes[2] shl 8) + (bytes[3] shl 0);
end;

{---- Property Handling ----}

procedure TMotor.set_int_prop(index: integer; value: word);
begin
    case (index) of
        USB_CMD_MOTOR_CURRENT :
        begin
            fCurrent := value;
            cmd_write(USB_CMD_MOTOR_CURRENT, word2bytes(fCurrent));
        end;

        USB_CMD_MOTOR_IDLE_CURRENT :
        begin
            fIdleCurrent := value;
            cmd_write(USB_CMD_MOTOR_IDLE_CURRENT, word2bytes(fIdleCurrent));
        end;
    end;
end;

function TMotor.get_int_prop(index: integer): word;
var
    len : integer;
    data: TByteArray;
begin
    case (index) of
        USB_CMD_MOTOR_CURRENT :
        begin
            len := 4;
            data := cmd_read(USB_CMD_MOTOR_CURRENT, len);
            fCurrent := bytes2int(data);
            Result := fCurrent;
        end;

        USB_CMD_MOTOR_IDLE_CURRENT :
        begin
            len := 4;
            data := cmd_read(USB_CMD_MOTOR_IDLE_CURRENT, len);
            fIdleCurrent := bytes2int(data);
            Result := fIdleCurrent;
        end;
    end;
end;

procedure TMotor.set_real_prop(index: integer; value: real);
begin
    case (index) of
        USB_CMD_MOTOR_POSITION :
        begin
            fPosition := units2steps(value, fUnits);
            cmd_write(USB_CMD_MOTOR_POSITION, int2bytes(fPosition));
        end;

        USB_CMD_MOTOR_VELOCITY :
        begin
            fVelocity := units2steps(value, fUnits);
            cmd_write(USB_CMD_MOTOR_VELOCITY, int2bytes(fVelocity));
        end;

        USB_CMD_MOTOR_ACCEL    :
        begin
            fAcceleration := units2steps(value, fUnits);
            cmd_write(USB_CMD_MOTOR_ACCEL, int2bytes(fAcceleration));
        end;

        USB_CMD_MOTOR_DECEL    :
        begin
            fDeceleration := units2steps(value, fUnits);
            cmd_write(USB_CMD_MOTOR_DECEL, int2bytes(fDeceleration));
        end;
    end;
end;

function TMotor.get_real_prop(index: integer): real;
var
    len : integer;
    data: TByteArray;
begin
    case (index) of
        USB_CMD_MOTOR_POSITION :
        begin
            len := 4;
            data := cmd_read(USB_CMD_MOTOR_POSITION, len);
            fposition := bytes2int(data);
            Result := steps2units(fPosition, fUnits);
        end;

        USB_CMD_MOTOR_REMSTEPS :
        begin
            len := 4;
            data := cmd_read(USB_CMD_MOTOR_REMSTEPS, len);
            fRemaining := bytes2int(data);
            Result := steps2units(fRemaining, fUnits);
        end;

        USB_CMD_MOTOR_VELOCITY :
        begin
            len := 4;
            data := cmd_read(USB_CMD_MOTOR_VELOCITY, len);
            fVelocity := bytes2int(data);
            Result := steps2units(fVelocity, fUnits);
        end;

        USB_CMD_MOTOR_ACCEL    :
        begin
            len := 4;
            data := cmd_read(USB_CMD_MOTOR_ACCEL, len);
            fAcceleration := bytes2int(data);
            Result := steps2units(fAcceleration, fUnits);
        end;

        USB_CMD_MOTOR_DECEL    :
        begin
            len := 4;
            data := cmd_read(USB_CMD_MOTOR_DECEL, len);
            fDeceleration := bytes2int(data);
            Result := steps2units(fDeceleration, fUnits);
        end;
    end;
end;

procedure TMotor.set_stepping(const value: TMotorStepping);
var
    tmp : TByteArray;
begin
    fStepping := value;
    setLength(tmp, 1);
    tmp[0] := byte(fStepping);
    cmd_write(USB_CMD_MOTOR_STEPPING, tmp);
end;

function TMotor.get_stepping: TMotorStepping;
var
    len : integer;
    data: TByteArray;
begin
    len := 4;
    data := cmd_read(USB_CMD_MOTOR_STEPPING, len);
    fStepping := TMotorStepping(data[0]);
    Result := fStepping;
end;

procedure TMotor.set_led(index: integer; value: boolean);
var
    tmp : TByteArray;
    l : integer;
begin
    if (index < 3) AND (index >= 0) then begin
        fLED[index] := value;
        setLength(tmp, 1);

        tmp[0] := 0;

        for l := 0 to 2 do
            if (fLED[l]) then
                tmp[0] := tmp[0] + (1 shl l);

        cmd_write(USB_CMD_IO_LED, tmp);
    end;
end;

function TMotor.get_fullrotation: real;
begin
    Result := steps2units(fFSPR, fUnits);
end;                 

{---- Motion Control ----}

procedure TMotor.move_to(position: real);
var
    steps : integer;
begin
    steps := units2steps(position, fUnits);
    cmd_write(USB_CMD_MOTOR_GOTO, int2bytes(steps));
end;

procedure TMotor.move(distance: real);
var
    steps : integer;
begin
    steps := units2steps(distance, fUnits);
    cmd_write(USB_CMD_MOTOR_MOVE, int2bytes(steps));
end;

procedure TMotor.brake;
begin
    cmd_write(USB_CMD_MOTOR_BRAKE, NIL);
end;

procedure TMotor.stop;
begin
    cmd_write(USB_CMD_MOTOR_STOP, NIL);
end;

{---- State Control ----}

procedure TMotor.enable(value: boolean);
var
    tmp : TByteArray;
begin
    fEnabled := value;
    setLength(tmp, 1);

    if value then begin
        tmp[0] := 4;
        cmd_write(USB_CMD_MOTOR_STATE, tmp);     // Enabled
    end else begin
        tmp[0] := 1;
        cmd_write(USB_CMD_MOTOR_STATE, tmp);     // Disabled
    end;
end;

procedure TMotor.reset;
var
    tmp : TByteArray;
begin
    set_real_prop(USB_CMD_MOTOR_POSITION, 0); // Reset Position to 0

    setLength(tmp, 1);
    
    tmp[0] := 5;
    cmd_write(USB_CMD_MOTOR_STATE, tmp); // Reset

    tmp[0] := 4;
    cmd_write(USB_CMD_MOTOR_STATE, tmp); // Active
end;

procedure TMotor.sleep(value: boolean);
var
    tmp : TByteArray;
begin
    fSleeping := value;
    setLength(tmp, 1);

    if value then begin
        tmp[0] := 0;
        cmd_write(USB_CMD_MOTOR_STATE, tmp);     // Sleep
    end else begin
        tmp[0] := 3;
        cmd_write(USB_CMD_MOTOR_STATE, tmp);     // WakeUp
    end;
end;

{---- CAN Bus Functions ----}

procedure TMotor.can_msg_send(id : integer; rtr : boolean; size: integer; data: TByteArray);
var
    b : integer;
    value : integer;
begin
    if (size > 8) then size := 8;

    for b := 0 to size - 1 do
        ep0_buf[b] := data[b];

    if (rtr) then
        value := (1 shl 8)
    else
        value := 0;

    value := value + 0;     // Send from Buffer 0
                       
    usb_control_msg(USB.handle, USB_TYPE_VENDOR or USB_RECIP_ENDPOINT or USB_ENDPOINT_OUT, USB_CMD_CAN_SEND, value, id, ep0_buf, size, 100);
end;

{---- Debug & Test Functions ----}

procedure TMotor.control_msg;
var
    b : integer;
    data : array[0..15] of byte;
begin
    usb_control_msg(USB.handle, USB_TYPE_VENDOR or USB_RECIP_ENDPOINT or USB_ENDPOINT_IN, 0, 0, 0, data, 4, 500);

{$IFDEF DEBUG}
    for b := 0 to 15 do begin
        if (assigned(debug)) then
            debug.lines.add('DATA : [' + inttostr(b) + '] = ' + inttostr(data[b]));
    end;

{$ENDIF}
end;

end.
