import 'package:core/presentation/views/html_viewer/html_iframe_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlIframeWidget.sandboxPolicy', () {
    final tokens = HtmlIframeWidget.sandboxPolicy.split(' ');

    test('SHOULD allow scripts and popups for the viewer bridge and links', () {
      expect(tokens, containsAll([
        'allow-scripts',
        'allow-popups',
        'allow-popups-to-escape-sandbox',
      ]));
    });

    test('SHOULD NOT grant same-origin access to the app', () {
      expect(tokens, isNot(contains('allow-same-origin')));
    });

    test('SHOULD NOT let the mail navigate the app window', () {
      expect(
        tokens.where((token) => token.startsWith('allow-top-navigation')),
        isEmpty,
      );
    });
  });
}
