import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/dom/remove_negative_margin_float_transformers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:mockito/annotations.dart';

import 'remove_negative_margin_float_transformer_test.mocks.dart';

void _verifyFloatPattern(RegExp pattern, String direction, String opposite) {
  expect(pattern.hasMatch('float: $direction;'), isTrue);
  expect(pattern.hasMatch('float:$direction'), isTrue);
  expect(pattern.hasMatch('float: $opposite;'), isFalse);
}

void _verifyNegativeMarginPattern(RegExp pattern, String side) {
  expect(pattern.hasMatch('margin-$side: -20px;'), isTrue);
  expect(pattern.hasMatch('margin-$side: -1em;'), isTrue);
  expect(pattern.hasMatch('margin-$side: 20px;'), isFalse);
  expect(pattern.hasMatch('margin-$side: 0px;'), isFalse);
}

@GenerateNiceMocks([MockSpec<DioClient>()])
void main() {
  group('RemoveNegativeMarginFloatTransformer', () {
    const transformer = RemoveNegativeMarginFloatTransformer();
    late MockDioClient dioClient;

    setUp(() {
      dioClient = MockDioClient();
    });

    Future<Document> run(String html) async {
      final doc = parse(html);
      await transformer.process(document: doc, dioClient: dioClient);
      return doc;
    }

    group('GitLab heading anchor pattern', () {
      test(
        'SHOULD remove float:left and negative margin-left from anchor element',
        () async {
          final doc = await run(
            '<h2>'
            '<a class="anchor" aria-hidden="true"'
            ' style="margin-top: 0; float: left; margin-left: -20px;'
            ' text-decoration: none;"></a>'
            'Heading text'
            '</h2>',
          );
          final anchor = doc.querySelector('a.anchor')!;
          final style = anchor.attributes['style'] ?? '';
          expect(style, isNot(contains('float')));
          expect(style, isNot(contains('margin-left: -20px')));
          expect(style, contains('margin-top: 0'));
          expect(style, contains('text-decoration: none'));
        },
      );

      test(
        'SHOULD remove float:right and negative margin-right from element',
        () async {
          final doc = await run(
            '<span style="float: right; margin-right: -15px; color: red;">x</span>',
          );
          final span = doc.querySelector('span')!;
          final style = span.attributes['style'] ?? '';
          expect(style, isNot(contains('float')));
          expect(style, isNot(contains('margin-right: -15px')));
          expect(style, contains('color: red'));
        },
      );

      test(
        'SHOULD remove style attribute entirely when only the problematic properties remain',
        () async {
          final doc = await run(
            '<a style="float: left; margin-left: -20px;"></a>',
          );
          final anchor = doc.querySelector('a')!;
          expect(anchor.attributes.containsKey('style'), isFalse);
        },
      );
    });

    group('Should NOT modify when pattern is not problematic', () {
      test('SHOULD keep float:left when margin-left is positive', () async {
        final doc = await run(
          '<img style="float: left; margin-left: 10px;" src="img.png">',
        );
        final img = doc.querySelector('img')!;
        final style = img.attributes['style'] ?? '';
        expect(style, contains('float: left'));
        expect(style, contains('margin-left: 10px'));
      });

      test('SHOULD keep float:left when margin-left is zero', () async {
        final doc = await run(
          '<img style="float: left; margin-left: 0px;" src="img.png">',
        );
        final img = doc.querySelector('img')!;
        final style = img.attributes['style'] ?? '';
        expect(style, contains('float: left'));
        expect(style, contains('margin-left: 0px'));
      });

      test('SHOULD keep negative margin-left when there is no float', () async {
        final doc = await run(
          '<p style="margin-left: -5px; color: blue;">text</p>',
        );
        final p = doc.querySelector('p')!;
        final style = p.attributes['style'] ?? '';
        expect(style, contains('margin-left: -5px'));
        expect(style, contains('color: blue'));
      });

      test(
        'SHOULD NOT remove float:left when negative margin is on opposite side (margin-right)',
        () async {
          final doc = await run(
            '<div style="float: left; margin-right: -10px;"></div>',
          );
          final div = doc.querySelector('div')!;
          final style = div.attributes['style'] ?? '';
          expect(style, contains('float: left'));
          expect(style, contains('margin-right: -10px'));
        },
      );

      test('SHOULD keep elements without style attribute unchanged', () async {
        final doc = await run('<p>No style here</p>');
        final p = doc.querySelector('p')!;
        expect(p.attributes.containsKey('style'), isFalse);
      });
    });

    group('Style cleanup', () {
      test('SHOULD collapse extra spaces after property removal', () async {
        final doc = await run(
          '<a style="color: red;  float: left;  margin-left: -20px;  font-size: 14px;"></a>',
        );
        final anchor = doc.querySelector('a')!;
        final style = anchor.attributes['style'] ?? '';
        expect(style, isNot(contains('  ')));
        expect(style, contains('color: red'));
        expect(style, contains('font-size: 14px'));
      });

      test('SHOULD handle irregular spacing in property values', () async {
        final doc = await run(
          '<a style="float :  left ; margin-left :  -20px ;"></a>',
        );
        final anchor = doc.querySelector('a')!;
        expect(anchor.attributes.containsKey('style'), isFalse);
      });
    });

    group('Multiple elements in document', () {
      test(
        'SHOULD fix all affected anchors in a multi-heading document',
        () async {
          const html = '''
<div>
  <h2><a class="anchor" style="float: left; margin-left: -20px;"></a>H2</h2>
  <h3><a class="anchor" style="float: left; margin-left: -20px;"></a>H3</h3>
  <p style="float: left; margin-left: 5px;">Normal float para</p>
</div>
''';
          final doc = await run(html);
          final anchors = doc.querySelectorAll('a.anchor');
          for (final anchor in anchors) {
            expect(anchor.attributes.containsKey('style'), isFalse);
          }
          final para = doc.querySelector('p')!;
          expect(para.attributes['style'], contains('float: left'));
          expect(para.attributes['style'], contains('margin-left: 5px'));
        },
      );
    });

    group('Case 2 — aria-hidden anchor with negative margin (post-sanitisation)', () {
      test(
        'SHOULD remove negative margin-left from aria-hidden anchor'
        ' even without float (post-sanitisation state)',
        () async {
          // Simulates what the element looks like after the CSS sanitiser
          // strips float:left — only the negative margin-left remains.
          final doc = await run(
            '<h2>'
            '<a aria-hidden="true" class="anchor"'
            ' style="margin-top: 0; margin-left: -20px; text-decoration: none;"></a>'
            'Heading text'
            '</h2>',
          );
          final anchor = doc.querySelector('a.anchor')!;
          final style = anchor.attributes['style'] ?? '';
          expect(style, isNot(contains('margin-left: -20px')),
              reason: 'negative margin-left must be removed from aria-hidden anchor');
          expect(style, contains('margin-top: 0'),
              reason: 'other style properties must be preserved');
          expect(style, contains('text-decoration: none'));
        },
      );

      test(
        'SHOULD remove negative margin-right from aria-hidden anchor',
        () async {
          final doc = await run(
            '<h3>'
            '<a aria-hidden="true"'
            ' style="margin-right: -20px; text-decoration: none;"></a>'
            'Heading 3'
            '</h3>',
          );
          final anchor = doc.querySelector('a')!;
          final style = anchor.attributes['style'] ?? '';
          expect(style, isNot(contains('margin-right: -20px')));
          expect(style, contains('text-decoration: none'));
        },
      );

      test(
        'SHOULD NOT remove negative margin-left from a regular (non-aria-hidden) anchor',
        () async {
          final doc = await run(
            '<a href="#section" style="margin-left: -5px; color: blue;">Back</a>',
          );
          final anchor = doc.querySelector('a')!;
          final style = anchor.attributes['style'] ?? '';
          expect(style, contains('margin-left: -5px'),
              reason: 'non-aria-hidden anchors must not be touched');
          expect(style, contains('color: blue'));
        },
      );

      test(
        'SHOULD fix all aria-hidden anchors across multiple headings',
        () async {
          final doc = await run(
            '<h2><a aria-hidden="true" style="margin-top: 0; margin-left: -20px;"></a>H2</h2>'
            '<h3><a aria-hidden="true" style="margin-top: 0; margin-left: -20px;"></a>H3</h3>'
            '<p><a href="#link" style="margin-left: -5px;">normal link</a></p>',
          );
          final headingAnchors = doc.querySelectorAll('a[aria-hidden="true"]');
          for (final anchor in headingAnchors) {
            final style = anchor.attributes['style'] ?? '';
            expect(style, isNot(contains('margin-left: -20px')));
          }
          final normalAnchor = doc.querySelector('a[href="#link"]')!;
          expect(normalAnchor.attributes['style'], contains('margin-left: -5px'),
              reason: 'non-aria-hidden anchor must not be modified');
        },
      );
    });

    group('Regex pattern verification', () {
      test('floatLeftPattern matches float:left variants', () {
        _verifyFloatPattern(
          RemoveNegativeMarginFloatTransformer.floatLeftPattern,
          'left', 'right',
        );
      });

      test('floatRightPattern matches float:right variants', () {
        _verifyFloatPattern(
          RemoveNegativeMarginFloatTransformer.floatRightPattern,
          'right', 'left',
        );
      });

      test('negativeMarginLeftPattern matches negative values only', () {
        _verifyNegativeMarginPattern(
          RemoveNegativeMarginFloatTransformer.negativeMarginLeftPattern,
          'left',
        );
      });

      test('negativeMarginRightPattern matches negative values only', () {
        _verifyNegativeMarginPattern(
          RemoveNegativeMarginFloatTransformer.negativeMarginRightPattern,
          'right',
        );
      });
    });
  });
}
