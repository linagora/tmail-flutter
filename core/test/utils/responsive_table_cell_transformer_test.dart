import 'package:core/presentation/utils/html_transformer/dom/responsive_table_cell_transformer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:mockito/annotations.dart';

import 'responsive_table_cell_transformer_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DioClient>()])
void main() {
  group('ResponsiveTableCellTransformer', () {
    const transformer = ResponsiveTableCellTransformer();
    final dioClient = MockDioClient();

    Future<Document> run(String html) async {
      final doc = parse(html);
      await transformer.process(document: doc, dioClient: dioClient);
      return doc;
    }

    test('adds overflow-wrap: anywhere to td with no existing style', () async {
      final doc = await run('<table><tr><td>content</td></tr></table>');
      expect(
        doc.querySelector('td')!.attributes['style'],
        'overflow-wrap: anywhere;',
      );
    });

    test('adds overflow-wrap: anywhere to th with no existing style', () async {
      final doc = await run('<table><tr><th>header</th></tr></table>');
      expect(
        doc.querySelector('th')!.attributes['style'],
        'overflow-wrap: anywhere;',
      );
    });

    test('appends overflow-wrap to td that already has a style ending with semicolon', () async {
      final doc = await run(
        '<table><tr><td style="min-width: 80px;">label</td></tr></table>',
      );
      expect(
        doc.querySelector('td')!.attributes['style'],
        'min-width: 80px; overflow-wrap: anywhere;',
      );
    });

    test('appends overflow-wrap with separator to td whose style has no trailing semicolon', () async {
      final doc = await run(
        '<table><tr><td style="color: red">text</td></tr></table>',
      );
      expect(
        doc.querySelector('td')!.attributes['style'],
        'color: red; overflow-wrap: anywhere;',
      );
    });

    test('does not override overflow-wrap when it is already set on td', () async {
      final doc = await run(
        '<table><tr><td style="overflow-wrap: break-word;">url</td></tr></table>',
      );
      expect(
        doc.querySelector('td')!.attributes['style'],
        'overflow-wrap: break-word;',
      );
    });

    test('processes all td and th elements in the document', () async {
      final doc = await run('''
        <table>
          <tr><th>Time</th><td>Tuesday 10:00</td></tr>
          <tr><th>Link</th><td>https://example.com/very-long-path</td></tr>
        </table>
      ''');
      final cells = doc.querySelectorAll('td, th');
      for (final cell in cells) {
        expect(
          cell.attributes['style'],
          contains('overflow-wrap: anywhere'),
          reason: 'Every td/th should have overflow-wrap: anywhere',
        );
      }
    });

    test('does nothing when document has no td or th elements', () async {
      final doc = await run('<div><p>No tables here</p></div>');
      expect(doc.querySelectorAll('td, th'), isEmpty);
    });

    test('preserves word-break and other existing inline styles', () async {
      final doc = await run(
        '<table><tr><td style="word-break: break-word; padding: 20px;">text</td></tr></table>',
      );
      final style = doc.querySelector('td')!.attributes['style']!;
      expect(style, contains('word-break: break-word'));
      expect(style, contains('padding: 20px'));
      expect(style, contains('overflow-wrap: anywhere'));
    });

    test('is idempotent — running twice does not duplicate overflow-wrap', () async {
      final doc = parse('<table><tr><td>text</td></tr></table>');
      await transformer.process(document: doc, dioClient: dioClient);
      await transformer.process(document: doc, dioClient: dioClient);
      final style = doc.querySelector('td')!.attributes['style']!;
      expect(
        'overflow-wrap'.allMatches(style).length,
        1,
        reason: 'overflow-wrap must appear exactly once even after multiple passes',
      );
    });

    test('does not add overflow-wrap to non-table elements', () async {
      final doc = await run('<div style="color: red"><p>text</p><span>more</span></div>');
      for (final el in doc.querySelectorAll('div, p, span')) {
        expect(
          el.attributes['style'] ?? '',
          isNot(contains('overflow-wrap')),
          reason: 'Only td/th must be modified — not div, p, or span',
        );
      }
    });

    test('processes all td and th elements in nested tables', () async {
      final doc = await run('''
        <table>
          <tr><td>outer
            <table>
              <tr><th>inner header</th><td>inner cell</td></tr>
            </table>
          </td></tr>
        </table>
      ''');
      for (final cell in doc.querySelectorAll('td, th')) {
        expect(
          cell.attributes['style'],
          contains('overflow-wrap: anywhere'),
          reason: 'Every td/th in nested tables must have overflow-wrap: anywhere',
        );
      }
    });
  });
}
