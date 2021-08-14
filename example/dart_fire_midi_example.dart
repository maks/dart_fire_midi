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

  // typically ctrl-c in shell will generate a sigint
  ProcessSignal.sigint.watch().listen((signal) {
    print('sigint disconnecting');
    fire.disconnectDevice();
    exit(0);
  });
}
