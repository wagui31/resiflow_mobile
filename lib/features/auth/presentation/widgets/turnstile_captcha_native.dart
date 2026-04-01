import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TurnstileCaptchaView extends StatefulWidget {
  const TurnstileCaptchaView({
    required this.siteKey,
    required this.isDarkMode,
    required this.onTokenChanged,
    super.key,
  });

  final String siteKey;
  final bool isDarkMode;
  final ValueChanged<String?> onTokenChanged;

  @override
  State<TurnstileCaptchaView> createState() => _TurnstileCaptchaViewState();
}

class _TurnstileCaptchaViewState extends State<TurnstileCaptchaView> {
  late final WebViewController _controller;
  var _pageLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _pageLoaded = true;
            _syncCaptchaConfiguration();
          },
        ),
      )
      ..addJavaScriptChannel(
        'TurnstileBridge',
        onMessageReceived: (message) {
          if (!mounted) {
            return;
          }
          final payload = _decodePayload(message.message);
          switch (payload['type']) {
            case 'token':
              widget.onTokenChanged(payload['payload'] as String?);
              break;
            case 'expired':
            case 'error':
              widget.onTokenChanged(null);
              break;
            default:
              break;
          }
        },
      );
    _loadCaptcha();
  }

  @override
  void didUpdateWidget(covariant TurnstileCaptchaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.siteKey != widget.siteKey ||
        oldWidget.isDarkMode != widget.isDarkMode) {
      _loadCaptcha();
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android &&
        platform != TargetPlatform.iOS &&
        platform != TargetPlatform.macOS) {
      return const _UnsupportedTurnstileView();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 88,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  void _loadCaptcha() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onTokenChanged(null);
    });
    _pageLoaded = false;
    _controller.loadFlutterAsset('assets/html/turnstile.html');
  }

  Future<void> _syncCaptchaConfiguration() async {
    if (!_pageLoaded || !mounted) {
      return;
    }

    final payload = jsonEncode(<String, String>{
      'siteKey': widget.siteKey,
      'theme': widget.isDarkMode ? 'dark' : 'light',
    });

    await _controller.runJavaScript('''
      window.resiflowTurnstileConfig = $payload;
      if (typeof window.renderTurnstile === 'function') {
        window.renderTurnstile();
      }
    ''');
  }

  Map<String, dynamic> _decodePayload(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore malformed bridge payloads.
    }
    return const <String, dynamic>{};
  }
}

class _UnsupportedTurnstileView extends StatelessWidget {
  const _UnsupportedTurnstileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 88,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        'Turnstile is available on web, Android, iOS, and macOS builds.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
