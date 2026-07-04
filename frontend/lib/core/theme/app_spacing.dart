import 'package:flutter/material.dart';

/// Espacements et rayons BabiCash — échelle de 4px.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  // Padding internes courants
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets listTilePadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: xxl, vertical: md);

  // Hauteurs tactiles minimales (accessibilité)
  static const double minTapTarget = 48;
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 64;

  // Rayons
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 999;

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));
}

/// SizedBox helpers de commodité
class VGap extends StatelessWidget {
  const VGap(this.height, {super.key});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class HGap extends StatelessWidget {
  const HGap(this.width, {super.key});
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}
