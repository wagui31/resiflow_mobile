import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    required this.logoAssetPath,
    super.key,
    this.size = 56,
  });

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
