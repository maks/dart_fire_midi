import 'dart:async';
import 'dart:typed_data';

import 'package:midi/midi.dart';

class FireDevice {
  final AlsaMidiDevice _device;

  late StreamSubscription<MidiMessage> _midiSubscription;

  FireDevice(this._device);

  Future<void> connectDevice() async {
    await _device.connect();

    _midiSubscription = _device.receivedMessages.listen((mesg) {
      print('MIDI MESG: ${mesg.toDictionary}');
    });
  }

  void sendAllOff() {
    print('sending all OFF to:');
    _device.send(Uint8List.fromList([0xB0, 0x7F, 0]));
  }

  void sendAllOn() {
    print('sending all ON to:');
    _device.send(Uint8List.fromList([0xB0, 0x7F, 1]));
  }

  void disconnectDevice() {
    _midiSubscription.cancel();
    _device.disconnect();
  }
}
