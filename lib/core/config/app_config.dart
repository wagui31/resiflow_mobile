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
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
  });

  static const String _environmentValue =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const String _apiBaseUrlValue =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  final AppEnvironment environment;
  final String apiBaseUrl;

  bool get isProduction => environment == AppEnvironment.prod;

  static AppConfig load() {
    final environment = AppEnvironment.fromValue(_environmentValue);
    final apiBaseUrl = _resolveApiBaseUrl(environment);

    return AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
    );
  }

  static String _resolveApiBaseUrl(AppEnvironment environment) {
    final trimmedBaseUrl = _apiBaseUrlValue.trim();

    if (trimmedBaseUrl.isNotEmpty) {
      return trimmedBaseUrl;
    }

    return switch (environment) {
      AppEnvironment.dev => 'http://10.0.2.2:8080',
      AppEnvironment.prod => throw UnsupportedError(
        'API_BASE_URL must be provided when APP_ENV=prod.',
      ),
    };
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.load();
});
