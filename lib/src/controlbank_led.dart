import 'dart:typed_data';

class ControlBankLED {
  static Uint8List off() {
    return Uint8List.fromList([
      0xB0, // midi control change code
      0x1B,
      0,
    ]);
  }

  static Uint8List on({
    bool channel = false,
    bool mixer = false,
    bool user1 = false,
    bool user2 = false,
  }) {
    final value = Uint8List(1);
    value[0] = 0x10;

    if (channel) {
      value[0] = value[0] | 0x01;
    }
    if (mixer) {
      value[0] = value[0] | 0x02;
    }
    if (user1) {
      value[0] = value[0] | 0x04;
    }
    if (user2) {
      value[0] = value[0] | 0x08;
    }

    return Uint8List.fromList([
      0xB0, // midi control change code
      0x1B,
      value[0],
    ]);
  }
}
