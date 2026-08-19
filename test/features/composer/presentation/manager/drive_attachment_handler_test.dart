import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_transfer_runner.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

import 'drive_attachment_handler_test.mocks.dart';
import 'drive_attachment_handler_test_helper.dart';

@GenerateNiceMocks([MockSpec<ToastManager>()])
void main() {
  late List<String> insertedHtml;
  late List<List<DriveDocument>> transferredBatches;
  late DriveTransferOutcome transferOutcome;
  late DriveAttachmentHandler handler;
  late MockToastManager mockToastManager;
  final appLocalizations = AppLocalizations();

  Future<void> handlePick(
    List<DriveDocument> result, {
    AppLocalizations? appLocalizations,
  }) {
    return handler.handleDrivePickResult(
      result,
      insertHtml: (html) async { insertedHtml.add(html); return true; },
      transferDriveDocuments: (docs) async {
        transferredBatches.add(docs);
        return transferOutcome;
      },
      appLocalizations: appLocalizations,
    );
  }

  setUp(() {
    insertedHtml = [];
    transferredBatches = [];
    transferOutcome = (started: true, succeeded: 1, failed: 0);
    handler = Get.put(DriveAttachmentHandler());
    mockToastManager = MockToastManager();
    Get.put<ToastManager>(mockToastManager);
  });

  tearDown(() {
    Get.reset();
  });

  group('DriveAttachmentHandler::handleDrivePickResult::', () {
    test('Should toast failure for docs dropped alongside a valid sibling', () async {
      await handlePick([linkDoc, noLinkDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      verify(mockToastManager.showMessageFailure(any)).called(1);
    });

    test('Should toast failure instead of success when the editor is unbound', () async {
      await handler.handleDrivePickResult(
        [linkDoc],
        insertHtml: (_) async => false,
        transferDriveDocuments: (docs) async {
          transferredBatches.add(docs);
          return transferOutcome;
        },
        appLocalizations: appLocalizations,
      );

      verify(mockToastManager.showMessageFailure(any)).called(1);
      verifyNever(mockToastManager.showMessageSuccess(any));
    });

    test('Should insert link html for docs with sharingLink', () async {
      await handlePick([linkDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('https://drive.example.com/report'));
      expect(insertedHtml.first, contains('Report'));
      expect(transferredBatches, isEmpty);
      verifyNever(mockToastManager.showMessageFailure(any));
      verify(mockToastManager.showMessageSuccess(any)).called(1);
    });

    test('Should still work and fall back to hardcoded English label when appLocalizations is omitted', () async {
      await handlePick([linkDoc]);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('Open in drive'));
    });

    test('Should prefer sharingLink over downloadLink when doc has both', () async {
      final bothLinksDoc = DriveDocument(
        id: '4',
        name: 'Both',
        size: 50,
        mimeType: 'application/pdf',
        sharingLink: Uri.parse('https://drive.example.com/both'),
        downloadLink: Uri.parse('https://drive.example.com/both-dl'),
      );

      await handlePick([bothLinksDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('https://drive.example.com/both'));
      expect(transferredBatches, isEmpty);
    });

    test('Should show toast and not insert html or transfer when doc has neither sharingLink nor downloadLink', () async {
      await handlePick([noLinkDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, isEmpty);
      expect(transferredBatches, isEmpty);
      verify(mockToastManager.showMessageFailure(any)).called(1);
    });

    test('Should not transfer a doc whose downloadLink is empty, and show a toast', () async {
      await handlePick([emptyDownloadLinkDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, isEmpty);
      expect(transferredBatches, isEmpty);
      final captured = verify(
        mockToastManager.showMessageFailure(captureAny),
      ).captured;
      expect(captured, hasLength(1));
      final failure = captured.single as DrivePickFailure;
      expect(failure.message, equals(appLocalizations.driveNoValidAttachment));
    });

    test('Should dispatch download-only docs to transferDriveDocuments, link docs to insertHtml', () async {
      await handlePick([linkDoc, attachmentDoc, noLinkDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('Report'));
      expect(transferredBatches, [[attachmentDoc]]);
      // noLinkDoc is attachable neither way — the drop must be reported.
      verify(mockToastManager.showMessageFailure(any)).called(1);
    });

    test('Should show a success toast carrying the localized message for a link-only pick', () async {
      await handlePick([linkDoc], appLocalizations: appLocalizations);

      final captured = verify(
        mockToastManager.showMessageSuccess(captureAny),
      ).captured;
      expect(captured, hasLength(1));
      final success = captured.single as DrivePickSuccess;
      expect(success.message, equals(appLocalizations.driveAttachmentAddedSuccessfully));
    });
  });

  group('DriveAttachmentHandler::handleDrivePickResult::download-only transfer::', () {
    test('Should call transferDriveDocuments with download-only docs and toast success', () async {
      await handlePick([attachmentDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, isEmpty);
      expect(transferredBatches, [[attachmentDoc]]);
      verifyNever(mockToastManager.showMessageFailure(any));
      verify(mockToastManager.showMessageSuccess(any)).called(1);
    });

    test('Should show no toast when only some docs of the batch transferred', () async {
      transferOutcome = (started: true, succeeded: 1, failed: 1);

      await handlePick([attachmentDoc], appLocalizations: appLocalizations);

      verifyNever(mockToastManager.showMessageSuccess(any));
      verifyNever(mockToastManager.showMessageFailure(any));
    });

    test('Should show no toast when every transfer of the batch was cancelled', () async {
      transferOutcome = (started: true, succeeded: 0, failed: 0);

      await handlePick([attachmentDoc], appLocalizations: appLocalizations);

      verifyNever(mockToastManager.showMessageSuccess(any));
      verifyNever(mockToastManager.showMessageFailure(any));
    });

    test('Should still toast success when links were inserted and every transfer was cancelled', () async {
      transferOutcome = (started: true, succeeded: 0, failed: 0);

      await handlePick([attachmentDoc, linkDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      verify(mockToastManager.showMessageSuccess(any)).called(1);
      verifyNever(mockToastManager.showMessageFailure(any));
    });

    test('Should show toast when transferDriveDocuments reports it took nothing', () async {
      transferOutcome = DriveAttachmentTransferRunner.notStartedOutcome;

      await handlePick([attachmentDoc], appLocalizations: appLocalizations);

      final captured = verify(
        mockToastManager.showMessageFailure(captureAny),
      ).captured;
      expect(captured, hasLength(1));
      final failure = captured.single as DrivePickFailure;
      expect(failure.message, equals(appLocalizations.driveAttachmentTransferFailed));
    });

    test('Should show toast when result is empty', () async {
      await handlePick([], appLocalizations: appLocalizations);

      expect(insertedHtml, isEmpty);
      expect(transferredBatches, isEmpty);
      verify(mockToastManager.showMessageFailure(any)).called(1);
    });

    test('Should show toast with null message when appLocalizations is omitted', () async {
      transferOutcome = DriveAttachmentTransferRunner.notStartedOutcome;

      await handlePick([attachmentDoc]);

      final captured = verify(
        mockToastManager.showMessageFailure(captureAny),
      ).captured;
      expect(captured, hasLength(1));
      final failure = captured.single as DrivePickFailure;
      expect(failure.message, isNull);
    });

    test('Should toast success when a mixed pick fully transfers', () async {
      await handlePick([attachmentDoc, linkDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      expect(transferredBatches, [[attachmentDoc]]);
      verifyNever(mockToastManager.showMessageFailure(any));
      verify(mockToastManager.showMessageSuccess(any)).called(1);
    });

    test('Should toast and still insert links when mixed pick transfer cannot start', () async {
      transferOutcome = DriveAttachmentTransferRunner.notStartedOutcome;

      await handlePick([attachmentDoc, linkDoc], appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('Report'));
      expect(transferredBatches, [[attachmentDoc]]);
      final captured = verify(
        mockToastManager.showMessageFailure(captureAny),
      ).captured;
      expect(captured, hasLength(1));
      final failure = captured.single as DrivePickFailure;
      expect(failure.message, equals(appLocalizations.driveAttachmentTransferFailed));
    });

    test('Should await an async insertHtml callback before insertDriveLinkHtml completes', () async {
      final callOrder = <String>[];

      await handler.insertDriveLinkHtml(
        [linkDoc],
        insertHtml: (html) async {
          callOrder.add('insertHtml-start');
          await Future<void>.delayed(const Duration(milliseconds: 10));
          insertedHtml.add(html);
          callOrder.add('insertHtml-end');
          return true;
        },
        appLocalizations: appLocalizations,
      );
      callOrder.add('awaited');

      expect(callOrder, ['insertHtml-start', 'insertHtml-end', 'awaited']);
      expect(insertedHtml, hasLength(1));
    });

    test('Should propagate exceptions thrown by an async insertHtml callback', () async {
      Object? caughtError;

      try {
        await handler.insertDriveLinkHtml(
          [linkDoc],
          insertHtml: (html) async {
            await Future<void>.delayed(const Duration(milliseconds: 5));
            throw StateError('mobile insertHtml failed');
          },
          appLocalizations: appLocalizations,
        );
      } catch (e) {
        caughtError = e;
      }

      expect(caughtError, isA<StateError>());
    });
  });
}
