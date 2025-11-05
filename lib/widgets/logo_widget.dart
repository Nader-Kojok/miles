import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool iconOnly;
  
  const LogoWidget({
    super.key,
    this.size = 60,
    this.iconOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconOnly 
        ? 'assets/icon_only_logo_miles.svg'
        : 'assets/logo_miles.svg',
      height: size,
      width: iconOnly ? size : null,
      fit: BoxFit.contain,
    );
  }
}
