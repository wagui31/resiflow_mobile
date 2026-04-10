import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment {
  dev,
  prod;

  static AppEnvironment fromValue(String value) {
    return switch (value.toLowerCase()) {
      'prod' => AppEnvironment.prod,
      _ => AppEnvironment.dev,
    };
  }
}

class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  static const String _defaultLocalApiPort = '8080';
  static const String _defaultDesktopApiBaseUrl =
      'http://127.0.0.1:$_defaultLocalApiPort';
  static const String _defaultAndroidApiBaseUrl =
      'http://10.0.2.2:$_defaultLocalApiPort';

  static const String _environmentValue = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );
  static const String _apiBaseUrlValue = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  final AppEnvironment environment;
  final String apiBaseUrl;

  bool get isProduction => environment == AppEnvironment.prod;

  static AppConfig load() {
    final environment = AppEnvironment.fromValue(_environmentValue);
    final apiBaseUrl = _resolveApiBaseUrl(environment);

    return AppConfig(environment: environment, apiBaseUrl: apiBaseUrl);
  }

  static String _resolveApiBaseUrl(AppEnvironment environment) {
    final trimmedBaseUrl = _apiBaseUrlValue.trim();

    if (trimmedBaseUrl.isNotEmpty) {
      return trimmedBaseUrl.replaceFirst(RegExp(r'\/+$'), '');
    }

    if (environment == AppEnvironment.dev) {
      return _defaultDevApiBaseUrlForCurrentPlatform();
    }

    throw UnsupportedError(
      'API_BASE_URL must be provided for ${environment.name}.',
    );
  }

  static String _defaultDevApiBaseUrlForCurrentPlatform() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _defaultAndroidApiBaseUrl;
    }

    return _defaultDesktopApiBaseUrl;
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.load();
});
