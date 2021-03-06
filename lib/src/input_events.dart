import 'dart:typed_data';

import 'cc_inputs.dart';

abstract class FireInputEvent {
  static FireInputEvent fromMidi(Uint8List data) {
    if (data[0] == CC.dialRotate) {
      return DialEvent(
        data[2] == 127 ? DialDirection.Left : DialDirection.Right,
        DialType.Select,
      );
    } else if (data[0] == CC.buttonDown) {
      return _getButton(data[1], true);
    } else if (data[0] == CC.buttonUp) {
      return _getButton(data[1], false);
    }
    return UnknownEvent();
  }

  static ButtonEvent _getButton(int code, bool down) {
    final dir = down ? ButtonDirection.Down : ButtonDirection.Up;

    if (PadEvent.isValidPadId(code)) {
      return PadEvent.fromMidi(code, dir);
    }

    switch (code) {
      case CC.bankSelect:
        return ButtonEvent(ButtonType.BankSelect, dir);
      case CC.volume:
        return ButtonEvent(ButtonType.Volume, dir);
      case CC.pan:
        return ButtonEvent(ButtonType.Pan, dir);
      case CC.filter:
        return ButtonEvent(ButtonType.Filter, dir);
      case CC.resonance:
        return ButtonEvent(ButtonType.Resonance, dir);
      case CC.patternUp:
        return ButtonEvent(ButtonType.PatternUp, dir);
      case CC.patternDown:
        return ButtonEvent(ButtonType.PatterDown, dir);
      case CC.browser:
        return ButtonEvent(ButtonType.Browser, dir);
      case CC.selectDown:
        return ButtonEvent(ButtonType.Select, dir);
      case CC.gridLeft:
        return ButtonEvent(ButtonType.GridLeft, dir);
      case CC.gridRight:
        return ButtonEvent(ButtonType.GridRight, dir);

      case CC.muteButton1:
        return ButtonEvent(ButtonType.MuteButton1, dir);
      case CC.muteButton2:
        return ButtonEvent(ButtonType.MuteButton2, dir);
      case CC.muteButton3:
        return ButtonEvent(ButtonType.MuteButton3, dir);
      case CC.muteButton4:
        return ButtonEvent(ButtonType.MuteButton4, dir);

      case CC.step:
        return ButtonEvent(ButtonType.Step, dir);
      case CC.note:
        return ButtonEvent(ButtonType.Note, dir);
      case CC.drum:
        return ButtonEvent(ButtonType.Drum, dir);
      case CC.perform:
        return ButtonEvent(ButtonType.Perform, dir);
      case CC.shift:
        return ButtonEvent(ButtonType.Shift, dir);
      case CC.alt:
        return ButtonEvent(ButtonType.Alt, dir);
      case CC.pattern:
        return ButtonEvent(ButtonType.Pattern, dir);
      case CC.play:
        return ButtonEvent(ButtonType.Play, dir);
      case CC.stop:
        return ButtonEvent(ButtonType.Stop, dir);
      case CC.record:
        return ButtonEvent(ButtonType.Record, dir);

      default:
        throw UnimplementedError();
    }
  }
}

enum DialType { Select, Volume, Pan, Filter, Resonance }

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

enum DialDirection { Left, Right }
enum ButtonDirection { Up, Down }

class DialEvent extends FireInputEvent {
  final DialDirection dir;
  final DialType type;

  DialEvent(this.dir, this.type);

  @override
  String toString() {
    return 'Dial: $type dir: $dir';
  }
}

class ButtonEvent extends FireInputEvent {
  final ButtonType type;
  final ButtonDirection dir;

  ButtonEvent(this.type, this.dir);

  @override
  String toString() {
    return 'Button: $type dir: $dir';
  }
}

class UnknownEvent extends FireInputEvent {}

class PadEvent extends ButtonEvent {
  static const _baseId = 54;
  static const _endId = 117;

  static const padsPerRow = 16;

  final int row;
  final int column;
  final ButtonDirection direction;

  static bool isValidPadId(int id) => (id >= _baseId) && (id <= _endId);

  PadEvent(this.row, this.column, this.direction)
      : super(ButtonType.Pad, direction);

  factory PadEvent.fromMidi(int id, ButtonDirection direction) {
    final offset = id - _baseId;

    if (offset > 63) {
      throw Exception('invalid pad id: $id');
    }
    return PadEvent(
      offset ~/ padsPerRow,
      offset % padsPerRow,
      direction,
    );
  }

  @override
  String toString() => 'PadInput $row:$column dir: $dir';
}
