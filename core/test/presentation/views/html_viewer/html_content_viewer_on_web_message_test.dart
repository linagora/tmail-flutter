import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlContentViewerOnWeb.isMessageForView', () {
    test('accepts the matching view id', () {
      expect(
        HtmlContentViewerOnWeb.isMessageForView(
          messageViewId: 'view-1',
          createdViewId: 'view-1',
        ),
        isTrue,
      );
    });

    test('ignores a message for another view', () {
      expect(
        HtmlContentViewerOnWeb.isMessageForView(
          messageViewId: 'other',
          createdViewId: 'view-1',
        ),
        isFalse,
      );
    });
  });
}
