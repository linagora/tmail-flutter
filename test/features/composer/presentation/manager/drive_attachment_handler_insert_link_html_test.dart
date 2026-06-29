import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:workplace/domain/entity/drive_document.dart';

import 'drive_attachment_handler_test_helper.dart';

void main() {
  late List<String> insertedHtml;
  late DriveAttachmentHandler handler;

  setUp(() {
    insertedHtml = [];
    handler = const DriveAttachmentHandler();
  });

  group('DriveAttachmentHandler::insertDriveLinkHtml::', () {
    test('Should generate anchor tag with escaped href and label', () {
      final doc = DriveDocument(
        id: '1',
        name: 'My <Report>',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('https://example.com/file?a=1&b=2'),
      );

      handler.insertDriveLinkHtml([
        doc,
      ], insertHtml: (html) => insertedHtml.add(html));

      expect(insertedHtml.first, contains('&amp;'));
      expect(insertedHtml.first, contains('My &lt;Report&gt;'));
      expect(insertedHtml.first, contains('<a href='));
    });

    test('Should join multiple links with <br>', () {
      final doc2 = DriveDocument(
        id: '2',
        name: 'Second',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('https://example.com/second'),
      );

      handler.insertDriveLinkHtml([
        linkDoc,
        doc2,
      ], insertHtml: (html) => insertedHtml.add(html));

      expect(insertedHtml.first, contains('<br>'));
    });

    test('Should produce empty string for docs with null sharingLink', () {
      handler.insertDriveLinkHtml([
        noLinkDoc,
      ], insertHtml: (html) => insertedHtml.add(html));

      expect(insertedHtml.first, isEmpty);
    });

    test('Should skip non-https links in release mode', () {
      final httpDoc = DriveDocument(
        id: '5',
        name: 'Insecure',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('http://example.com/file'),
      );

      handler.insertDriveLinkHtml([
        httpDoc,
      ], insertHtml: (html) => insertedHtml.add(html));

      if (kReleaseMode) {
        expect(insertedHtml.first, isEmpty);
      } else {
        expect(insertedHtml.first, contains('http://example.com/file'));
      }
    });
  });
}
