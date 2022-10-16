// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'cc_inputs.dart';

abstract class FireInputEvent {
  static FireInputEvent fromMidi(Uint8List data) {
    // print("EVENT:$data");
    DialType? maybeDialType = DialType.values.firstWhereOrNull((dt) => dt.id == data[1]);
    if (data[2] == CC.selectDown) {
      maybeDialType = DialType.Select;
    }
    if (maybeDialType != null) {
      final dialMotionValue = data[2];
      final dialVelocity = (dialMotionValue > 64) ? 128 - dialMotionValue : dialMotionValue;
      late final DialDirection dir;
      if (data[0] == 176) {
        dir = (dialMotionValue > 64) ? DialDirection.Left : DialDirection.Right;
      } else {
        dir = (data[0] == CC.buttonDown) ? DialDirection.TouchOn : DialDirection.TouchOff;
      }
      return DialEvent(maybeDialType, dir, dialVelocity);
    } else if (data[0] == CC.buttonDown) {
      final int buttonVelocity = data[2];
      return _getButton(data[1], true, buttonVelocity);
    } else if (data[0] == CC.buttonUp) {
      return _getButton(data[1], false, 0);
    }
    return UnknownEvent();
  }

  static ButtonEvent _getButton(int code, bool down, int velocity) {
    final dir = down ? ButtonDirection.Down : ButtonDirection.Up;

    if (PadEvent.isValidPadId(code)) {
      return PadEvent.fromMidi(code, dir, velocity);
    }

    switch (code) {
      case CC.bankSelect:
        return ButtonEvent(ButtonType.BankSelect, dir, velocity);
      case CC.volume:
        return ButtonEvent(ButtonType.Volume, dir, velocity);
      case CC.pan:
        return ButtonEvent(ButtonType.Pan, dir, velocity);
      case CC.filter:
        return ButtonEvent(ButtonType.Filter, dir, velocity);
      case CC.resonance:
        return ButtonEvent(ButtonType.Resonance, dir, velocity);
      case CC.patternUp:
        return ButtonEvent(ButtonType.PatternUp, dir, velocity);
      case CC.patternDown:
        return ButtonEvent(ButtonType.PatterDown, dir, velocity);
      case CC.browser:
        return ButtonEvent(ButtonType.Browser, dir, velocity);
      case CC.selectDown:
        return ButtonEvent(ButtonType.Select, dir, velocity);
      case CC.gridLeft:
        return ButtonEvent(ButtonType.GridLeft, dir, velocity);
      case CC.gridRight:
        return ButtonEvent(ButtonType.GridRight, dir, velocity);

      case CC.muteButton1:
        return ButtonEvent(ButtonType.MuteButton1, dir, velocity);
      case CC.muteButton2:
        return ButtonEvent(ButtonType.MuteButton2, dir, velocity);
      case CC.muteButton3:
        return ButtonEvent(ButtonType.MuteButton3, dir, velocity);
      case CC.muteButton4:
        return ButtonEvent(ButtonType.MuteButton4, dir, velocity);

      case CC.step:
        return ButtonEvent(ButtonType.Step, dir, velocity);
      case CC.note:
        return ButtonEvent(ButtonType.Note, dir, velocity);
      case CC.drum:
        return ButtonEvent(ButtonType.Drum, dir, velocity);
      case CC.perform:
        return ButtonEvent(ButtonType.Perform, dir, velocity);
      case CC.shift:
        return ButtonEvent(ButtonType.Shift, dir, velocity);
      case CC.alt:
        return ButtonEvent(ButtonType.Alt, dir, velocity);
      case CC.pattern:
        return ButtonEvent(ButtonType.Pattern, dir, velocity);
      case CC.play:
        return ButtonEvent(ButtonType.Play, dir, velocity);
      case CC.stop:
        return ButtonEvent(ButtonType.Stop, dir, velocity);
      case CC.record:
        return ButtonEvent(ButtonType.Record, dir, velocity);

      default:
        throw UnimplementedError();
    }
  }
}

enum DialType {
  Select(CC.select),
  Volume(CC.volume),
  Pan(CC.pan),
  Filter(CC.filter),
  Resonance(CC.resonance);

  final int id;
  const DialType(this.id);
}

enum ButtonType {
  PatternUp,
  PatterDown,
  Browser,
  GridLeft,
  GridRight,
  BankSelect,
  MuteButton1,
  MuteButton2,
  MuteButton3,
  MuteButton4,
  Step,
  Note,
  Drum,
  Perform,
  Shift,
  Alt,
  Pattern,
  Play,
  Stop,
  Record,
  Volume,
  Pan,
  Filter,
  Resonance,
  Select,
  Pad
}

enum DialDirection {
  Left, Right, TouchOn, TouchOff
}

enum ButtonDirection { Up, Down }

class DialEvent extends FireInputEvent {
  final DialDirection direction;
  final DialType type;
  final int velocity;

  DialEvent(this.type, this.direction, this.velocity);

  @override
  String toString() {
    return 'Dial: $type dir: $direction vel:$velocity';
  }
}

class ButtonEvent extends FireInputEvent {
  final ButtonType type;
  final ButtonDirection direction;
  final int velocity;

  ButtonEvent(this.type, this.direction, this.velocity);

  @override
  String toString() {
    return 'Button: $type dir: $direction vel:$velocity';
  }
}

class UnknownEvent extends FireInputEvent {}

class PadEvent extends ButtonEvent {
  static const _baseId = 54;
  static const _endId = 117;

  static const padsPerRow = 16;

  final int row;
  final int column;

  static bool isValidPadId(int id) => (id >= _baseId) && (id <= _endId);

  PadEvent(this.row, this.column, ButtonDirection direction, int velocity) : super(ButtonType.Pad, direction, velocity);

  factory PadEvent.fromMidi(int id, ButtonDirection direction, int velocity) {
    final offset = id - _baseId;

    if (offset > 63) {
      throw Exception('invalid pad id: $id');
    }
    return PadEvent(
      offset ~/ padsPerRow,
      offset % padsPerRow,
      direction,
      velocity,
    );
  }

  @override
  String toString() => 'PadInput $row:$column dir: $direction';
}
