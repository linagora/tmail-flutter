import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // These tests guard against the infinite-resize loop triggered by emails that
  // include `html, body { height: 100% !important }` in their CSS.  When that
  // rule is active, document.body.scrollHeight equals the iframe's current
  // height, so every postMessage adds offsetBuffer and grows the iframe again.
  // shouldUpdateHeight must return false in the stabilized state to break the
  // loop at the Dart layer.
  group('HtmlContentViewerOnWeb.shouldUpdateHeight', () {
    const offset = 30.0;
    const minH = 200.0;

    // ── loop-guard cases ──────────────────────────────────────────────────────

    test('returns false when height is already stable', () {
      // scrollHeight = 3000, current = 3030 (3000 + 30 offset already baked in)
      // This is exactly the stabilized state produced by the feedback loop.
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 3000,
          currentActualHeight: 3030,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: false,
        ),
        isFalse,
      );
    });

    test('returns false when stable at a different size', () {
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 500,
          currentActualHeight: 530,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: false,
        ),
        isFalse,
      );
    });

    // ── legitimate first-load case ────────────────────────────────────────────

    test('returns true for initial render when content exceeds initial height', () {
      // Widget starts at heightContent=200, real content is 3000 px.
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 3000,
          currentActualHeight: 200,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: false,
        ),
        isTrue,
      );
    });

    // ── legitimate dynamic-resize cases ──────────────────────────────────────

    test('returns true when content genuinely grows (e.g. quote expanded)', () {
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 5000,
          currentActualHeight: 3030,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: false,
        ),
        isTrue,
      );
    });

    test('returns true when content shrinks (e.g. quote collapsed)', () {
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 2000,
          currentActualHeight: 5030,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: false,
        ),
        isTrue,
      );
    });

    // ── minHeight boundary cases ──────────────────────────────────────────────

    test('returns false when autoAdjust=false and withBuffer does not exceed minHeight', () {
      // 100 + 30 = 130 which is not > 200
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 100,
          currentActualHeight: 130,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: false,
        ),
        isFalse,
      );
    });

    test('returns true when autoAdjust=false and withBuffer exceeds minHeight', () {
      // 210 + 30 = 240 > 200
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 210,
          currentActualHeight: 200,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: false,
        ),
        isTrue,
      );
    });

    test('returns true when autoAdjust=true and withBuffer meets minHeight', () {
      // 170 + 30 = 200 >= 200
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 170,
          currentActualHeight: 150,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: true,
        ),
        isTrue,
      );
    });

    test('returns false when autoAdjust=true and withBuffer is below minHeight', () {
      // 100 + 30 = 130 < 200
      expect(
        HtmlContentViewerOnWeb.shouldUpdateHeight(
          reportedScrollHeight: 100,
          currentActualHeight: 90,
          minHeight: minH,
          offsetBuffer: offset,
          autoAdjust: true,
        ),
        isFalse,
      );
    });
  });
}
