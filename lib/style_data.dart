import 'dart:ui';

class StyleData {
  final Color mLineColor;
  final Color labelXColor;
  final Color hCrossColor;
  final Color vCrossColor;

  StyleData({Color mLineColor, Color labelXColor, Color hCrossColor, Color vCrossColor})
      : mLineColor = mLineColor ?? Color(0xff4C86CD),
        labelXColor = labelXColor ?? Color(0xff4C86CD),
        hCrossColor = hCrossColor ?? Color(0xff4C86CD),
        vCrossColor = vCrossColor ?? Color(0xff4C86CD);
}
