import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/model/workplace_enums.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';
import 'package:workplace/presentation/model/drive_picker_session.dart';

typedef _ModalStub = Future<DrivePickOutcome?> Function();

// Harness overriding the modal seam — no real WebView/iframe is pumped.
class _TestWidget extends StatefulWidget {
  const _TestWidget();

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<_TestWidget>
    with DrivePickerStateMixin<_TestWidget> {
  final List<DrivePickState> pickStates = [];
  final List<WorkplaceFilePickerConfigRequest> openCalls = [];
  _ModalStub modalStub = () => Future.value();
  num? maxAttachmentSizeBytesStub;
  num? remainingAttachmentCapacityBytesStub;
  bool uploadFromUrlSupportedOverride = true;
  bool sessionResolveThrows = false;
  bool pickCallbackThrows = false;
  Completer<void>? pickCallbackBlocker;

  @override
  DrivePickerSession get session => DrivePickerSession(
        uploadFromUrlSupported: () => uploadFromUrlSupportedOverride,
        maxAttachmentSizeBytesGetter: () {
          if (sessionResolveThrows) throw StateError('capability read blew up');
          return maxAttachmentSizeBytesStub;
        },
        remainingAttachmentCapacityBytesGetter: () =>
            remainingAttachmentCapacityBytesStub,
        onFetchIntent: ({required filePickerConfig}) async => WorkplaceIntent(
          intentId: 'intent-1',
          intentUrl: Uri.parse('https://drive.example.com/pick'),
        ),
      );

  @override
  OnPickDriveCallback? get pickerOnCallback => (state) async {
        pickStates.add(state);
        if (pickCallbackThrows) throw StateError('consumer handler blew up');
        if (pickCallbackBlocker != null) await pickCallbackBlocker!.future;
      };

  @override
  DriveIntentImageAssets get driveIntentImageAssets =>
      const DriveIntentImageAssets(driveLogo: '', closeIcon: '', searchIcon: '');

  @override
  Future<DrivePickOutcome?> openDrivePickerModal(
    WorkplaceFilePickerConfigRequest filePickerConfig,
  ) {
    openCalls.add(filePickerConfig);
    return modalStub();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

Future<_TestState> _pumpPicker(WidgetTester tester, {ThemeData? theme}) async {
  await tester.pumpWidget(MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const _TestWidget(),
  ));
  return tester.state<_TestState>(find.byType(_TestWidget));
}

DriveDocument _doc() => const DriveDocument(
      id: 'doc1',
      name: 'file.pdf',
      size: 512,
      mimeType: 'application/pdf',
    );

void main() {
  group('DrivePickerStateMixin', () {
    group('outcome dispatch', () {
      testWidgets('Picked → DrivePickResult with documents', (tester) async {
        final state = await _pumpPicker(tester);
        state.modalStub = () => Future.value(DrivePickOutcomePicked([_doc()]));

        await state.onPickerTap();

        expect(state.pickStates, hasLength(1));
        final result = state.pickStates.single as DrivePickResult;
        expect(result.documents.single.id, 'doc1');
      });

      testWidgets('Failed → DrivePickFailure with error and message', (tester) async {
        final state = await _pumpPicker(tester);
        final error = StateError('token exchange failed');
        state.modalStub = () => Future.value(DrivePickOutcomeFailed(error));

        await state.onPickerTap();

        expect(state.pickStates, hasLength(1));
        final failure = state.pickStates.single as DrivePickFailure;
        expect(failure.error, same(error));
        expect(failure.message, isNotNull);
      });

      testWidgets('Cancelled → no callback', (tester) async {
        final state = await _pumpPicker(tester);
        state.modalStub = () => Future.value(const DrivePickOutcomeCancelled());

        await state.onPickerTap();

        expect(state.pickStates, isEmpty);
      });

      testWidgets('null outcome (route popped externally) → no callback', (tester) async {
        final state = await _pumpPicker(tester);
        state.modalStub = () => Future.value(null);

        await state.onPickerTap();

        expect(state.pickStates, isEmpty);
      });

      testWidgets('callback throwing → contained, tap allowed again', (tester) async {
        final state = await _pumpPicker(tester);
        state.pickCallbackThrows = true;
        state.modalStub = () => Future.value(DrivePickOutcomePicked([_doc()]));

        await state.onPickerTap();
        await state.onPickerTap();

        expect(state.pickStates, hasLength(2));
        expect(state.openCalls, hasLength(2));
      });

      testWidgets('modal future fails → DrivePickFailure with the thrown error', (tester) async {
        final state = await _pumpPicker(tester);
        final error = StateError('showDialog failed');
        state.modalStub = () => Future.error(error);

        await state.onPickerTap();

        expect(state.pickStates, hasLength(1));
        final failure = state.pickStates.single as DrivePickFailure;
        expect(failure.error, same(error));
      });
    });

    group('maxAttachmentSizeBytes', () {
      testWidgets('exposes the value returned by the mixer override', (tester) async {
        final state = await _pumpPicker(tester);
        state.maxAttachmentSizeBytesStub = 5000;

        expect(state.session.maxAttachmentSizeBytesGetter(), equals(5000));
      });

      testWidgets('is null when the mixer override returns null', (tester) async {
        final state = await _pumpPicker(tester);
        state.maxAttachmentSizeBytesStub = null;

        expect(state.session.maxAttachmentSizeBytesGetter(), isNull);
      });
    });

    group('availableSize', () {
      testWidgets('advertises the remaining capacity, not the full limit', (tester) async {
        final state = await _pumpPicker(tester);
        state.maxAttachmentSizeBytesStub = 100 * 1024 * 1024;
        state.remainingAttachmentCapacityBytesStub = 20 * 1024 * 1024;

        await state.onPickerTap();

        final downloadLink = state.openCalls.single.downloadLink!;
        expect(downloadLink.availableSize, equals(20 * 1024 * 1024));
        expect(downloadLink.maxFileSize, equals(100 * 1024 * 1024));
      });

      testWidgets('falls back to the full limit when no remainder is known', (tester) async {
        final state = await _pumpPicker(tester);
        state.maxAttachmentSizeBytesStub = 100 * 1024 * 1024;
        state.remainingAttachmentCapacityBytesStub = null;

        await state.onPickerTap();

        final downloadLink = state.openCalls.single.downloadLink!;
        expect(downloadLink.availableSize, equals(100 * 1024 * 1024));
      });
    });

    group('capability gating', () {
      testWidgets('downloadLink is set when uploadFromUrlSupported is true', (tester) async {
        final state = await _pumpPicker(tester);
        state.uploadFromUrlSupportedOverride = true;
        state.modalStub = () => Future.value(const DrivePickOutcomeCancelled());

        await state.onPickerTap();

        expect(state.openCalls.single.downloadLink, isNotNull);
      });

      testWidgets('downloadLink is null when uploadFromUrlSupported is false', (tester) async {
        final state = await _pumpPicker(tester);
        state.uploadFromUrlSupportedOverride = false;
        state.modalStub = () => Future.value(const DrivePickOutcomeCancelled());

        await state.onPickerTap();

        expect(state.openCalls.single.downloadLink, isNull);
      });
    });

    group('theme resolution', () {
      testWidgets('uses the app declared theme (light) regardless of no explicit theme', (tester) async {
        final state = await _pumpPicker(tester);
        state.modalStub = () => Future.value(const DrivePickOutcomeCancelled());

        await state.onPickerTap();

        expect(state.openCalls.single.theme.type, WorkplaceThemeType.light);
      });

      testWidgets('follows the app theme brightness when dark', (tester) async {
        final state = await _pumpPicker(
          tester,
          theme: ThemeData(brightness: Brightness.dark),
        );
        state.modalStub = () => Future.value(const DrivePickOutcomeCancelled());

        await state.onPickerTap();

        expect(state.openCalls.single.theme.type, WorkplaceThemeType.dark);
      });
    });

    group('re-entrancy and lifecycle', () {
      testWidgets('second tap while modal is open → ignored', (tester) async {
        final state = await _pumpPicker(tester);
        final completer = Completer<DrivePickOutcome?>();
        state.modalStub = () => completer.future;

        final firstTap = state.onPickerTap();
        await state.onPickerTap();
        expect(state.openCalls, hasLength(1));

        completer.complete(const DrivePickOutcomeCancelled());
        await firstTap;
      });

      testWidgets('second tap while pick callback is in flight → opens another picker', (tester) async {
        final state = await _pumpPicker(tester);
        final callbackBlocker = Completer<void>();
        state.pickCallbackBlocker = callbackBlocker;
        state.modalStub = () => Future.value(DrivePickOutcomePicked([_doc()]));

        final firstTap = state.onPickerTap();
        await tester.pump();
        expect(state.openCalls, hasLength(1));
        expect(state.pickStates, hasLength(1));

        final secondTap = state.onPickerTap();
        await tester.pump();
        expect(state.openCalls, hasLength(2));
        expect(state.pickStates, hasLength(2));

        callbackBlocker.complete();
        await firstTap;
        await secondTap;
      });

      testWidgets('tap allowed again after previous modal closed', (tester) async {
        final state = await _pumpPicker(tester);
        state.modalStub = () => Future.value(const DrivePickOutcomeCancelled());

        await state.onPickerTap();
        await state.onPickerTap();

        expect(state.openCalls, hasLength(2));
      });

      testWidgets('tap allowed again after modal failure', (tester) async {
        final state = await _pumpPicker(tester);
        state.modalStub = () => Future.error(StateError('modal crashed'));
        await state.onPickerTap();

        state.modalStub = () => Future.value(const DrivePickOutcomeCancelled());
        await state.onPickerTap();

        expect(state.openCalls, hasLength(2));
      });

      testWidgets('tap after state disposed → no modal, failure callback, no crash', (tester) async {
        final state = await _pumpPicker(tester);
        await tester.pumpWidget(const SizedBox.shrink());

        await state.onPickerTap();

        expect(state.openCalls, isEmpty);
        // Reported rather than dropped: the user tapped and must learn nothing opened.
        final failure = state.pickStates.single as DrivePickFailure;
        expect(failure.message, isNull, reason: 'no live context to localize with');
      });

      testWidgets('pick delivered even though the opener was disposed mid-flight', (tester) async {
        final state = await _pumpPicker(tester);
        final completer = Completer<DrivePickOutcome?>();
        state.modalStub = () => completer.future;

        final tap = state.onPickerTap();
        await tester.pumpWidget(const SizedBox.shrink());
        expect(state.mounted, isFalse, reason: 'sanity: opener really is gone');

        completer.complete(DrivePickOutcomePicked([_doc()]));
        await tap;

        expect(state.pickStates, hasLength(1));
        final result = state.pickStates.single as DrivePickResult;
        expect(result.documents.single.id, 'doc1');
      });

      // Pins the up-front capture of the toast text: localizations need a live
      // context, so reading them after the await would lose the message.
      testWidgets('failure after opener disposal keeps the localized message', (tester) async {
        final state = await _pumpPicker(tester);
        final completer = Completer<DrivePickOutcome?>();
        state.modalStub = () => completer.future;

        final tap = state.onPickerTap();
        await tester.pumpWidget(const SizedBox.shrink());

        completer.complete(DrivePickOutcomeFailed(StateError('intent failed')));
        await tap;

        expect(state.pickStates, hasLength(1));
        final failure = state.pickStates.single as DrivePickFailure;
        expect(failure.message, isNotNull);
      });
    });

    group('configuration failures', () {
      testWidgets('resolver throw → failure callback, no modal, no unhandled error', (tester) async {
        final state = await _pumpPicker(tester);
        state.sessionResolveThrows = true;

        await state.onPickerTap();

        expect(state.openCalls, isEmpty);
        final failure = state.pickStates.single as DrivePickFailure;
        expect(failure.message, isNotNull, reason: 'localized before the throw');
        expect(tester.takeException(), isNull);
      });

      testWidgets('tap allowed again after a configuration failure', (tester) async {
        final state = await _pumpPicker(tester);
        state.sessionResolveThrows = true;
        await state.onPickerTap();

        state.sessionResolveThrows = false;
        state.modalStub = () => Future.value(DrivePickOutcomePicked([_doc()]));
        await state.onPickerTap();

        expect(state.openCalls, hasLength(1));
        expect(state.pickStates.last, isA<DrivePickResult>());
        expect(tester.takeException(), isNull);
      });
    });
  });
}
