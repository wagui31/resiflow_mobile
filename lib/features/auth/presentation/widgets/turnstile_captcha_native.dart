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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'TurnstileBridge',
        onMessageReceived: (message) {
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
    widget.onTokenChanged(null);
    _controller.loadHtmlString(_buildHtml());
  }

  String _buildHtml() {
    final siteKey = jsonEncode(widget.siteKey);
    final theme = jsonEncode(widget.isDarkMode ? 'dark' : 'light');

    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
    <style>
      html, body {
        margin: 0;
        padding: 0;
        background: transparent;
        overflow: hidden;
      }
      body {
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 88px;
      }
      #captcha {
        width: 100%;
      }
    </style>
  </head>
  <body>
    <div id="captcha"></div>
    <script>
      function post(type, payload) {
        TurnstileBridge.postMessage(JSON.stringify({
          channel: 'resiflow-turnstile',
          type: type,
          payload: payload || null
        }));
      }

      function renderWidget() {
        if (!window.turnstile) {
          window.setTimeout(renderWidget, 120);
          return;
        }

        window.turnstile.render('#captcha', {
          sitekey: $siteKey,
          theme: $theme,
          size: 'flexible',
          callback: function(token) {
            post('token', token);
          },
          'expired-callback': function() {
            post('expired', null);
          },
          'error-callback': function() {
            post('error', null);
          }
        });
      }

      window.onload = renderWidget;
    </script>
  </body>
</html>
''';
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
