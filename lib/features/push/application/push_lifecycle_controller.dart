import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/firebase_push_options.dart';
import '../../../core/push/push_installation_storage.dart';
import '../../../core/router/app_router.dart';
import '../../auth/domain/auth_models.dart';
import '../../notifications/application/notification_navigation.dart';
import '../../notifications/application/notification_providers.dart';
import '../../notifications/domain/notification_models.dart';
import '../data/push_repository.dart';

final pushLifecycleControllerProvider = Provider<PushLifecycleController>((ref) {
  final controller = PushLifecycleController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebasePushOptions.initializeAppForCurrentPlatform();
}

class PushLifecycleController {
  PushLifecycleController(this._ref);

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'resiflow_notifications',
    'ResiFlow Notifications',
    description: 'Residence notifications',
    importance: Importance.high,
  );

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;

  FirebaseMessaging? _messaging;
  UserProfile? _currentUser;
  String? _lastRegisteredToken;
  int? _lastRegisteredUserId;
  Map<String, String>? _pendingNavigationData;
  bool _initialized = false;
  bool _firebaseReady = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (!_supportsPush) {
      return;
    }

    final app = await FirebasePushOptions.initializeAppForCurrentPlatform();
    if (app == null) {
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _messaging = FirebaseMessaging.instance;
    await _configureForegroundPresentation();
    await _initializeLocalNotifications();
    _listenToForegroundEvents();
    await _captureInitialMessage();
    _firebaseReady = true;
  }

  Future<void> syncAuthenticatedSession(UserProfile user) async {
    _currentUser = user;
    await initialize();
    if (!_firebaseReady || !_supportsPush) {
      return;
    }

    final messaging = _messaging;
    if (messaging == null) {
      return;
    }

    final permission = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final status = permission.authorizationStatus;
    if (status == AuthorizationStatus.denied ||
        status == AuthorizationStatus.notDetermined) {
      return;
    }

    final token = await messaging.getToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    await _registerTokenForUser(user, token.trim());
    _flushPendingNavigation();
  }

  Future<void> logoutCurrentDevice() async {
    _currentUser = null;
    _lastRegisteredToken = null;
    _lastRegisteredUserId = null;

    await initialize();
    if (!_firebaseReady || !_supportsPush) {
      return;
    }

    final installationId = await _ref
        .read(pushInstallationStorageProvider)
        .readOrCreateInstallationId();
    final token = await _messaging?.getToken();

    try {
      await _ref.read(pushRepositoryProvider).logoutCurrentDevice(
            token: token,
            installationId: installationId,
          );
    } catch (_) {
      // Logout must never block clearing the local session.
    }
  }

  void dispose() {
    unawaited(_tokenRefreshSubscription?.cancel());
    unawaited(_foregroundMessageSubscription?.cancel());
    unawaited(_messageOpenedAppSubscription?.cancel());
  }

  Future<void> _registerTokenForUser(UserProfile user, String token) async {
    if (_lastRegisteredUserId == user.id && _lastRegisteredToken == token) {
      return;
    }

    final installationId = await _ref
        .read(pushInstallationStorageProvider)
        .readOrCreateInstallationId();

    await _ref.read(pushRepositoryProvider).upsertToken(
          token: token,
          platform: defaultTargetPlatform == TargetPlatform.iOS
              ? 'IOS'
              : 'ANDROID',
          installationId: installationId,
          deviceName: defaultTargetPlatform.name,
          appVersion: null,
        );

    _lastRegisteredUserId = user.id;
    _lastRegisteredToken = token;
  }

  Future<void> _configureForegroundPresentation() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          return;
        }
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            _handleNotificationNavigation(
              decoded.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              ),
            );
          }
        } catch (_) {
          // Ignore malformed payloads.
        }
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  void _listenToForegroundEvents() {
    _tokenRefreshSubscription ??=
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          final user = _currentUser;
          if (user == null) {
            return;
          }
          unawaited(_registerTokenForUser(user, token));
        });

    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((
      message,
    ) {
      _invalidateNotifications();
      final notification = message.notification;
      if (notification == null ||
          defaultTargetPlatform != TargetPlatform.android) {
        return;
      }

      final payload = jsonEncode(message.data);
      unawaited(
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'resiflow_notifications',
              'ResiFlow Notifications',
              channelDescription: 'Residence notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: payload,
        ),
      );
    });

    _messageOpenedAppSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          _handleNotificationNavigation(message.data);
        });
  }

  Future<void> _captureInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final normalized = data.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    _invalidateNotifications();
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _pendingNavigationData = normalized;
      return;
    }

    final type = AppNotificationType.fromApi(normalized['type']);
    openNotificationTarget(context, ProviderScope.containerOf(context), type);
    _pendingNavigationData = null;
  }

  void _flushPendingNavigation() {
    final pending = _pendingNavigationData;
    if (pending == null) {
      return;
    }
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }
    final type = AppNotificationType.fromApi(pending['type']);
    openNotificationTarget(context, ProviderScope.containerOf(context), type);
    _pendingNavigationData = null;
  }

  void _invalidateNotifications() {
    _ref.invalidate(notificationsCenterControllerProvider);
    _ref.invalidate(unreadNotificationsCountProvider);
    _ref.invalidate(usersNotificationCountProvider);
    _ref.invalidate(paymentNotificationCountProvider);
    _ref.invalidate(expenseNotificationCountProvider);
    _ref.invalidate(voteNotificationCountProvider);
  }

  bool get _supportsPush {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
