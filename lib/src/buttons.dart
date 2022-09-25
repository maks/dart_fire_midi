import 'dart:typed_data';

import 'cc_inputs.dart';

enum ButtonCode {
  browser(CC.browser),
  patternUp(CC.patternUp),
  patternDown(CC.patternDown),
  gridLeft(CC.gridLeft),
  gridRight(CC.gridRight),
  step(CC.step),
  note(CC.note),
  drum(CC.drum),
  perform(CC.perform),
  shift(CC.shift),
  alt(CC.alt),
  pattern(CC.pattern),
  soloMute1(CC.muteButton1),
  soloMute2(CC.muteButton2),
  soloMute3(CC.muteButton3),
  soloMute4(CC.muteButton4),
  play(CC.play),
  stop(CC.stop),
  record(CC.record);

  const ButtonCode(this.code);
  final int code;
}

enum ButtonLedColor { off, color1, color2, color3, color4 }

class ButtonControls {
  static Uint8List buttonOn(ButtonCode button, int ledColour) {
    return CC.on(button.code, ledColour);
  }

  static Uint8List buttonOff(ButtonCode button) {
    return CC.on(button.code, 0);
  }
}
