import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_html/html.dart' as html;
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';
import 'package:workplace/presentation/model/drive_origin_validator.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';
import 'package:workplace/presentation/model/drive_picker_session.dart';

// Exercises the real `window.postMessage` transport (other tests call
// onMessage directly). Contract: the modal owns its listener for its own
// lifetime and must not depend on the opener's — the context-menu tile pops
// its route on tap and disposes before the handshake arrives.
//
// universal_html gives the VM an in-memory DOM, so dispatchEvent reaches
// addEventListener under `flutter test`. The real web modal can't be pumped
// (HtmlIframeWidget needs a browser), so these harnesses mirror its wiring.

const _origin = 'https://drive.example.com';
const _intentId = 'intent-1';

WorkplaceIntent _intent() => WorkplaceIntent(
      intentId: _intentId,
      intentUrl: Uri.parse('$_origin/pick'),
      client: _origin,
    );

Future<WorkplaceIntent> _fetchIntentStub({
  required WorkplaceFilePickerConfigRequest filePickerConfig,
}) async =>
    _intent();

/// Mimics the Drive iframe calling `parent.postMessage(...)`.
void _driveIframePosts(String type, {String origin = _origin}) {
  html.window.dispatchEvent(html.MessageEvent(
    'message',
    data: jsonEncode({'type': 'intent-$_intentId:$type'}),
    origin: origin,
  ));
}

Widget _app(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

// ---------------------------------------------------------------------------
// Group A — WebWindowMessageMixin: the start/stop primitive.
// ---------------------------------------------------------------------------

class _ListenerProbe extends StatefulWidget {
  final List<String> received;
  const _ListenerProbe(this.received);

  @override
  State<_ListenerProbe> createState() => _ListenerProbeState();
}

class _ListenerProbeState extends State<_ListenerProbe>
    with WebWindowMessageMixin<_ListenerProbe> {
  @override
  void initState() {
    super.initState();
    startWindowMessageListener((raw, _) => widget.received.add(raw));
  }

  @override
  void dispose() {
    stopWindowMessageListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void _listenerPrimitiveTests() {
  testWidgets('registers a window listener on initState', (tester) async {
    final received = <String>[];
    await tester.pumpWidget(_app(_ListenerProbe(received)));

    _driveIframePosts('ready');

    expect(received, hasLength(1));
  });

  testWidgets('removes the window listener on dispose', (tester) async {
    final received = <String>[];
    await tester.pumpWidget(_app(_ListenerProbe(received)));
    await tester.pumpWidget(_app(const SizedBox.shrink()));

    _driveIframePosts('ready');

    expect(received, isEmpty);
  });

  testWidgets('a disposed listener does not block a later one', (tester) async {
    final first = <String>[];
    await tester.pumpWidget(_app(_ListenerProbe(first)));
    await tester.pumpWidget(_app(const SizedBox.shrink()));

    final second = <String>[];
    await tester.pumpWidget(_app(_ListenerProbe(second)));
    _driveIframePosts('ready');

    expect(first, isEmpty);
    expect(second, hasLength(1));
  });
}

// ---------------------------------------------------------------------------
// Group B & C harnesses — a stand-in for the web modal that owns its listener.
// Same initState/onCleanup wiring as DriveIntentWebViewModal (web), minus the
// iframe platform view, which is unavailable on the VM.
// ---------------------------------------------------------------------------

class _DriveModalUnderTest extends StatefulWidget {
  const _DriveModalUnderTest();

  @override
  State<_DriveModalUnderTest> createState() => _DriveModalUnderTestState();
}

class _DriveModalUnderTestState extends State<_DriveModalUnderTest>
    with
        DriveIntentMessageHandlerMixin<_DriveModalUnderTest>,
        WebWindowMessageMixin<_DriveModalUnderTest> {
  final List<DrivePickOutcome> outcomes = [];
  final List<String> ackCalls = [];
  // Records forwarded messages, so a listener leaked after close is observable
  // independently of the phase-closed guard.
  final List<String> forwarded = [];

  // Fast, but clear of the dialog's entry animation so pumpAndSettle can't
  // burn the deadline (production is 20s).
  @override
  Duration get readyTimeout => const Duration(seconds: 5);

  @override
  DriveOriginValidator get originValidator => const WebDriveOriginValidator();

  @override
  void initState() {
    super.initState();
    startWindowMessageListener(_forwardMessage);
    startLoading(() async => _intent());
    // Stands in for HtmlIframeWidget.onIframeCreated.
    notifyPlatformViewReady();
  }

  void _forwardMessage(String raw, String? origin) {
    forwarded.add(raw);
    onMessage(raw: raw, origin: origin);
  }

  @override
  Future<void> loadIntent(WorkplaceIntent intent) async {}

  @override
  Future<void> sendAck() async => ackCalls.add('ack');

  @override
  void onCleanup() => stopWindowMessageListener();

  @override
  void onFinished(DrivePickOutcome outcome) => outcomes.add(outcome);

  @override
  void dispose() {
    onCleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
        showSkeleton ? 'skeleton' : 'drive-picker',
        textDirection: TextDirection.ltr,
      );
}

Future<_DriveModalUnderTestState> _openModalInDialog(WidgetTester tester) async {
  late BuildContext hostContext;
  await tester.pumpWidget(_app(Builder(builder: (ctx) {
    hostContext = ctx;
    return const Scaffold();
  })));

  showDialog<DrivePickOutcome>(
    context: hostContext,
    barrierDismissible: false,
    builder: (_) => const _DriveModalUnderTest(),
  );
  await tester.pumpAndSettle();

  return tester.state<_DriveModalUnderTestState>(
    find.byType(_DriveModalUnderTest),
  );
}

void _modalOwnsListenerTests() {
  testWidgets('while open, a window message drives the handshake', (tester) async {
    final modal = await _openModalInDialog(tester);

    _driveIframePosts('ready');
    _driveIframePosts('readyToUse');
    await tester.pump();

    expect(modal.ackCalls, hasLength(1));
    expect(modal.showSkeleton, isFalse);
    expect(find.text('drive-picker'), findsOneWidget);
  });

  testWidgets('a message is delivered once, not once per live listener',
      (tester) async {
    final modal = await _openModalInDialog(tester);

    _driveIframePosts('ready');
    await tester.pump();

    expect(modal.ackCalls, hasLength(1));
  });

  testWidgets('the modal detaches its window listener when it closes',
      (tester) async {
    final modal = await _openModalInDialog(tester);
    _driveIframePosts('ready');
    expect(modal.forwarded, hasLength(1), reason: 'sanity: live while open');

    modal.cancel();
    await tester.pumpAndSettle();
    expect(find.byType(_DriveModalUnderTest), findsNothing);

    final beforeCount = modal.forwarded.length;
    _driveIframePosts('readyToUse');

    expect(
      modal.forwarded,
      hasLength(beforeCount),
      reason: 'a closed modal must not keep a live window listener',
    );
  });

  testWidgets('no handshake → the modal times out (timeout wiring intact)',
      (tester) async {
    final modal = await _openModalInDialog(tester);

    await tester.pump(const Duration(seconds: 6));

    expect(modal.outcomes, hasLength(1));
    expect(modal.outcomes.single, isA<DrivePickOutcomeFailed>());
  });
}

// ---------------------------------------------------------------------------
// Group C — end-to-end via the attachment context menu. This is the
// regression: the tile pops its own route on tap, so if the modal ever leaned
// on the tile's listener the handshake would be lost and the pick would fail.
// ---------------------------------------------------------------------------

/// Same shape as the real context-menu tile state: pops its own route in
/// onTap, then opens the picker modal.
class _MenuTileUnderTest extends StatefulWidget {
  const _MenuTileUnderTest();

  @override
  State<_MenuTileUnderTest> createState() => _MenuTileUnderTestState();
}

class _MenuTileUnderTestState extends State<_MenuTileUnderTest>
    with DrivePickerStateMixin<_MenuTileUnderTest> {
  @override
  DrivePickerSession get session => DrivePickerSession(
        uploadFromUrlSupported: () => false,
        maxAttachmentSizeBytesGetter: () => null,
        remainingAttachmentCapacityBytesGetter: () => null,
        onFetchIntent: _fetchIntentStub,
      );

  @override
  DriveIntentImageAssets get driveIntentImageAssets =>
      const DriveIntentImageAssets(driveLogo: '', closeIcon: '', searchIcon: '');

  @override
  Future<DrivePickOutcome?> openDrivePickerModal(
    WorkplaceFilePickerConfigRequest filePickerConfig,
  ) {
    return showDialog<DrivePickOutcome>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DriveModalUnderTest(),
    );
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: const Text('Attach from Drive'),
        onTap: () {
          Navigator.pop(context);
          onPickerTap();
        },
      );
}

Future<_DriveModalUnderTestState> _openPickerFromContextMenu(
  WidgetTester tester,
) async {
  late BuildContext hostContext;
  await tester.pumpWidget(_app(Builder(builder: (ctx) {
    hostContext = ctx;
    return const Scaffold();
  })));

  showModalBottomSheet<void>(
    context: hostContext,
    builder: (_) => const _MenuTileUnderTest(),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Attach from Drive'));
  await tester.pumpAndSettle();

  return tester.state<_DriveModalUnderTestState>(
    find.byType(_DriveModalUnderTest),
  );
}

void _contextMenuEndToEndTests() {
  testWidgets(
    'after the tile pops its route, the Drive handshake still reaches the '
    'modal — skeleton hides, no timeout',
    (tester) async {
      final modal = await _openPickerFromContextMenu(tester);
      expect(find.byType(_MenuTileUnderTest), findsNothing,
          reason: 'the tile route was popped before the modal opened');

      _driveIframePosts('ready');
      _driveIframePosts('readyToUse');
      await tester.pump();

      expect(modal.ackCalls, hasLength(1));
      expect(modal.showSkeleton, isFalse);

      await tester.pump(const Duration(seconds: 6));
      expect(modal.outcomes, isEmpty);
    },
  );

  testWidgets('a "done" pick from the context-menu flow resolves as Picked',
      (tester) async {
    final modal = await _openPickerFromContextMenu(tester);

    // Handshake over the real window transport proves the listener reaches the
    // modal after the tile is gone.
    _driveIframePosts('ready');
    await tester.pump();
    expect(modal.ackCalls, hasLength(1));

    // Terminal `done` goes via onMessage, not dispatchEvent: on the VM,
    // universal_html throws ConcurrentModificationError when onCleanup removes
    // the listener mid-dispatch (real browsers allow this).
    modal.onMessage(
      raw: jsonEncode({
        'type': 'intent-$_intentId:done',
        'document': [
          {
            'id': 'doc1',
            'name': 'file.pdf',
            'size': 512,
            'mimeType': 'application/pdf',
          }
        ],
      }),
      origin: _origin,
    );
    await tester.pumpAndSettle();

    expect(modal.outcomes, hasLength(1));
    expect(modal.outcomes.single, isA<DrivePickOutcomePicked>());
  });
}

void main() {
  setUp(() => PlatformInfo.isTestingForWeb = true);
  tearDown(() => PlatformInfo.isTestingForWeb = false);

  group('Drive picker web message-listener lifecycle', () {
    group('listener primitive', _listenerPrimitiveTests);
    group('modal owns its listener', _modalOwnsListenerTests);
    group('context-menu end to end', _contextMenuEndToEndTests);
  });
}
