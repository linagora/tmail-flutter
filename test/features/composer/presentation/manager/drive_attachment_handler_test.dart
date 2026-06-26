import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:workplace/domain/entity/drive_document.dart';

import 'drive_attachment_handler_test_helper.dart';

void main() {
  late List<String> insertedHtml;
  late DriveAttachmentHandler handler;

  setUp(() {
    insertedHtml = [];
    handler = DriveAttachmentHandler(
      insertHtml: (html) => insertedHtml.add(html),
    );
  });

  group('DriveAttachmentHandler::handleDrivePickResult::', () {
    test('Should insert link html for docs with sharingLink', () {
      handler.handleDrivePickResult([linkDoc]);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('https://drive.example.com/report'));
      expect(insertedHtml.first, contains('Report'));
    });

    test('Should prefer sharingLink over downloadLink when doc has both', () {
      final bothLinksDoc = DriveDocument(
        id: '4',
        name: 'Both',
        size: 50,
        mimeType: 'application/pdf',
        sharingLink: Uri.parse('https://drive.example.com/both'),
        downloadLink: Uri.parse('https://drive.example.com/both-dl'),
      );

      handler.handleDrivePickResult([bothLinksDoc]);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('https://drive.example.com/both'));
    });

    test('Should skip docs with neither sharingLink nor downloadLink', () {
      handler.handleDrivePickResult([noLinkDoc]);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, isEmpty);
    });

    test('Should handle mixed docs correctly — only link docs inserted', () {
      handler.handleDrivePickResult([linkDoc, attachmentDoc, noLinkDoc]);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('Report'));
    });
  });
}
