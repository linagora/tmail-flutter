import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Guards against the infinite-resize loop: emails with `html, body { height: 100% }`
  // make scrollHeight equal the iframe height, so every update grows it forever.
  group('HtmlContentViewerOnWeb.shouldUpdateHeight', () {
    const offset = 30.0;
    const minH = 200.0;

    bool check({
      required double reported,
      required double current,
      bool autoAdjust = false,
    }) => HtmlContentViewerOnWeb.shouldUpdateHeight(
      scrollHeightWithBuffer: reported + offset,
      currentActualHeight: current,
      minHeight: minH,
      autoAdjust: autoAdjust,
    );

    test('returns false when height is already stable', () {
      // reported=3000, withBuffer=3030 == current=3030 → idempotent, stop loop
      expect(check(reported: 3000, current: 3030), isFalse);
    });

    test('returns false when stable at a different size', () {
      expect(check(reported: 500, current: 530), isFalse);
    });

    test('returns true for initial render when content exceeds initial height', () {
      // Widget starts at heightContent=200, real content is 3000 px.
      expect(check(reported: 3000, current: 200), isTrue);
    });

    test('returns true when content genuinely grows (e.g. quote expanded)', () {
      expect(check(reported: 5000, current: 3030), isTrue);
    });

    test('returns true when content shrinks (e.g. quote collapsed)', () {
      expect(check(reported: 2000, current: 5030), isTrue);
    });

    test('returns false when autoAdjust=false and withBuffer does not exceed minHeight', () {
      // 100 + 30 = 130, not > 200 (minHeight)
      expect(check(reported: 100, current: 200), isFalse);
    });

    test('returns false when autoAdjust=false and withBuffer exactly equals minHeight', () {
      // 170 + 30 = 200, not > 200 — strict greater-than boundary
      expect(check(reported: 170, current: 150), isFalse);
    });

    test('returns true when autoAdjust=false and withBuffer exceeds minHeight', () {
      // 210 + 30 = 240 > 200
      expect(check(reported: 210, current: 200), isTrue);
    });

    test('returns true when autoAdjust=true and withBuffer meets minHeight', () {
      // 170 + 30 = 200 >= 200
      expect(check(reported: 170, current: 150, autoAdjust: true), isTrue);
    });

    test('returns false when autoAdjust=true and withBuffer is below minHeight', () {
      // 100 + 30 = 130 < 200
      expect(check(reported: 100, current: 90, autoAdjust: true), isFalse);
    });

    test('dedup alone CANNOT stop the loop — CSS override is load-bearing', () {
      double iframe = 200;
      const buffer = 30.0;
      final history = <double>{iframe};

      for (var i = 0; i < 10; i++) {
        final scrollHeight = iframe; // body fills iframe — the bug condition
        final reported = scrollHeight + buffer;
        if (HtmlContentViewerOnWeb.shouldUpdateHeight(
          scrollHeightWithBuffer: reported,
          currentActualHeight: iframe,
          minHeight: 200,
          autoAdjust: false,
        )) {
          iframe = reported;
          history.add(iframe);
        }
      }

      expect(history.length, greaterThan(5),
          reason: 'Dart dedup does not catch the buffer-delta loop; '
              'the CSS override in generateHtmlDocument is the actual fix.');
    });
  });
}
