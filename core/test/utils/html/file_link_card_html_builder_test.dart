import 'package:flutter_test/flutter_test.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';

void main() {
  group('FileLinkCardHtmlBuilder buildFileLinkCard tests', () {
    test('Should build anchor tag with href, title and action label', () {
      final result = FileLinkCardHtmlBuilder.buildFileLinkCard(
        const FileLinkCardContent(
          href: 'https://example.com/file',
          title: 'My File',
          actionLabel: 'Open in drive',
          iconZoneHtml: '<div>icon</div>',
        ),
      );

      expect(result, startsWith('<a href="https://example.com/file"'));
      expect(result, contains('target="_blank"'));
      expect(result, contains('rel="noopener noreferrer"'));
      expect(result, contains('<div>icon</div>'));
      expect(result, contains('title="My File">My File</div>'));
      expect(result, contains('Open in drive ↗'));
      expect(result, endsWith('</a>'));
    });

    test('Should apply custom card width and min height', () {
      final result = FileLinkCardHtmlBuilder.buildFileLinkCard(
        const FileLinkCardContent(
          href: 'https://example.com/file',
          title: 'My File',
          actionLabel: 'Open in drive',
          iconZoneHtml: '',
        ),
        size: const FileLinkCardSize(cardWidthPx: 200, cardMinHeightPx: 100),
      );

      expect(result, contains('width:200px'));
      expect(result, contains('min-height:100px'));
    });

    test('Should escape href, title and action label to prevent HTML/attribute injection', () {
      final result = FileLinkCardHtmlBuilder.buildFileLinkCard(
        const FileLinkCardContent(
          href: 'https://example.com/file?a="><script>alert(1)</script>',
          title: '<script>alert(1)</script>',
          actionLabel: '"><b>bold</b>',
          iconZoneHtml: '',
        ),
      );

      expect(result, isNot(contains('<script>')));
      expect(result, isNot(contains('"><b>')));
    });
  });

  group('FileLinkCardHtmlBuilder buildFileCardIconZone tests', () {
    test('Should render an image tag with the given imageUrl as src', () {
      final result = FileLinkCardHtmlBuilder.buildFileCardIconZone(
        imageUrl: 'https://example.com/thumb.png',
      );

      expect(result, contains('<img src="https://example.com/thumb.png"'));
      expect(result, contains('width="60" height="60"'));
    });

    test('Should omit the image tag entirely when imageUrl is null', () {
      final result = FileLinkCardHtmlBuilder.buildFileCardIconZone();

      expect(result, isNot(contains('<img')));
      expect(result, contains('<div style='));
    });

    test('Should omit the image tag entirely when imageUrl is empty', () {
      final result = FileLinkCardHtmlBuilder.buildFileCardIconZone(imageUrl: '');

      expect(result, isNot(contains('<img')));
    });

    test('Should apply custom icon zone height and icon size', () {
      final result = FileLinkCardHtmlBuilder.buildFileCardIconZone(
        imageUrl: 'https://example.com/thumb.png',
        iconZoneHeightPx: 120,
        iconSizePx: 80,
      );

      expect(result, contains('height:120px'));
      expect(result, contains('width="80" height="80"'));
    });

    test('Should escape imageUrl to prevent attribute injection', () {
      final result = FileLinkCardHtmlBuilder.buildFileCardIconZone(
        imageUrl: 'https://example.com/thumb.png"><script>alert(1)</script>',
      );

      expect(result, isNot(contains('<script>')));
    });
  });

  group('FileLinkCardHtmlBuilder wrapFileCardsHtml tests', () {
    test('Should return empty string when cards is empty', () {
      final result = FileLinkCardHtmlBuilder.wrapFileCardsHtml([]);

      expect(result, isEmpty);
    });

    test('Should wrap cards in an editable block-level div followed by an empty paragraph', () {
      final result = FileLinkCardHtmlBuilder.wrapFileCardsHtml(['<a>card1</a>', '<a>card2</a>']);

      expect(result, '<div style="display:block;max-width:100%;"><a>card1</a><a>card2</a></div><p><br></p>');
    });

    test('Should concatenate cards without inserting anything between them', () {
      final result = FileLinkCardHtmlBuilder.wrapFileCardsHtml(['<a>card1</a>', '<a>card2</a>', '<a>card3</a>']);

      expect(result, contains('<a>card1</a><a>card2</a><a>card3</a>'));
    });
  });
}
