import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_interceptors.dart';
import '../config/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final clientPlatform = switch (defaultTargetPlatform) {
    TargetPlatform.android => 'mobile-android',
    TargetPlatform.iOS => 'mobile-ios',
    TargetPlatform.macOS => 'desktop-macos',
    TargetPlatform.windows => 'desktop-windows',
    TargetPlatform.linux => 'desktop-linux',
    TargetPlatform.fuchsia => 'fuchsia',
  };
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: <String, Object>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Platform': kIsWeb ? 'web' : clientPlatform,
      },
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    AuthTokenInterceptor(ref),
    ApiErrorInterceptor(),
  ]);

  return dio;
});
