@TestOn('chrome')

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_html/html.dart' as html;
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';

class _MessageListenerWidget extends StatefulWidget {
  final void Function(String data, String? origin) onMessage;

  const _MessageListenerWidget({required this.onMessage});

  @override
  State<_MessageListenerWidget> createState() => _MessageListenerWidgetState();
}

class _MessageListenerWidgetState extends State<_MessageListenerWidget>
    with WebWindowMessageMixin<_MessageListenerWidget> {
  @override
  void initState() {
    super.initState();
    startWindowMessageListener(widget.onMessage);
  }

  @override
  void dispose() {
    stopWindowMessageListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  testWidgets('forwards browser MessageEvents', (tester) async {
    String? data;
    String? origin;
    await tester.pumpWidget(MaterialApp(
      home: _MessageListenerWidget(
        onMessage: (message, messageOrigin) {
          data = message;
          origin = messageOrigin;
        },
      ),
    ));

    html.window.dispatchEvent(
      html.MessageEvent(
        'message',
        data: jsonEncode({'type': 'intent-test:readyToUse'}),
        origin: Uri.base.origin,
      ),
    );
    await tester.pump();

    expect(data, jsonEncode({'type': 'intent-test:readyToUse'}));
    expect(origin, Uri.base.origin);
  });

  testWidgets('stops forwarding messages after disposal', (tester) async {
    var callCount = 0;
    await tester.pumpWidget(MaterialApp(
      home: _MessageListenerWidget(
        onMessage: (_, __) => callCount++,
      ),
    ));

    await tester.pumpWidget(const SizedBox());
    html.window.dispatchEvent(
      html.MessageEvent(
        'message',
        data: jsonEncode({'type': 'intent-test:readyToUse'}),
        origin: Uri.base.origin,
      ),
    );
    await tester.pump();

    expect(callCount, 0);
  });
}
