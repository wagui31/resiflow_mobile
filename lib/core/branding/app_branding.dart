import '../assets/app_assets.dart';

class AppBranding {
  const AppBranding({
    required this.logoAssetPath,
  });

  final String? logoAssetPath;

  static const AppBranding current = AppBranding(
    logoAssetPath: AppAssets.appLogoDefault,
  );
}
