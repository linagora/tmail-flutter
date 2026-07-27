import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

import 'drive_attachment_handler_test.mocks.dart';
import 'drive_attachment_handler_test_helper.dart';

@GenerateNiceMocks([MockSpec<ToastManager>()])
void main() {
  late List<String> insertedHtml;
  late DriveAttachmentHandler handler;
  late MockToastManager mockToastManager;
  final appLocalizations = AppLocalizations();

  setUp(() {
    insertedHtml = [];
    handler = Get.put(DriveAttachmentHandler());
    mockToastManager = MockToastManager();
    Get.put<ToastManager>(mockToastManager);
  });

  tearDown(() {
    Get.reset();
  });

  group('DriveAttachmentHandler::handleDrivePickResult::', () {
    test('Should insert link html for docs with sharingLink', () async {
      await handler.handleDrivePickResult([
        linkDoc,
      ], insertHtml: (html) async => insertedHtml.add(html), appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('https://drive.example.com/report'));
      expect(insertedHtml.first, contains('Report'));
      verifyNever(mockToastManager.showMessageFailure(any));
    });

    test('Should still work and fall back to hardcoded English label when appLocalizations is omitted', () async {
      await handler.handleDrivePickResult([
        linkDoc,
      ], insertHtml: (html) async => insertedHtml.add(html));

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

      await handler.handleDrivePickResult([
        bothLinksDoc,
      ], insertHtml: (html) async => insertedHtml.add(html), appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('https://drive.example.com/both'));
    });

    test('Should show download-only toast and not insert html when doc has neither sharingLink nor downloadLink', () async {
      await handler.handleDrivePickResult([
        noLinkDoc,
      ], insertHtml: (html) async => insertedHtml.add(html), appLocalizations: appLocalizations);

      expect(insertedHtml, isEmpty);
      verify(mockToastManager.showMessageFailure(any)).called(1);
    });

    test('Should handle mixed docs correctly — only link docs inserted, no toast shown', () async {
      await handler.handleDrivePickResult([
        linkDoc,
        attachmentDoc,
        noLinkDoc,
      ], insertHtml: (html) async => insertedHtml.add(html), appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('Report'));
      verifyNever(mockToastManager.showMessageFailure(any));
    });
  });

  group('DriveAttachmentHandler::handleDrivePickResult::download-only toast::', () {
    test('Should show toast with driveAttachmentInDevelopment message when all docs are download-only', () async {
      handler.handleDrivePickResult([
        attachmentDoc,
      ], insertHtml: (html) async => insertedHtml.add(html), appLocalizations: appLocalizations);

      expect(insertedHtml, isEmpty);
      final captured = verify(
        mockToastManager.showMessageFailure(captureAny),
      ).captured;
      expect(captured, hasLength(1));
      final failure = captured.single as DrivePickFailure;
      expect(failure.message, equals(appLocalizations.driveAttachmentInDevelopment));
    });

    test('Should show toast when result is empty', () async {
      handler.handleDrivePickResult(
        [],
        insertHtml: (html) async => insertedHtml.add(html),
        appLocalizations: appLocalizations,
      );

      expect(insertedHtml, isEmpty);
      verify(mockToastManager.showMessageFailure(any)).called(1);
    });

    test('Should show toast with null message when appLocalizations is omitted', () async {
      handler.handleDrivePickResult([
        attachmentDoc,
      ], insertHtml: (html) async => insertedHtml.add(html));

      expect(insertedHtml, isEmpty);
      final captured = verify(
        mockToastManager.showMessageFailure(captureAny),
      ).captured;
      expect(captured, hasLength(1));
      final failure = captured.single as DrivePickFailure;
      expect(failure.message, isNull);
    });

    test('Should not show toast when at least one doc has sharingLink', () async {
      handler.handleDrivePickResult([
        attachmentDoc,
        linkDoc,
      ], insertHtml: (html) async => insertedHtml.add(html), appLocalizations: appLocalizations);

      expect(insertedHtml, hasLength(1));
      verifyNever(mockToastManager.showMessageFailure(any));
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
