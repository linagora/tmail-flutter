import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:workplace/domain/entity/drive_document.dart';

import 'drive_attachment_handler_test_helper.dart';

void main() {
  late List<String> insertedHtml;
  late DriveAttachmentHandler handler;

  setUpAll(() {
    Get.put(DriveAttachmentHandler());
  });

  setUp(() {
    insertedHtml = [];
    handler = Get.find<DriveAttachmentHandler>();
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

      handler.insertDriveLinkHtml([
        doc,
      ], insertHtml: (html) async { insertedHtml.add(html); return true; }, appLocalizations: AppLocalizations());

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

      handler.insertDriveLinkHtml([
        doc,
      ], insertHtml: (html) async { insertedHtml.add(html); return true; });

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

      handler.insertDriveLinkHtml([
        doc,
      ], insertHtml: (html) async { insertedHtml.add(html); return true; }, appLocalizations: AppLocalizations());

      final html = insertedHtml.first;
      expect('<a '.allMatches(html).length, 1);
      expect(html, matches(RegExp(r'^<div style="display:block[^>]*>.*<a href="https://example\.com/report\.pdf"[^>]*>.*Report\.pdf.*</a>.*</div><p><br></p>$')));
    });

    test('Should render multiple docs as cards in one wrapping row ending with an empty paragraph', () async {
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
      ], insertHtml: (html) async { insertedHtml.add(html); return true; }, appLocalizations: AppLocalizations());

      final html = insertedHtml.first;
      expect(html, contains('Report'));
      expect(html, contains('Second'));
      expect('<p><br></p>'.allMatches(html).length, 1);
      expect(html, endsWith('<p><br></p>'));
      expect(html, matches(RegExp(r'^<div style="display:block[^>]*>.*</div><p><br></p>$')));
    });

    test('Should produce empty string for docs with null sharingLink', () async {
      handler.insertDriveLinkHtml([
        noLinkDoc,
      ], insertHtml: (html) async { insertedHtml.add(html); return true; }, appLocalizations: AppLocalizations());

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

      handler.insertDriveLinkHtml([
        imageDoc,
      ], insertHtml: (html) async { insertedHtml.add(html); return true; }, appLocalizations: AppLocalizations());

      expect(insertedHtml.first, contains('<img src="https://cdn.example.com/thumbnails/photo.png"'));
    });

    test('Should omit the img tag entirely when the document has no thumbnail', () async {
      final xlsDoc = DriveDocument(
        id: '8',
        name: 'Sheet.xlsx',
        size: 0,
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sharingLink: Uri.parse('https://example.com/sheet.xlsx'),
      );

      handler.insertDriveLinkHtml([
        xlsDoc,
      ], insertHtml: (html) async { insertedHtml.add(html); return true; }, appLocalizations: AppLocalizations());

      expect(insertedHtml.first, isNot(contains('<img')));
    });

    test('Should embed a non-https thumbnail when requireHttps is false', () async {
      final httpThumbnailDoc = DriveDocument(
        id: '10',
        name: 'Photo3.png',
        size: 0,
        mimeType: 'image/png',
        sharingLink: Uri.parse('https://example.com/photo3.png'),
        thumbnail: DriveDocumentThumbnail(link: Uri.parse('http://cdn.example.com/thumbnails/photo3.png')),
      );

      handler.insertDriveLinkHtml([
        httpThumbnailDoc,
      ], insertHtml: (html) async { insertedHtml.add(html); return true; }, appLocalizations: AppLocalizations());

      expect(insertedHtml.first, contains('<img src="http://cdn.example.com/thumbnails/photo3.png"'));
    });

    test('Should allow non-https links when requireHttps is false', () async {
      final httpDoc = DriveDocument(
        id: '5',
        name: 'Insecure',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('http://example.com/file'),
      );

      handler.insertDriveLinkHtml([
        httpDoc,
      ], insertHtml: (html) async { insertedHtml.add(html); return true; }, appLocalizations: AppLocalizations());

      expect(insertedHtml.first, contains('http://example.com/file'));
    });
  });
}
