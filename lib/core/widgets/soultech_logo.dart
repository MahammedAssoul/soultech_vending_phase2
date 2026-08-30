import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SoultechLogo extends StatelessWidget {
  const SoultechLogo({super.key, this.width = 150});
  final double width;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/branding/appbar_icon.svg',
        width: width,
        fit: BoxFit.contain,
      );
}
