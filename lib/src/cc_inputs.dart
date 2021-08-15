import 'dart:typed_data';

class CC {
  static const buttonDown = 144;
  static const buttonUp = 128;
  static const dialRotate = 176;

  static const rotateLeft = 127;
  static const rotateRight = 1;

  static const dialTouchOn = 127;
  static const dialTouchOff = 0;

  static const volume = 16;
  static const pan = 17;
  static const filter = 18;
  static const resonance = 19;

  static const selectDown = 25;
  static const bankSelect = 26;

  static const patternUp = 31;
  static const patternDown = 32;
  static const browser = 33;
  static const gridLeft = 34;
  static const gridRight = 35;

  static const muteButton1 = 36;
  static const muteButton2 = 37;
  static const muteButton3 = 38;
  static const muteButton4 = 39;

  static const step = 44;
  static const note = 45;
  static const drum = 46;
  static const perform = 47;
  static const shift = 48;
  static const alt = 49;
  static const pattern = 50;

  static const play = 51;
  static const stop = 52;
  static const record = 53;

  static const select = 118;

  // All
  static const off = 0;

  // Red Only
  // pattern up/down, browser, grid left/right
  static const paleRed = 1;
  static const red = 2;

  // Green only
  // mute 1,2,3,4
  static const paleGreen = 1;
  static const green = 2;

  // Yellow only
  // alt, stop
  static const paleYellow = 1;
  static const yellow = 2;

  // Yellow-Red
  // step, note, drum, perform, shift, record
  static const paleYellow2 = 1;
  static const paleRed2 = 2;
  static const yellow2 = 3;
  static const red2 = 4;

  // Yellow-Green
  // pattern, play
  static const paleGreen3 = 1;
  static const paleYellow3 = 2;
  static const green3 = 3;
  static const yellow3 = 4;

  static Uint8List on(int id, int value) {
    return Uint8List.fromList([
      0xB0, // midi control change code
      id,
      value,
    ]);
  }
}
