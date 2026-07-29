import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

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

  @override
  FetchDriveIntentCallback get pickerFetchIntent =>
      ({required filePickerConfig}) async => WorkplaceIntent(
            intentId: 'intent-1',
            intentUrl: Uri.parse('https://drive.example.com/pick'),
          );

  @override
  OnPickDriveCallback? get pickerOnCallback => pickStates.add;

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

Future<_TestState> _pumpPicker(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _TestWidget(),
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

      testWidgets('tap after state disposed → no modal, no callback, no crash', (tester) async {
        final state = await _pumpPicker(tester);
        await tester.pumpWidget(const SizedBox.shrink());

        await state.onPickerTap();

        expect(state.openCalls, isEmpty);
        expect(state.pickStates, isEmpty);
      });
    });
  });
}
