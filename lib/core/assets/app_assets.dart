import 'package:flutter/material.dart';

class AppAssets {
  const AppAssets._();

  static const String images = 'assets/images';
  static const String logos = '$images/logos';

  static const String landingImageLight = '$images/image_copro_ligth.png';
  static const String landingImageDark = '$images/image_copro_dark.png';
  static const String appLogoLight = '$logos/logo_ligth.svg';
  static const String appLogoDark = '$logos/logo_dark.svg';
  static const String appLogoDefault = appLogoLight;

  static String landingImage(Brightness brightness) {
    return brightness == Brightness.dark ? landingImageDark : landingImageLight;
  }

  static String appLogo(Brightness brightness) {
    return brightness == Brightness.dark ? appLogoDark : appLogoLight;
  }
}
