import 'package:flutter/material.dart';

class Responsive {
  Responsive(this.context);

  final BuildContext context;

  Size get _size => MediaQuery.sizeOf(context);

  double w(double value) => _size.width * (value / 375);
  double h(double value) => _size.height * (value / 812);

  double r(double value) {
    final scale = _size.width / 375;
    return value * scale;
  }

  double sp(double value) {
    final scale = _size.width / 375;
    return value * scale;
  }

  bool get isSmall => _size.width < 360;
  bool get isTablet => _size.width >= 600;
}

extension ResponsiveX on BuildContext {
  Responsive get responsive => Responsive(this);
}
