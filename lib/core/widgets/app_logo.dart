import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({required this.logoAssetPath, super.key, this.size = 56});

  final String? logoAssetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (logoAssetPath == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.apartment_rounded,
          size: size * 0.55,
          color: colorScheme.onPrimaryContainer,
        ),
      );
    }

    if (logoAssetPath!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        logoAssetPath!,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        logoAssetPath!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
