import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';

// Minimal widget harness — no WebView/iframe needed.
class _TestWidget extends StatefulWidget {
  const _TestWidget();

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<_TestWidget> with DriveIntentMessageHandlerMixin {
  final List<String> ackCalls = [];
  final List<WorkplaceIntent> loadCalls = [];
  final List<DrivePickOutcome> outcomes = [];
  bool throwOnAck = false;
  bool failAckAsync = false;
  bool throwOnLoad = false;
  bool failLoadAsync = false;
  bool throwOnCleanup = false;

  @override
  Future<void> sendAck() {
    if (throwOnAck) throw StateError('send ack failed');
    if (failAckAsync) return Future.error(StateError('send ack failed async'));
    ackCalls.add('ack');
    return Future.value();
  }

  @override
  Future<void> loadIntent(WorkplaceIntent intent) {
    if (throwOnLoad) throw StateError('load intent failed');
    if (failLoadAsync) return Future.error(StateError('load intent failed async'));
    loadCalls.add(intent);
    return Future.value();
  }

  @override
  void onCleanup() {
    if (throwOnCleanup) throw StateError('cleanup failed');
  }

  @override
  void onFinished(DrivePickOutcome outcome) => outcomes.add(outcome);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

const _intentId = 'test-123';
const _origin = 'https://drive.example.com';

WorkplaceIntent _intent({String intentId = _intentId, String url = '$_origin/pick'}) =>
    WorkplaceIntent(intentId: intentId, intentUrl: Uri.parse(url));

Future<_TestState> _pumpHarness(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: _TestWidget()));
  return tester.state<_TestState>(find.byType(_TestWidget));
}

Future<_TestState> _buildAndApply(WidgetTester tester, {WorkplaceIntent? intent}) async {
  final s = await _pumpHarness(tester);
  s.startLoading(() => Future.value(intent ?? _intent()));
  await tester.pump();
  s.notifyPlatformViewReady();
  return s;
}

String _encode(Map<String, dynamic> map) => jsonEncode(map);

void _handshakeMessageTests() {
  testWidgets('ready → sendAck called, no outcome yet, skeleton still shown', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);
    expect(state.ackCalls, hasLength(1));
    expect(state.outcomes, isEmpty);
    expect(state.showSkeleton, isTrue);
  });

  testWidgets('sendAck throws → Failed outcome', (tester) async {
    final state = await _buildAndApply(tester);
    state.throwOnAck = true;
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);
    await tester.pump();

    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
  });

  testWidgets('sendAck fails asynchronously → Failed outcome', (tester) async {
    final state = await _buildAndApply(tester);
    state.failAckAsync = true;
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);
    await tester.pump();

    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
  });

  testWidgets('readyToUse → hides skeleton, no ack, no outcome', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:readyToUse'}), origin: _origin);
    expect(state.ackCalls, isEmpty);
    expect(state.outcomes, isEmpty);
    expect(state.showSkeleton, isFalse);
  });
}

void _terminalMessageTests() {
  testWidgets('done → Picked outcome with documents, no ack', (tester) async {
    final state = await _buildAndApply(tester);
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
    expect(state.outcomes, hasLength(1));
    final outcome = state.outcomes.single as DrivePickOutcomePicked;
    expect(outcome.documents, hasLength(1));
    expect(outcome.documents.first.id, 'doc1');
  });

  testWidgets('error → Failed outcome with DriveIntentErrorException', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:error'}), origin: _origin);
    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
    expect((state.outcomes.single as DrivePickOutcomeFailed).error, isA<DriveIntentErrorException>());
    expect(state.ackCalls, isEmpty);
  });

  testWidgets('cancel → Cancelled outcome', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:cancel'}), origin: _origin);
    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeCancelled>());
    expect(state.ackCalls, isEmpty);
  });
}

void _invalidMessageTests() {
  testWidgets('malformed JSON → no crash, nothing dispatched', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: '{not valid json{{', origin: _origin);
    expect(state.ackCalls, isEmpty);
    expect(state.outcomes, isEmpty);
    state.cancelReadyTimeoutForTesting();
  });

  testWidgets('valid JSON array (not object) → no crash, nothing dispatched', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: '[]', origin: _origin);
    expect(state.ackCalls, isEmpty);
    expect(state.outcomes, isEmpty);
    state.cancelReadyTimeoutForTesting();
  });

  testWidgets('unknown type → no crash, nothing dispatched', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:unknown-op'}), origin: _origin);
    expect(state.ackCalls, isEmpty);
    expect(state.outcomes, isEmpty);
    state.cancelReadyTimeoutForTesting();
  });
}

void _originFilterTests() {
  testWidgets('wrong origin → nothing dispatched', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: 'https://evil.example.com');
    expect(state.ackCalls, isEmpty);
    expect(state.outcomes, isEmpty);
    state.cancelReadyTimeoutForTesting();
  });

  testWidgets('null origin → nothing dispatched', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: null);
    expect(state.ackCalls, isEmpty);
    expect(state.outcomes, isEmpty);
    state.cancelReadyTimeoutForTesting();
  });

  testWidgets('data: URI origin accepts * from mobile shim', (tester) async {
    final state = await _buildAndApply(tester, intent: _intent(url: 'data:text/html,hi'));
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: '*');
    expect(state.ackCalls, hasLength(1));
  });
}

void _applyOrderingTests() {
  testWidgets('platform view ready before intent resolves — still applies once both are ready', (tester) async {
    final state = await _pumpHarness(tester);
    state.notifyPlatformViewReady();
    expect(state.loadCalls, isEmpty);

    final completer = Completer<WorkplaceIntent>();
    state.startLoading(() => completer.future);
    completer.complete(_intent());
    await tester.pump();

    expect(state.loadCalls, hasLength(1));
    state.cancelReadyTimeoutForTesting();
  });

  testWidgets('intent resolves before platform view ready — applies once view is ready', (tester) async {
    final state = await _pumpHarness(tester);
    state.startLoading(() => Future.value(_intent()));
    await tester.pump();
    expect(state.loadCalls, isEmpty);

    state.notifyPlatformViewReady();
    expect(state.loadCalls, hasLength(1));
    state.cancelReadyTimeoutForTesting();
  });

  testWidgets('message arriving before the intent is applied → dropped', (tester) async {
    final state = await _pumpHarness(tester);
    state.startLoading(() => Future.value(_intent()));
    // Platform view never becomes ready — still in the waiting phase.
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);
    await tester.pump();

    expect(state.ackCalls, isEmpty);
    expect(state.outcomes, isEmpty);
    state.cancelReadyTimeoutForTesting();
  });
}

void _intentLoadFailureTests() {
  testWidgets('intent fetch fails → Failed outcome, no load attempted', (tester) async {
    final state = await _pumpHarness(tester);
    state.startLoading(() => Future.error(StateError('token exchange failed')));
    await tester.pump();

    expect(state.loadCalls, isEmpty);
    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
  });

  testWidgets('intent loader throws synchronously → Failed outcome, no load attempted', (tester) async {
    final state = await _pumpHarness(tester);
    state.startLoading(() => throw StateError('token exchange failed'));
    await tester.pump();

    expect(state.loadCalls, isEmpty);
    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
  });

  testWidgets('loading the intent throws → Failed outcome', (tester) async {
    final state = await _pumpHarness(tester);
    state.throwOnLoad = true;
    state.startLoading(() => Future.value(_intent()));
    await tester.pump();
    state.notifyPlatformViewReady();
    await tester.pump();

    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
  });

  testWidgets('loading the intent fails asynchronously → Failed outcome', (tester) async {
    final state = await _pumpHarness(tester);
    state.failLoadAsync = true;
    state.startLoading(() => Future.value(_intent()));
    await tester.pump();
    state.notifyPlatformViewReady();
    await tester.pump();

    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
  });
}

void _pageLoadFailureTests() {
  testWidgets('notifyPageLoadFailed → Failed outcome without waiting for timeout', (tester) async {
    final state = await _buildAndApply(tester);
    state.notifyPageLoadFailed(DriveIntentPageLoadException('net::ERR_NAME_NOT_RESOLVED'));

    expect(state.outcomes, hasLength(1));
    final outcome = state.outcomes.single as DrivePickOutcomeFailed;
    expect(outcome.error, isA<DriveIntentPageLoadException>());
  });

  testWidgets('page load failure before intent applied → ignored, modal stays', (tester) async {
    final state = await _pumpHarness(tester);
    state.startLoading(() => Future.value(_intent()));
    // Platform view never becomes ready — still in the waiting phase; a
    // WebView error here cannot be the Drive page (nothing was loaded yet).
    state.notifyPageLoadFailed(DriveIntentPageLoadException('spurious init error'));

    expect(state.outcomes, isEmpty);
    expect(state.showSkeleton, isTrue);
    state.cancelReadyTimeoutForTesting();
  });

  testWidgets('page load failure after interactive → ignored, picker keeps working', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:readyToUse'}), origin: _origin);
    state.notifyPageLoadFailed(DriveIntentPageLoadException('in-page navigation error'));

    expect(state.outcomes, isEmpty);
    expect(state.showSkeleton, isFalse);
  });

  testWidgets('notifyPageLoadFailed after finish → no second outcome', (tester) async {
    final state = await _buildAndApply(tester);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:cancel'}), origin: _origin);
    state.notifyPageLoadFailed(DriveIntentPageLoadException('HTTP 500'));

    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeCancelled>());
  });
}

Future<_TestState> _pumpOnPushedRoute(
  WidgetTester tester, {
  void Function(DrivePickOutcome?)? onResult,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.of(context)
            .push<DrivePickOutcome>(
              MaterialPageRoute(builder: (_) => const _TestWidget()),
            )
            .then((result) => onResult?.call(result)),
        child: const Text('open'),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return tester.state<_TestState>(find.byType(_TestWidget));
}

void _finishContractTests() {
  testWidgets('onCleanup throws → swallowed, onFinished still runs, route still pops', (tester) async {
    final state = await _pumpOnPushedRoute(tester);
    state.throwOnCleanup = true;

    state.cancel();
    await tester.pumpAndSettle();

    expect(state.outcomes.single, isA<DrivePickOutcomeCancelled>());
    expect(find.byType(_TestWidget), findsNothing);
  });

  testWidgets('finish pops the route with the outcome as dialog result', (tester) async {
    DrivePickOutcome? result;
    final state = await _pumpOnPushedRoute(tester, onResult: (r) => result = r);

    state.cancel();
    await tester.pumpAndSettle();

    expect(result, const DrivePickOutcomeCancelled());
  });
}

void _disposeRaceSafetyTests() {
  testWidgets('intent resolves after dispose → no load, no outcome, no crash', (tester) async {
    final state = await _pumpHarness(tester);
    final completer = Completer<WorkplaceIntent>();
    state.startLoading(() => completer.future);
    state.notifyPlatformViewReady();
    await tester.pumpWidget(const SizedBox.shrink());

    completer.complete(_intent());
    await tester.pump();

    expect(state.loadCalls, isEmpty);
    expect(state.outcomes, isEmpty);
  });

  testWidgets('intent fails after dispose → Failed outcome, no setState/pop crash', (tester) async {
    final state = await _pumpHarness(tester);
    final completer = Completer<WorkplaceIntent>();
    state.startLoading(() => completer.future);
    await tester.pumpWidget(const SizedBox.shrink());

    completer.completeError(StateError('token exchange failed'));
    await tester.pump();

    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
  });

  testWidgets('cancel while loader pending → later failure adds no second outcome', (tester) async {
    final state = await _pumpHarness(tester);
    final completer = Completer<WorkplaceIntent>();
    state.startLoading(() => completer.future);
    state.notifyPlatformViewReady();
    state.cancel();

    completer.completeError(StateError('token exchange failed'));
    await tester.pump();

    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeCancelled>());
  });
}

class _TimeoutTestWidget extends StatefulWidget {
  const _TimeoutTestWidget();

  @override
  _TimeoutTestState createState() => _TimeoutTestState();
}

class _TimeoutTestState extends State<_TimeoutTestWidget>
    with DriveIntentMessageHandlerMixin {
  final List<DrivePickOutcome> outcomes = [];

  @override
  Duration get readyTimeout => const Duration(milliseconds: 50);

  @override
  Future<void> sendAck() => Future.value();

  @override
  Future<void> loadIntent(WorkplaceIntent intent) => Future.value();

  @override
  void onFinished(DrivePickOutcome outcome) => outcomes.add(outcome);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void _readyTimeoutTests() {
  testWidgets('fires Failed(DriveIntentTimeoutException) if ready never arrives', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _TimeoutTestWidget()));
    final state = tester.state<_TimeoutTestState>(find.byType(_TimeoutTestWidget));
    state.startLoading(() => Future.value(_intent()));
    await tester.pump();
    state.notifyPlatformViewReady();

    await tester.pump(const Duration(milliseconds: 60));

    expect(state.outcomes, hasLength(1));
    expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
    expect((state.outcomes.single as DrivePickOutcomeFailed).error, isA<DriveIntentTimeoutException>());
  });

  testWidgets('cancelled if readyToUse arrives before timeout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _TimeoutTestWidget()));
    final state = tester.state<_TimeoutTestState>(find.byType(_TimeoutTestWidget));
    state.startLoading(() => Future.value(_intent()));
    await tester.pump();
    state.notifyPlatformViewReady();
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:readyToUse'}), origin: _origin);

    await tester.pump(const Duration(milliseconds: 60));

    expect(state.outcomes, isEmpty);
  });

  testWidgets('fires Failed(DriveIntentTimeoutException) if readyToUse never arrives, even after ready', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _TimeoutTestWidget()));
    final state = tester.state<_TimeoutTestState>(find.byType(_TimeoutTestWidget));
    state.startLoading(() => Future.value(_intent()));
    await tester.pump();
    state.notifyPlatformViewReady();
    state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);

    await tester.pump(const Duration(milliseconds: 60));

    expect(state.outcomes, hasLength(1));
    expect((state.outcomes.single as DrivePickOutcomeFailed).error, isA<DriveIntentTimeoutException>());
  });

  testWidgets('fires Failed(DriveIntentTimeoutException) if platform view never becomes ready', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _TimeoutTestWidget()));
    final state = tester.state<_TimeoutTestState>(find.byType(_TimeoutTestWidget));
    state.startLoading(() => Future.value(_intent()));

    await tester.pump(const Duration(milliseconds: 60));

    expect(state.outcomes, hasLength(1));
    expect((state.outcomes.single as DrivePickOutcomeFailed).error, isA<DriveIntentTimeoutException>());
  });
}

void main() {
  group('DriveIntentMessageHandlerMixin', () {
    group('handshake messages', _handshakeMessageTests);
    group('terminal messages', _terminalMessageTests);
    group('invalid messages', _invalidMessageTests);
    group('origin filtering', _originFilterTests);
    group('apply ordering (intent resolution vs platform view ready)', _applyOrderingTests);
    group('intent load failures', _intentLoadFailureTests);
    group('page load failure', _pageLoadFailureTests);
    group('ready timeout wiring', _readyTimeoutTests);
    group('finish contract', _finishContractTests);
    group('dispose race safety', _disposeRaceSafetyTests);

    group('multi-state isolation', () {
      testWidgets('two states with different intentIds — only matching state handles done', (tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: Column(children: [_TestWidget(), _TestWidget()]),
        ));
        final states = tester.stateList<_TestState>(find.byType(_TestWidget)).toList();
        final stateA = states[0];
        final stateB = states[1];

        stateA.startLoading(() => Future.value(_intent(intentId: 'intent-a')));
        stateB.startLoading(() => Future.value(_intent(intentId: 'intent-b')));
        await tester.pump();
        stateA.notifyPlatformViewReady();
        stateB.notifyPlatformViewReady();

        final doneForA = _encode({
          'type': 'intent-intent-a:done',
          'document': [
            {'id': 'doc1', 'name': 'file.pdf', 'size': 100, 'mimeType': 'application/pdf'},
          ],
        });

        stateA.onMessage(raw: doneForA, origin: _origin);
        stateB.onMessage(raw: doneForA, origin: _origin);

        expect(stateA.outcomes, hasLength(1));
        expect(stateB.outcomes, isEmpty);
        stateB.cancelReadyTimeoutForTesting();
      });

      testWidgets('two ready messages → sendAck called twice, no dedup', (tester) async {
        final state = await _buildAndApply(tester);
        state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);
        state.onMessage(raw: _encode({'type': 'intent-$_intentId:ready'}), origin: _origin);
        expect(state.ackCalls, hasLength(2));
        expect(state.outcomes, isEmpty);
        state.cancelReadyTimeoutForTesting();
      });

      testWidgets('message after outcome finalized → no second outcome, no crash', (tester) async {
        final state = await _buildAndApply(tester);
        state.onMessage(raw: _encode({'type': 'intent-$_intentId:error'}), origin: _origin);
        expect(state.outcomes, hasLength(1));

        state.onMessage(
          raw: _encode({
            'type': 'intent-$_intentId:done',
            'document': [
              {'id': 'd1', 'name': 'f.pdf', 'size': 100, 'mimeType': 'application/pdf'},
            ],
          }),
          origin: _origin,
        );
        expect(state.outcomes, hasLength(1));
      });
    });
  });
}
