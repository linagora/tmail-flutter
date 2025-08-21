import 'package:core/presentation/utils/html_transformer/dom/normalize_line_height_in_style_transformer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:mockito/annotations.dart';

import 'normalize_line_height_in_style_transformer_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DioClient>()])
void main() {
  group('NormalizeLineHeightInStyleTransformer', () {
    const transformer = NormalizeLineHeightInStyleTransformer();
    final dioClient = MockDioClient();

    Future<Document> run(String html) async {
      final doc = parse(html);
      await transformer.process(document: doc, dioClient: dioClient);
      return doc;
    }

    test('Should removes line-height:1px', () async {
      final doc = await run('<p style="color:red; line-height:1px;">Hello</p>');
      expect(doc.querySelector('p')!.attributes['style'], 'color:red;');
    });

    test('Should removes line-height:100%', () async {
      final doc = await run(
        '<p style="line-height:100%; font-size:14px;">Hi</p>',
      );
      expect(doc.querySelector('p')!.attributes['style'], 'font-size:14px;');
    });

    test('Should keeps other line-height values', () async {
      final doc = await run(
        '<p style="line-height:150%; font-weight:bold;">Hi</p>',
      );
      expect(
        doc.querySelector('p')!.attributes['style'],
        'line-height:150%; font-weight:bold;',
      );
    });

    test('Should removes style attribute if only line-height existed',
        () async {
      final doc = await run('<div style="line-height:1px;"></div>');
      expect(
        doc.querySelector('div')!.attributes.containsKey('style'),
        isFalse,
      );
    });

    test('Should handles missing style gracefully', () async {
      final doc = await run('<span>No style here</span>');
      expect(
        doc.querySelector('span')!.attributes.containsKey('style'),
        isFalse,
      );
    });

    test('Should removes multiple unwanted line-heights', () async {
      final doc = await run(
        '<p style="line-height:1px; color:blue; line-height:100%; font-size:12px;"></p>',
      );
      expect(
        doc.querySelector('p')!.attributes['style'],
        'color:blue; font-size:12px;',
      );
    });

    test('Should removes line-height even with irregular spacing', () async {
      final doc = await run(
        '<p style="line-height :   1px ; color: green;"></p>',
      );
      expect(doc.querySelector('p')!.attributes['style'], 'color: green;');
    });

    test('Should keep line-height:auto', () async {
      final doc = await run(
        '<p style="line-height:auto; font-size:16px;"></p>',
      );
      expect(
        doc.querySelector('p')!.attributes['style'],
        'line-height:auto; font-size:16px;',
      );
    });

    test('Should not touch unrelated CSS properties', () async {
      final doc = await run(
        '<p style="margin:0; padding:5px;"></p>',
      );
      expect(
        doc.querySelector('p')!.attributes['style'],
        'margin:0; padding:5px;',
      );
    });

    test('Should trim trailing semicolon after removal', () async {
      final doc = await run(
        '<p style="line-height:1px;"></p>',
      );
      expect(
        doc.querySelector('p')!.attributes.containsKey('style'),
        isFalse,
      );
    });
  });
}
