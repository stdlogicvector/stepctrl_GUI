{
  LibUSB.DLL's Delphi declarations.

  Modify from PowerSwitch's LIBUSB.pas.

  This file direct access LibUSB.dll, not like PowerSwitch use USBLibExport.dll.

  Date:    2006-Nov-15
  Version: 1.0
  Author:  Shaoziyang (shaoziyang@gmail.com)

  Usage:
  1. add LibUSB to uses section;
  2. define a globe value as TLIBUSB class;
  3. use USBdevInit to initial user USB device;
  4. set user's PID and VID;
  5. use USBdevOpen to open USB device;
  6. use USBdevRead and USBdevWrite to access user's USB device;
  7. use USBdevClose to close device when exit;

}

unit libusb;

interface

uses
  Windows;

const
  LIBUSB_PATH_MAX = 512;

  USB_OK = 0; // 0 = success from functions < 0 is failed

  { Device and/or Interface Class codes }
  USB_CLASS_PER_INTERFACE = 0; { for DeviceClass }
  USB_CLASS_AUDIO = 1;
  USB_CLASS_COMM = 2;
  USB_CLASS_HID = 3;
  USB_CLASS_PRINTER = 7;
  USB_CLASS_MASS_STORAGE = 8;
  USB_CLASS_HUB = 9;
  USB_CLASS_DATA = 10;
  USB_CLASS_VENDOR_SPEC = $FF;

  // Descriptor types
  USB_DT_DEVICE = $01;
  USB_DT_CONFIG = $02;
  USB_DT_STRING = $03;
  USB_DT_INTERFACE = $04;
  USB_DT_ENDPOINT = $05;

  USB_DT_HID = $21;
  USB_DT_REPORT = $22;
  USB_DT_PHYSICAL = $23;
  USB_DT_HUB = $29;

  // Descriptor sizes per descriptor type
  USB_DT_DEVICE_SIZE = 18;
  USB_DT_CONFIG_SIZE = 9;
  USB_DT_INTERFACE_SIZE = 9;
  USB_DT_ENDPOINT_SIZE = 7;
  USB_DT_ENDPOINT_AUDIO_SIZE = 9; // Audio extension
  USB_DT_HUB_NONVAR_SIZE = 7;

  // Endpoint descriptor
  USB_MAXENDPOINTS = 32;

  USB_ENDPOINT_ADDRESS_MASK = $0F; // in bEndpointAddress
  USB_ENDPOINT_DIR_MASK = $80;

  USB_ENDPOINT_TYPE_MASK = $03; // in bmAttributes
  USB_ENDPOINT_TYPE_CONTROL = 0;
  USB_ENDPOINT_TYPE_ISOCHRONOUS = 1;
  USB_ENDPOINT_TYPE_BULK = 2;
  USB_ENDPOINT_TYPE_INTERRUPT = 3;

  // Interface descriptor
  USB_MAXINTERFACES = 32;

  USB_MAXALTSETTING = 128; // Hard limit

  // Configuration descriptor information..
  USB_MAXCONFIG = 8;

  // Standard requests
  USB_REQ_GET_STATUS = $00;
  USB_REQ_CLEAR_FEATURE = $01;
  // $02 is reserved
  USB_REQ_SET_FEATURE = $03;
  // $04 is reserved
  USB_REQ_SET_ADDRESS = $05;
  USB_REQ_GET_DESCRIPTOR = $06;
  USB_REQ_SET_DESCRIPTOR = $07;
  USB_REQ_GET_CONFIGURATION = $08;
  USB_REQ_SET_CONFIGURATION = $09;
  USB_REQ_GET_INTERFACE = $0A;
  USB_REQ_SET_INTERFACE = $0B;
  USB_REQ_SYNCH_FRAME = $0C;

  USB_TYPE_STANDARD = ($00 shl 5);
  USB_TYPE_CLASS = ($01 shl 5);
  USB_TYPE_VENDOR = ($02 shl 5);
  USB_TYPE_RESERVED = ($03 shl 5);

  USB_RECIP_DEVICE = $00;
  USB_RECIP_INTERFACE = $01;
  USB_RECIP_ENDPOINT = $02;
  USB_RECIP_OTHER = $03;

  // Various libusb API related stuff
  USB_ENDPOINT_IN = $80;
  USB_ENDPOINT_OUT = $00;

  // Error codes
  USB_ERROR_BEGIN = 500000;

  // Timeout
  USB_TIMEOUT = 100;

type
  // All standard descriptors have these 2 fields in common
  usb_descriptor_header = packed record
    bLength,
      bDescriptorType: byte;
  end;

  // String descriptor
  usb_string_descriptor = packed record
    bLength,
      bDescriptorType: byte;
    wData: packed array[0..0] of word;
  end;

  usb_hid_descriptor = packed record
    bLength,
      bDescriptorType: byte;
    bcdHID: word;
    bCountryCode,
      bNumDescriptors: byte;
  end;

  // Endpoint descriptor
  pusb_endpoint_descriptor = ^usb_endpoint_descriptor;
  usb_endpoint_descriptor = packed record
    bLength,
      bDescriptorType,
      bEndpointAddress,
      bmAttributes: byte;

    wMaxPacketSize: word;

    bInterval,
      bRefresh,
      bSynchAddress: byte;

    extra: PByte; // Extra descriptors
    extralen: integer;
  end;
  // pascal translation of C++ struc
  TArray_usb_endpoint_descriptor = packed array[0..65535] of usb_endpoint_descriptor;
  PArray_usb_endpoint_descriptor = ^TArray_usb_endpoint_descriptor;

  // Interface descriptor
  pusb_interface_descriptor = ^usb_interface_descriptor;
  usb_interface_descriptor = packed record
    bLength,
      bDescriptorType,
      bInterfaceNumber,
      bAlternateSetting,
      bNumEndpoints,
      bInterfaceClass,
      bInterfaceSubClass,
      bInterfaceProtocol,
      iInterface: byte;

    endpoint: PArray_usb_endpoint_descriptor;

    extra: PByte; // Extra descriptors
    extralen: integer;
  end;
  // pascal translation of C++ struc
  TArray_usb_interface_descriptor = packed array[0..65535] of usb_interface_descriptor;
  PArray_usb_interface_descriptor = ^TArray_usb_interface_descriptor;

  pusb_interface = ^usb_interface;
  usb_interface = packed record
    altsetting: PArray_usb_interface_descriptor;
    num_altsetting: integer;
  end;
  // pascal translation of C++ struc
  TArray_usb_interface = packed array[0..65535] of usb_interface;
  PArray_usb_interface = ^TArray_usb_interface;

  // Configuration descriptor information..
  pusb_config_descriptor = ^usb_config_descriptor;
  usb_config_descriptor = packed record
    bLength,
      bDescriptorType: byte;

    wTotalLength: word;

    bNumInterfaces,
      bConfigurationValue,
      iConfiguration,
      bmAttributes,
      MaxPower: byte;

    iinterface: PArray_usb_interface;

    extra: PByte; // Extra descriptors
    extralen: integer;
  end;
  // pascal translation of C++ struc
  TArray_usb_config_descriptor = packed array[0..65535] of usb_config_descriptor;
  PArray_usb_config_descriptor = ^TArray_usb_config_descriptor;

  // Device descriptor
  usb_device_descriptor = packed record
    bLength,
      bDescriptorType: byte;
    bcdUSB: word;

    bDeviceClass,
      bDeviceSubClass,
      bDeviceProtocol,
      bMaxPacketSize0: byte;

    idVendor,
      idProduct,
      bcdDevice: word;

    iManufacturer,
      iProduct,
      iSerialNumber,
      bNumConfigurations: byte;
  end;

  usb_ctrl_setup = packed record
    bRequestType,
      bRequest: byte;
    wValue,
      wIndex,
      wLength: word;
  end;

  pusb_bus = ^usb_bus;
  pusb_device = ^usb_device;
  usb_device = packed record
    next, prev: pusb_device;
    filename: packed array[0..LIBUSB_PATH_MAX - 1] of char;
    bus: pusb_bus;
    descriptor: usb_device_descriptor;
    config: PArray_usb_config_descriptor;

    dev: pointer; // Darwin support
  end;

  usb_bus = packed record
    next, prev: pusb_bus;
    dirname: packed array[0..LIBUSB_PATH_MAX - 1] of char;
    devices: pusb_device;
    location: longint;
  end;

  pusb_dev_handle = ^usb_dev_handle;
  usb_dev_handle = packed record
    fd: Integer;
    bus: pusb_bus;
    dev: pusb_device;
    cfg: Integer;
    intfac: Integer;
    altset: Integer;
    impl_info: Pointer;
  end;

  // Version information, Windows specific
  pusb_version = ^usb_version;
  usb_version = packed record
      dllmajor,
      dllminor,
      dllmicro,
      dllnano: integer;
      drivermajor,
      driverminor,
      drivermicro,
      drivernano: integer;
  end;

  //LibUSB functions declarations
procedure usb_init; cdecl; external 'libusb0.dll' name 'usb_init';
procedure usb_set_debug(level: Integer); cdecl; external 'libusb0.dll' name 'usb_set_debug';
function usb_devices(dev: pusb_dev_handle): pusb_device; cdecl; external 'libusb0.dll' name 'usb_device';
function usb_find_busses: Integer; cdecl; external 'libusb0.dll' name 'usb_find_busses';
function usb_find_devices: Integer; cdecl; external 'libusb0.dll' name 'usb_find_devices';
function usb_get_busses: pusb_bus; cdecl; external 'libusb0.dll' name 'usb_get_busses';

function usb_get_version: pusb_version; cdecl; external 'libusb0.dll' name 'usb_get_version';
function usb_open(dev: pusb_device): pusb_dev_handle; cdecl; external 'libusb0.dll' name 'usb_open';
function usb_close(dev: pusb_dev_handle): Integer; cdecl; external 'libusb0.dll' name 'usb_close';
function usb_get_string(dev: pusb_dev_handle; index, langid: Integer; buf: array of char; len: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_get_string';
function usb_get_string_simple(dev: pusb_dev_handle; index: Integer; buf: array of char; len: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_get_string_simple';

function usb_get_descriptor_by_endpoint(dev: pusb_dev_handle; ep: Integer; tp: Byte; index: Byte; var buf; size: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_get_descriptor_by_endpoint';
function usb_get_descriptor(dev: pusb_dev_handle; tp, index: Byte; var buf; size: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_get_descriptor';

function usb_control_msg(dev: pusb_dev_handle; requesttype, request, value, index: Integer; var bytes; size, timeout: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_control_msg';
function usb_bulk_write(dev: pusb_dev_handle; ep: Integer; bytes: PChar; size, timeout: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_bulk_write';
function usb_bulk_read(dev: pusb_dev_handle; ep: Integer; bytes: PChar; size, timeout: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_bulk_read';
function usb_interrupt_write(dev: pusb_dev_handle; ep: Integer; bytes: PChar; size, timeout: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_interrupt_write';
function usb_interrupt_read(dev: pusb_dev_handle; ep: Integer; bytes: PChar; size, timeout: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_interrupt_read';

function usb_set_configuration(dev: pusb_dev_handle; configuration: Integer): pusb_device; cdecl; external 'libusb0.dll' name 'usb_set_configuration';
function usb_claim_interface(dev: pusb_dev_handle; interfaces: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_claim_interface';
function usb_release_interface(dev: pusb_dev_handle; interfaces: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_release_interface';
function usb_set_altinterface(dev: pusb_dev_handle; alternate: Integer): Integer; cdecl; external 'libusb0.dll' name 'usb_set_altinterface';
function usb_resetep(dev: pusb_dev_handle; ep: Word): Integer; cdecl; external 'libusb0.dll' name 'usb_resetep';
function usb_clear_halt(dev: pusb_dev_handle; ep: Word): Integer; cdecl; external 'libusb0.dll' name 'usb_clear_halt';
function usb_reset(dev: pusb_dev_handle): Integer; cdecl; external 'libusb0.dll' name 'usb_reset';

type
  TLIBUSB = packed record
    bus: pusb_bus;
    dev: pusb_device;
    handle: pusb_dev_handle;
    VID, PID: word;
    version: pusb_version;
    dat: array[0..255] of byte;
  end;

procedure USBdevInit(var usb: TLIBUSB);
function USBdevOpen(var usb: TLIBUSB): Boolean;
function USBdevClose(var usb: TLIBUSB): Boolean;

implementation

procedure USBdevInit(var usb: TLIBUSB);
begin
  usb.dev := nil;
  usb.handle := nil;
  usb_init;
  //usb_find_busses;
end;

function USBdevOpen(var usb: TLIBUSB): Boolean;
begin
  usb_find_busses;
  usb_find_devices;
  
  usb.dev := nil;
  usb.handle := nil;
  usb.bus := usb_get_busses;

  while usb.bus <> nil do
  begin
    usb.dev := usb.bus.devices;
    while usb.dev <> nil do
    begin
      if (usb.dev.descriptor.idVendor = usb.VID) and
        (usb.dev.descriptor.idProduct = usb.PID) then
      begin
        usb.handle := usb_open(usb.dev);
        if usb.handle <> nil then
          Result := True
        else
          Result := FALSE;
        Exit;
      end;
      usb.dev := usb.dev.next;
    end;
    usb.bus := usb.bus.next;
  end;
  Result := FALSE;
end;

function USBdevClose(var usb: TLIBUSB): Boolean;
begin
  Result := FALSE;
  if usb.handle = nil then
    Exit;
  if usb_close(usb.handle) = 0 then
  begin
    usb.dev := nil;
    usb.handle := nil;
    Result := True;
  end;
end;

end.

