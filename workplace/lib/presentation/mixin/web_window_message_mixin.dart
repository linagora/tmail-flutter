import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

typedef OnWebWindowListener = void Function(html.Event);

/// Mixin for [State] subclasses that need to listen to `window.onmessage`
/// events. Guards for [html.MessageEvent] and String data before forwarding.
mixin WebWindowMessageMixin<T extends StatefulWidget> on State<T> {
  OnWebWindowListener? _windowListener;

  void startWindowMessageListener(
    void Function(String data, String? origin) onMessage,
  ) {
    _windowListener = (html.Event event) {
      if (event is! html.MessageEvent) return;
      final data = event.data;
      if (data is! String) return;
      onMessage(data, event.origin);
    };
    html.window.addEventListener('message', _windowListener!);
  }

  void stopWindowMessageListener() {
    if (_windowListener != null) {
      html.window.removeEventListener('message', _windowListener!);
      _windowListener = null;
    }
  }
}
