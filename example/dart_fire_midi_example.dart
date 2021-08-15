import 'dart:io';

import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:midi/midi.dart';

void main() async {
  final midiDevices = AlsaMidiDevice.getDevices();
  if (midiDevices.isEmpty) {
    print('missing akai fire controller');
    exit(1);
  }
  final fire = FireDevice(midiDevices.first);
  print('fire device: $fire');
  await fire.connectDevice();

  fire.sendAllOff();
  print('init: all off');

  // uncomment to light up top left grid button blue
  // fire.colorPad(0, 0, PadColor(0, 0, 127));

  // uncomment to show grid on top wuaarter of the oled screen
  // final oled = List.filled(128 * 64, false);
  // for (var i = 0; i < 128 * 8; i++) {
  //   oled[i] = (i % 2) == 0;
  // }
  // fire.sendBitmap(oled);

  fire.inputEvents.listen((event) {
    print('input event: $event');
  });

  // typically ctrl-c in shell will generate a sigint
  ProcessSignal.sigint.watch().listen((signal) {
    print('sigint disconnecting');
    fire.disconnectDevice();
    exit(0);
  });
}
