import 'dart:io';

import 'package:dart_fire_midi/dart_fire_midi.dart' as fire;
import 'package:midi/midi.dart';

import 'extensions.dart';

void main() async {
  final midiDevices = AlsaMidiDevice.getDevices();
  if (midiDevices.isEmpty) {
    print('missing akai fire controller');
    exit(1);
  }

  final midiDev = midiDevices.firstWhereOrNull((dev) => dev.name.contains('FL STUDIO'));

  if (midiDev == null) {
    print('missing Akai Fire device');
    return;
  }
  if (!(await midiDev.connect())) {
    print('failed ot connect to Akai Fire device');
    return;
  }

  midiDev.send(fire.allOffMessage);
  print('init: all off');

  // uncomment to light up top left grid button blue
  midiDev.send(fire.colorPad(0, 0, fire.PadColor(10, 70, 50)));

  // show grid on top quarter of the oled screen
  final oled = List.filled(128 * 64, false);
  for (var i = 0; i < 128 * 8; i++) {
    oled[i] = (i % 2) == 0;
  }
  fire.sendBitmap(oled);

  midiDev.receivedMessages.listen((event) {
    print('input event: $event');
  });

  // typically ctrl-c in shell will generate a sigint
  ProcessSignal.sigint.watch().listen((signal) {
    print('sigint disconnecting');
    midiDev.disconnect();
    exit(0);
  });
}
