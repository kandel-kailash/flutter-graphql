import 'package:flutter/widgets.dart';

enum ScreenWidth {
  phone._(minWidth: 0, maxWidth: 600),
  tablet._(minWidth: 601, maxWidth: 1200),
  desktop._(minWidth: 1201, maxWidth: double.infinity);

  const ScreenWidth._({
    required this.minWidth,
    required this.maxWidth,
  });

  factory ScreenWidth.fromMaxWidth(double logicalWidth) => values.firstWhere(
        (config) =>
            config.minWidth <= logicalWidth && logicalWidth <= config.maxWidth,
      );

  factory ScreenWidth.from(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return values.firstWhere(
      (config) => config.minWidth <= width && width <= config.maxWidth,
    );
  }

  final double minWidth;
  final double maxWidth;
}
