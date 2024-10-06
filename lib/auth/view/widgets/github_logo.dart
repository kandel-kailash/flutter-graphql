import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GithubLogo extends StatelessWidget {
  const GithubLogo({
    super.key,
    required this.size,
    this.colorFilter = const ColorFilter.mode(
      Colors.white,
      BlendMode.srcIn,
    ),
  });

  final ColorFilter colorFilter;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svgs/github-logo.svg',
      colorFilter: colorFilter,
      height: size.height,
      width: size.width,
    );
  }
}
