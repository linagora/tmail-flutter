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

    test('Should remove line-height regardless of property casing', () async {
      for (final property in ['LINE-HEIGHT', 'Line-Height', 'lInE-hEiGhT']) {
        final doc = await run('<p style="$property:1px; color:red;">Hi</p>');
        expect(doc.querySelector('p')!.attributes['style'], 'color:red;');
      }
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

    test('Should remove small unitless line-height values', () async {
      for (final value in ['0.1', '0.9']) {
        final doc = await run('<p style="line-height:$value;">Hi</p>');
        expect(
          doc.querySelector('p')!.attributes.containsKey('style'),
          isFalse,
        );
      }
    });

    test(
      'Should keep normal unitless and relative line-height values',
      () async {
        for (final value in ['1', '1.5', '1.2em', '2em', '1.2rem']) {
          final doc = await run('<p style="line-height:$value;">Hi</p>');
          expect(
            doc.querySelector('p')!.attributes['style'],
            'line-height:$value;',
          );
        }
      },
    );

    test('Should remove small percentage line-height values', () async {
      for (final value in ['10%', '50%', '100%']) {
        final doc = await run('<p style="line-height:$value;">Hi</p>');
        expect(
          doc.querySelector('p')!.attributes.containsKey('style'),
          isFalse,
        );
      }

      final doc = await run('<p style="line-height:150%;">Hi</p>');
      expect(doc.querySelector('p')!.attributes['style'], 'line-height:150%;');
    });

    test(
      'Should remove small absolute line-height values and keep larger ones',
      () async {
        for (final value in ['1px', '1pt']) {
          final doc = await run('<p style="line-height:$value;">Hi</p>');
          expect(
            doc.querySelector('p')!.attributes.containsKey('style'),
            isFalse,
          );
        }

        for (final value in ['2px', '14px', '2pt']) {
          final doc = await run('<p style="line-height:$value;">Hi</p>');
          expect(
            doc.querySelector('p')!.attributes['style'],
            'line-height:$value;',
          );
        }
      },
    );

    test('Should enforce exact line-height removal boundaries', () async {
      for (final value in ['.99', '+0.1', '0.99em', '1.0px', '0.5pt']) {
        final doc = await run('<p style="line-height:$value;">Hi</p>');
        expect(
          doc.querySelector('p')!.attributes.containsKey('style'),
          isFalse,
          reason: 'Expected line-height $value to be removed',
        );
      }

      for (final value in [
        '1',
        '1.0',
        '1.01',
        '1.0em',
        '1.01px',
        '2pt',
        '100.01%',
        '-0.1',
        '1e-1',
        // Zero is the intentional image-gap/spacer trick — preserved in any unit.
        '0',
        '0.0',
        '0px',
        '0em',
        '0%',
      ]) {
        final doc = await run('<p style="line-height:$value;">Hi</p>');
        expect(
          doc.querySelector('p')!.attributes['style'],
          'line-height:$value;',
          reason: 'Expected line-height $value to be preserved',
        );
      }
    });

    test(
      'Should preserve keywords, invalid values, and unrelated styles',
      () async {
        for (final value in ['normal', 'auto', 'inherit', 'calc(1em + 2px)']) {
          final doc = await run(
            '<p style="color:red; line-height:$value; font-size:14px;">Hi</p>',
          );
          expect(
            doc.querySelector('p')!.attributes['style'],
            'color:red; line-height:$value; font-size:14px;',
          );
        }
      },
    );

    test('Should remove a degenerate line-height with !important', () async {
      final doc = await run(
        '<p style="color:red; line-height:0.1 !important; font-size:14px;">Hi</p>',
      );
      expect(
        doc.querySelector('p')!.attributes['style'],
        'color:red; font-size:14px;',
      );
    });

    test('Should remove degenerate line-height with spaced !important',
        () async {
      // Arbitrary whitespace around !important is valid CSS and must not defeat
      // removal (incl. > any fixed bound, and a space after `!`).
      for (final value in [
        '0.1 !important',
        '0.1 ! important',
        '0.1${' ' * 20}!important',
      ]) {
        final doc = await run('<p style="line-height:$value; color:red;">Hi</p>');
        final style = doc.querySelector('p')!.attributes['style']!;
        expect(style, isNot(contains('line-height')), reason: 'value: $value');
        expect(style, contains('color:red'));
      }
    });

    test('Should handle uppercase !IMPORTANT and mixed whitespace', () async {
      final doc = await run('''
        <p style="color:red;\n  LiNe-HeIgHt:\t0.5EM !IMPORTANT;\n font-size:14px">Hi</p>
      ''');
      final style = doc.querySelector('p')!.attributes['style']!;
      expect(style.toLowerCase(), isNot(contains('line-height')));
      expect(style, contains('color:red;'));
      expect(style, contains('font-size:14px'));
    });

    test('Should not modify custom properties or quoted CSS values', () async {
      final customPropertyDoc = await run(
        '<p style="--line-height:0.1; color:red;">Hi</p>',
      );
      expect(
        customPropertyDoc.querySelector('p')!.attributes['style'],
        '--line-height:0.1; color:red;',
      );

      final quotedValueDoc = await run(
        '<p style=\'line-height:1.5; content:"line-height:0.1;";\'>Hi</p>',
      );
      expect(
        quotedValueDoc.querySelector('p')!.attributes['style'],
        'line-height:1.5; content:"line-height:0.1;";',
      );
    });

    test('Should not touch ";line-height:" embedded in a quoted value',
        () async {
      // The semicolons are inside a quoted value, so they are not top-level
      // declaration boundaries and the property is left intact.
      const style = '--payload:"x; line-height:0.1; y"; color:red;';
      final doc = await run("<p style='$style'>Hi</p>");
      expect(doc.querySelector('p')!.attributes['style'], style);
    });

    test('Should not touch ";line-height:" inside a single-quoted value',
        () async {
      // Semicolons inside a single-quoted value are not top-level boundaries.
      final doc = await run(
        '<p style="content:\'a; line-height:0.1; b\'; color:red;">Hi</p>',
      );
      expect(
        doc.querySelector('p')!.attributes['style'],
        "content:'a; line-height:0.1; b'; color:red;",
      );
    });

    test('Should not split on an escaped semicolon', () async {
      // `\;` is escaped data, not a boundary, so the trailing line-height:0.1 is
      // part of the --payload value and must be preserved.
      const style = '--payload:x\\;line-height:0.1; color:red;';
      final doc = await run("<p style='$style'>Hi</p>");
      expect(doc.querySelector('p')!.attributes['style'], style);
    });

    test('Should keep malformed CSS unchanged (fail-open)', () async {
      for (final style in [
        'line-height:0.1; content:"unclosed', // unterminated quote
        'line-height:0.1; /* unclosed comment', // unterminated comment
        'line-height:0.1 /*/', // unterminated comment (/*/)
        'line-height:0.1); color:red', // unbalanced parenthesis
        'line-height:0.1 \\', // trailing backslash
      ]) {
        final doc = await run("<p style='$style'>Hi</p>");
        expect(doc.querySelector('p')!.attributes['style'], style);
      }
    });

    test(
      'Should preserve unrelated whitespace when line-height is kept',
      () async {
        const style = 'line-height:1.5; font-family:"A  B"; content:"x  y";';
        final doc = await run("<p style='$style'>Hi</p>");
        expect(doc.querySelector('p')!.attributes['style'], style);
      },
    );

    test('Should not split on semicolons inside a CSS function value', () async {
      final doc = await run(
        '<p style=\'background-image:url("data:image/svg+xml;a;b"); line-height:0.1; color:red;\'>Hi</p>',
      );
      expect(
        doc.querySelector('p')!.attributes['style'],
        'background-image:url("data:image/svg+xml;a;b"); color:red;',
      );
    });

    test('Should respect escaped quotes while removing line-height', () async {
      final doc = await run(
        r'''<p style='content:"a\";b"; line-height:0.1; color:red;'>Hi</p>''',
      );
      expect(
        doc.querySelector('p')!.attributes['style'],
        r'''content:"a\";b"; color:red;''',
      );
    });

    test(
      'Should fix a multi-line signature without removing inline styles',
      () async {
        final doc = await run('''
          <div>
            <p style="color:#333; font-size:14px; line-height:0.1;">Name</p>
            <p style="color:#333; font-size:12px; line-height:0.1;">Role</p>
          </div>
        ''');

        final paragraphs = doc.querySelectorAll('p');
        expect(paragraphs, hasLength(2));
        for (final paragraph in paragraphs) {
          final style = paragraph.attributes['style']!;
          expect(style, isNot(contains('line-height')));
          expect(style, contains('color:#333'));
          expect(style, contains('font-size:'));
        }
      },
    );

    test(
      'Should removes style attribute if only line-height existed',
      () async {
        final doc = await run('<div style="line-height:1px;"></div>');
        expect(
          doc.querySelector('div')!.attributes.containsKey('style'),
          isFalse,
        );
      },
    );

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

    test('Should remove back-to-back degenerate line-heights', () async {
      // The boundary between them must survive removal of the first.
      final doc = await run(
        '<p style="line-height:0.1;line-height:0.2;color:blue;"></p>',
      );
      expect(doc.querySelector('p')!.attributes['style'], 'color:blue;');
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
