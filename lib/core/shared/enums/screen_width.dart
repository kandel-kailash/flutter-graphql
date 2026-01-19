import 'package:flutter/widgets.dart';

enum ScreenWidth {
  phone._(minWidth: 0, maxWidth: 600),
  tablet._(minWidth: 601, maxWidth: 1280),
  desktop._(minWidth: 1281, maxWidth: double.infinity);

  const ScreenWidth._({required this.minWidth, required this.maxWidth});

  factory ScreenWidth.fromLogicalWidth(double logicalWidth) =>
      values.firstWhere(
        (config) =>
            config.minWidth <= logicalWidth && logicalWidth <= config.maxWidth,
      );

  factory ScreenWidth.from(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);

    final double logicalWidth =
        mediaQueryData.size.width / mediaQueryData.devicePixelRatio;

    return ScreenWidth.fromLogicalWidth(logicalWidth);
  }

  final double minWidth;
  final double maxWidth;
}
