// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
  static int _counter = 0;

  late final String _viewType;
  late final web.HTMLIFrameElement _iframe;
  StreamSubscription<web.MessageEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _viewType = 'resiflow-turnstile-${_counter++}';
    _iframe = web.HTMLIFrameElement()
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = 'transparent';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return _iframe;
    });

    _subscription = web.window.onMessage.listen((event) {
      final message = event.data?.dartify();
      if (message is! String) {
        return;
      }

      try {
        final payload = jsonDecode(message);
        if (payload is! Map<String, dynamic> ||
            payload['channel'] != 'resiflow-turnstile') {
          return;
        }

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
      } catch (_) {
        // Ignore unrelated postMessage traffic.
      }
    });

    _reloadIframe();
  }

  @override
  void didUpdateWidget(covariant TurnstileCaptchaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.siteKey != widget.siteKey ||
        oldWidget.isDarkMode != widget.isDarkMode) {
      _reloadIframe();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 88, child: HtmlElementView(viewType: _viewType));
  }

  void _reloadIframe() {
    widget.onTokenChanged(null);
    final query = Uri(
      queryParameters: <String, String>{
        'siteKey': widget.siteKey,
        'theme': widget.isDarkMode ? 'dark' : 'light',
      },
    ).query;
    _iframe.src = 'turnstile.html?$query';
  }
}
