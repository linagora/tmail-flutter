@TestOn('chrome')

import 'package:flutter_test/flutter_test.dart';

import 'mobile_email_responsive_layout_fixture.dart';

void main() {
  group('Email HTML document layout', () {
    test('nested quote toggle hides then reveals inner quotes', () async {
      const fixture = EmailFixture(
        '<blockquote id="outer"><p>outer</p>'
        '<blockquote id="middle"><p>middle</p>'
        '<blockquote id="inner"><p>inner</p></blockquote>'
        '</blockquote></blockquote>',
        quoteToggle: true,
      );

      await withEmail(fixture, (viewport) async {
        expect(viewport.isQuoteVisible, isFalse);
        await viewport.expandQuote();
        expect(viewport.isQuoteVisible, isTrue);
        expect(viewport.element('#inner').textContent, contains('inner'));
      });
    });

    test('wide pre does not overflow a 360px viewport', () async {
      const fixture = EmailFixture(
        '<pre id="wide">https://example.com/very/long/path/that/should/not/'
        'overflow/abcdefghijklmnopqrstuvwxyz0123456789</pre>',
      );

      await withEmail(fixture, (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        final pre = viewport.element('#wide');
        expect(pre.scrollWidth <= pre.clientWidth + 1, isTrue);
      });
    });

    test('simple table stays within 360px', () async {
      const fixture = EmailFixture(
        '<table style="width:100%"><tr>'
        '<td id="cell">https://example.com/a-reasonably-long-cell-value</td>'
        '</tr></table>',
      );

      await withEmail(fixture, (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(
          viewport.element('#cell').scrollWidth <=
              viewport.element('#cell').clientWidth + 1,
          isTrue,
        );
      });
    });
  });
}
