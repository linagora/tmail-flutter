import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/presentation/mixin/drive_intent_message_handler_mixin.dart';

// Minimal widget harness — no WebView needed.
class _TestWidget extends StatefulWidget {
  const _TestWidget();

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<_TestWidget> with DriveIntentMessageHandlerMixin {
  final List<String> ackCalls = [];
  final List<List<DriveDocument>?> closeCalls = [];

  @override
  void sendAck() => ackCalls.add('ack');

  // Override to capture close calls without needing a Navigator.
  @override
  void closeModal(List<DriveDocument>? result) => closeCalls.add(result);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

const _intentId = 'test-123';
const _origin = 'https://drive.example.com';

Future<_TestState> _buildAndInit(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: _TestWidget()));
  final s = tester.state<_TestState>(find.byType(_TestWidget));
  s.initMessageHandler(intentId: _intentId, intentOrigin: _origin);
  return s;
}

String _encode(Map<String, dynamic> map) => jsonEncode(map);

void _messageTypeTests() {
  testWidgets('ready → sendAck called, modal stays open', (tester) async {
    final state = await _buildAndInit(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);
    expect(state.ackCalls, hasLength(1));
    expect(state.closeCalls, isEmpty);
  });

  testWidgets('done → closeModal with documents, no ack', (tester) async {
    final state = await _buildAndInit(tester);
    state.onMessage(
      raw: _encode({
        'type': 'intent-$_intentId:done',
        'document': [
          {'id': 'doc1', 'name': 'file.pdf', 'size': 512, 'mimeType': 'application/pdf', 'downloadLink': 'https://example.com/file.pdf'},
        ],
      }),
      origin: _origin,
    );
    expect(state.ackCalls, isEmpty);
    expect(state.closeCalls, hasLength(1));
    expect(state.closeCalls.first, isNotNull);
    expect(state.closeCalls.first!.length, 1);
    expect(state.closeCalls.first!.first.id, 'doc1');
  });

  testWidgets('error → closeModal(null)', (tester) async {
    final state = await _buildAndInit(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:error'}), origin: _origin);
    expect(state.closeCalls, hasLength(1));
    expect(state.closeCalls.first, isNull);
    expect(state.ackCalls, isEmpty);
  });

  testWidgets('cancel → closeModal(null)', (tester) async {
    final state = await _buildAndInit(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:cancel'}), origin: _origin);
    expect(state.closeCalls, hasLength(1));
    expect(state.closeCalls.first, isNull);
    expect(state.ackCalls, isEmpty);
  });

  testWidgets('malformed JSON → no crash, nothing dispatched', (tester) async {
    final state = await _buildAndInit(tester);
    state.onMessage(raw: '{not valid json{{', origin: _origin);
    expect(state.ackCalls, isEmpty);
    expect(state.closeCalls, isEmpty);
  });

  testWidgets('unknown type → no crash, nothing dispatched', (tester) async {
    final state = await _buildAndInit(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:unknown-op'}), origin: _origin);
    expect(state.ackCalls, isEmpty);
    expect(state.closeCalls, isEmpty);
  });
}

void _originFilterTests() {
  testWidgets('wrong origin → nothing dispatched', (tester) async {
    final state = await _buildAndInit(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: 'https://evil.example.com');
    expect(state.ackCalls, isEmpty);
    expect(state.closeCalls, isEmpty);
  });

  testWidgets('null origin → nothing dispatched', (tester) async {
    final state = await _buildAndInit(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: null);
    expect(state.ackCalls, isEmpty);
    expect(state.closeCalls, isEmpty);
  });

  testWidgets('data: URI origin accepts * from mobile shim', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _TestWidget()));
    final state = tester.state<_TestState>(find.byType(_TestWidget));
    state.initMessageHandler(intentId: _intentId, intentOrigin: 'null');
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: '*');
    expect(state.ackCalls, hasLength(1));
  });
}

void main() {
  group('DriveIntentMessageHandlerMixin', () {
    group('message types', _messageTypeTests);
    group('origin filtering', _originFilterTests);
  });
}
