A pure Dart library for communicating with a Akai Fire midi controller.

## Usage

A simple usage example:

```dart
void main() async {
  final midiDevices = AlsaMidiDevice.getDevices();
  if (midiDevices.isEmpty) {
    print('missing akai fire controller');
    exit(1);
  }
  final fire = FireDevice(midiDevices.first);
  print('fire device: $fire');
}
```

see `example\dart_fire_midi_example.dart` for a more detailed example of how to use the package.

## Acknowledgments

This package is only possible thanks to the work of [documenting the Akai Fire's midi implementation done by Paul Curtis at Segger](https://blog.segger.com/decoding-the-akai-fire-part-1/).


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/maks/dart_fire_midi/issues
