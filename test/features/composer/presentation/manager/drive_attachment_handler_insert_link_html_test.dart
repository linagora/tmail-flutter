import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:workplace/domain/entity/drive_document.dart';

import 'drive_attachment_handler_test_helper.dart';

void main() {
  late List<String> insertedHtml;
  late DriveAttachmentHandler handler;

  setUp(() {
    insertedHtml = [];
    handler = DriveAttachmentHandler();
  });

  group('DriveAttachmentHandler::insertDriveLinkHtml::', () {
    test('Should generate anchor tag with escaped href and label', () async {
      final doc = DriveDocument(
        id: '1',
        name: 'My <Report>',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('https://example.com/file?a=1&b=2'),
      );

      await handler.insertDriveLinkHtml([
        doc,
      ], insertHtml: (html) => insertedHtml.add(html), appLocalizations: AppLocalizations());

      expect(insertedHtml.first, contains('&amp;'));
      expect(insertedHtml.first, contains('My &lt;Report&gt;'));
      expect(insertedHtml.first, contains('<a href='));
    });

    test('Should fall back to hardcoded English label when appLocalizations is not provided', () async {
      final doc = DriveDocument(
        id: '1',
        name: 'Report.pdf',
        size: 0,
        mimeType: 'application/pdf',
        sharingLink: Uri.parse('https://example.com/report.pdf'),
      );

      await handler.insertDriveLinkHtml([
        doc,
      ], insertHtml: (html) => insertedHtml.add(html));

      expect(insertedHtml.first, contains('Open in drive'));
    });

    test('Should wrap the whole card in a single anchor so clicking anywhere opens the link', () async {
      final doc = DriveDocument(
        id: '1',
        name: 'Report.pdf',
        size: 0,
        mimeType: 'application/pdf',
        sharingLink: Uri.parse('https://example.com/report.pdf'),
      );

      await handler.insertDriveLinkHtml([
        doc,
      ], insertHtml: (html) => insertedHtml.add(html), appLocalizations: AppLocalizations());

      final html = insertedHtml.first;
      expect('<a '.allMatches(html).length, 1);
      expect(html, matches(RegExp(r'^<div style="display:block[^>]*><a href="https://example\.com/report\.pdf"[^>]*>.*Report\.pdf.*</a></div><br>$')));
    });

    test('Should render multiple docs as cards in one wrapping row ending with a single <br>', () async {
      final doc2 = DriveDocument(
        id: '2',
        name: 'Second',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('https://example.com/second'),
      );

      await handler.insertDriveLinkHtml([
        linkDoc,
        doc2,
      ], insertHtml: (html) => insertedHtml.add(html), appLocalizations: AppLocalizations());

      final html = insertedHtml.first;
      expect(html, contains('Report'));
      expect(html, contains('Second'));
      expect('<br>'.allMatches(html).length, 1);
      expect(html, endsWith('<br>'));
      expect(html, matches(RegExp(r'^<div style="display:block[^>]*>.*</div><br>$')));
    });

    test('Should produce empty string for docs with null sharingLink', () async {
      await handler.insertDriveLinkHtml([
        noLinkDoc,
      ], insertHtml: (html) => insertedHtml.add(html), appLocalizations: AppLocalizations());

      expect(insertedHtml.first, isEmpty);
    });

    test('Should embed the document thumbnail link as the img src when provided', () async {
      final imageDoc = DriveDocument(
        id: '7',
        name: 'Photo.png',
        size: 0,
        mimeType: 'image/png',
        sharingLink: Uri.parse('https://example.com/photo.png'),
        thumbnail: DriveDocumentThumbnail(link: Uri.parse('https://cdn.example.com/thumbnails/photo.png')),
      );

      await handler.insertDriveLinkHtml([
        imageDoc,
      ], insertHtml: (html) => insertedHtml.add(html), appLocalizations: AppLocalizations());

      expect(insertedHtml.first, contains('<img src="https://cdn.example.com/thumbnails/photo.png"'));
    });

    test('Should render an img tag with empty src when the document has no thumbnail', () async {
      final xlsDoc = DriveDocument(
        id: '8',
        name: 'Sheet.xlsx',
        size: 0,
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sharingLink: Uri.parse('https://example.com/sheet.xlsx'),
      );

      await handler.insertDriveLinkHtml([
        xlsDoc,
      ], insertHtml: (html) => insertedHtml.add(html), appLocalizations: AppLocalizations());

      expect(insertedHtml.first, contains('<img src=""'));
    });

    test('Should skip non-https links in release mode', () async {
      final httpDoc = DriveDocument(
        id: '5',
        name: 'Insecure',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('http://example.com/file'),
      );

      await handler.insertDriveLinkHtml([
        httpDoc,
      ], insertHtml: (html) => insertedHtml.add(html), appLocalizations: AppLocalizations());

      if (kReleaseMode) {
        expect(insertedHtml.first, isEmpty);
      } else {
        expect(insertedHtml.first, contains('http://example.com/file'));
      }
    });
  });
}
