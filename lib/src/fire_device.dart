import 'dart:async';
import 'dart:typed_data';

import 'package:midi/midi.dart';

import 'input_events.dart';

/// valid RGB values are 7it, ie. 0-127 ONLY
class PadColor {
  final int r;
  final int g;
  final int b;

  PadColor(this.r, this.g, this.b);

  factory PadColor.off() => PadColor(0, 0, 0);
}


class FireDevice {
  static const _aBitMutate = [
    [13, 19, 25, 31, 37, 43, 49],
    [0, 20, 26, 32, 38, 44, 50],
    [1, 7, 27, 33, 39, 45, 51],
    [2, 8, 14, 34, 40, 46, 52],
    [3, 9, 15, 21, 41, 47, 53],
    [4, 10, 16, 22, 28, 48, 54],
    [5, 11, 17, 23, 29, 35, 55],
    [6, 12, 18, 24, 30, 36, 42],
  ];

  final Uint8List _aOLEDBitmap = Uint8List(1175);

  final AlsaMidiDevice _device;

  late StreamSubscription<MidiMessage> _midiSubscription;

  final _inputStreamController = StreamController<FireInputEvent>();

  Stream<FireInputEvent> get inputEvents => _inputStreamController.stream;

  FireDevice(this._device);

  Future<void> connectDevice() async {
    await _device.connect();

    _midiSubscription = _device.receivedMessages.listen((mesg) {
      _inputStreamController.add(FireInputEvent.fromMidi(mesg.data));
    });
  }

  // turn off all lights
  void sendAllOff() {
    _device.send(Uint8List.fromList([0xB0, 0x7F, 0]));
  }

  // turn on all lights
  void sendAllOn() {
    _device.send(Uint8List.fromList([0xB0, 0x7F, 1]));
  }

  /// send monochrome bit map to the OLED display
  /// MUST be 128 x 64 in length!!
  void sendBitmap(List<bool> bitmap) async {
    _sendSysexBitmap(bitmap);
  }

  /// turn on and set the colour of a pad button
  void colorPad(int padRow, int padColumn, PadColor color) {
    final sysexHeader = Uint8List.fromList([
      0xF0, // System Exclusive
      0x47, // Akai Manufacturer ID
      0x7F, // The All-Call address
      0x43, // “Fire” product
      0x65, // Write LED cmd
      0x00, // mesg length - high byte
      0x04, // mesg length - low byte
    ]);
    final sysexFooter = Uint8List.fromList([
      0xF7, // End of Exclusive
    ]);

    final ledData = Uint8List.fromList([
      (padRow * 16 + padColumn),
      color.r,
      color.g,
      color.b,
    ]);

    final b = BytesBuilder();
    b.add(sysexHeader);
    b.add(ledData);
    b.add(sysexFooter);

    final midiData = b.toBytes();

    _device.send(Uint8List.fromList(midiData));
  }

  void disconnectDevice() {
    _midiSubscription.cancel();
    _device.disconnect();
  }

  void _sendSysexBitmap(List<bool> boolMap) {
    final bitmap = _aOLEDBitmap;
    // these need to go after the bitmap length high/low bytes
    // but need to be included in the payload length, hence we just
    // put them at the start of the sent "bitmap" payload
    _aOLEDBitmap[0] = 0x00;
    _aOLEDBitmap[1] = 0x07;
    _aOLEDBitmap[2] = 0x00;
    _aOLEDBitmap[3] = 0x7f;

    // Clear the screen
    var x = 0;
    var y = 0;
    for (x = 0; x < 128; ++x) {
      for (y = 0; y < 64; ++y) {
        _plotPixel(x, y, 0);
      }
    }

    x = 0;
    y = 0;
    for (x = 0; x < 128; ++x) {
      for (y = 0; y < 64; ++y) {
        final pxl = boolMap[x + (y * 128)] ? 1 : 0;
        _plotPixel(x, y, pxl);
      }
    }

    final length = Uint8List.fromList([bitmap.length]);

    final sysexHeader = Uint8List.fromList([
      0xF0, // System Exclusive
      0x47, // Akai Manufacturer ID
      0x7F, // The All-Call address
      0x43, // “Fire” product
      0x0E, // “Write OLED” command
      //(length[0] >> 7), // Payload length high
      0x09,
      (length[0] & 0x7F), // Payload length low
    ]);

    final sysexFooter = Uint8List.fromList([
      0xF7, // End of Exclusive
    ]);

    final b = BytesBuilder();
    b.add(sysexHeader);
    b.add(bitmap);
    b.add(sysexFooter);

    final midiData = b.toBytes();

    _device.send(Uint8List.fromList(midiData));
  }

  /// Plot pixel on bitmap.
  /// X - X coordinate of pixel (0..127).
  /// Y - Y coordinate of pixel (0..63).
  /// C - Color, 0=black, nonzero=white.
  /// ref: https://blog.segger.com/decoding-the-akai-fire-part-3/
  void _plotPixel(int X, int Y, int C) {
    int remapBit;
    //
    if (X < 128 && Y < 64) {
      //
      // Unwind 128x64 arrangement into a 1024x8 arrangement of pixels.
      //
      X += 128 * (Y ~/ 8);
      Y %= 8;

      //
      // Remap by tiling 7x8 block of translated pixels.
      //
      remapBit = _aBitMutate[Y][X % 7];
      if (C > 0) {
        _aOLEDBitmap[4 + X ~/ 7 * 8 + remapBit ~/ 7] |= 1 << (remapBit % 7);
      } else {
        _aOLEDBitmap[4 + X ~/ 7 * 8 + remapBit ~/ 7] &= ~(1 << (remapBit % 7));
      }
    }
  }
}
