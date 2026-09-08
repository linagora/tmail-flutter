import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  group('HtmlContentViewer', () {
    test('applies the mobile responsive layout only for an opted-in native email view', () {
      const viewer = HtmlContentViewer(
        configuration: HtmlContentViewerConfiguration(
          content: HtmlContentViewerContent(html: ''),
        ),
      );

      expect(
        HtmlContentViewer.shouldApplyMobileResponsiveLayout(
          viewer.configuration,
          HtmlContentViewerPlatform.mobile,
        ),
        isFalse,
      );
      expect(
        HtmlContentViewer.shouldApplyMobileResponsiveLayout(
          _mobileResponsiveConfiguration(),
          HtmlContentViewerPlatform.mobile,
        ),
        isTrue,
      );
    });

    test('does not apply the mobile responsive layout without a native platform', () {
      expect(
        HtmlContentViewer.shouldApplyMobileResponsiveLayout(
          _mobileResponsiveConfiguration(),
          HtmlContentViewerPlatform.desktop,
        ),
        isFalse,
      );
    });

    test('does not apply the mobile responsive layout without a view width', () {
      expect(
        HtmlContentViewer.shouldApplyMobileResponsiveLayout(
          HtmlContentViewerConfiguration(
            content: const HtmlContentViewerContent(html: ''),
            behavior: HtmlContentViewerBehavior(features: {
              HtmlContentViewerFeature.mobileResponsiveLayout,
            }),
          ),
          HtmlContentViewerPlatform.mobile,
        ),
        isFalse,
      );
    });

    test('does not apply the mobile responsive layout when scrolling is disabled', () {
      expect(
        HtmlContentViewer.shouldApplyMobileResponsiveLayout(
          HtmlContentViewerConfiguration(
            content: const HtmlContentViewerContent(html: ''),
            layout: const HtmlContentViewerLayout(
              viewport: HtmlContentViewerViewport(
                constraints: BoxConstraints.tightFor(width: 360),
              ),
            ),
            behavior: HtmlContentViewerBehavior(features: {
              HtmlContentViewerFeature.mobileResponsiveLayout,
              HtmlContentViewerFeature.disableScrolling,
            }),
          ),
          HtmlContentViewerPlatform.mobile,
        ),
        isFalse,
      );
    });
  });

  group('HtmlContentViewerConfiguration', () {
    test('keeps the default height and typography values', () {
      const configuration = HtmlContentViewerConfiguration(
        content: HtmlContentViewerContent(html: ''),
      );

      expect(
        configuration.layout.height.minContentHeight,
        ConstantsUI.htmlContentMinHeight,
      );
      expect(configuration.layout.height.maxContentHeight, isNull);
      expect(configuration.typography.fontSize, 16);
    });

    test('maps bounded viewport and content height constraints', () {
      const configuration = HtmlContentViewerConfiguration(
        content: HtmlContentViewerContent(html: ''),
        layout: HtmlContentViewerLayout(
          viewport: HtmlContentViewerViewport(
            constraints: BoxConstraints.tightFor(width: 360),
          ),
          height: HtmlContentViewerHeightConfiguration(
            contentConstraints: BoxConstraints(
              minHeight: 20,
              maxHeight: 400,
            ),
          ),
        ),
      );

      expect(configuration.layout.viewport.width, 360);
      expect(configuration.layout.height.minContentHeight, 20);
      expect(configuration.layout.height.maxContentHeight, 400);
    });

    test('keeps the view height cap, offset and requested text size', () {
      const configuration = HtmlContentViewerConfiguration(
        content: HtmlContentViewerContent(html: ''),
        layout: HtmlContentViewerLayout(
          height: HtmlContentViewerHeightConfiguration(
            viewConstraints: BoxConstraints(maxHeight: 300),
            offset: HtmlContentViewerLength(12),
          ),
        ),
        typography: HtmlContentViewerTypography(
          textSize: HtmlContentViewerLength(14),
        ),
      );

      expect(configuration.layout.height.maxViewHeight, 300);
      expect(configuration.layout.height.offset.value, 12);
      expect(configuration.typography.fontSize, 14);
    });

    test('copies behavior features to prevent later external mutation', () {
      final features = {HtmlContentViewerFeature.keepWidthWhileLoading};
      final behavior = HtmlContentViewerBehavior(features: features);
      features.add(HtmlContentViewerFeature.keepAlive);

      expect(
        behavior.has(HtmlContentViewerFeature.keepWidthWhileLoading),
        isTrue,
      );
      expect(behavior.has(HtmlContentViewerFeature.keepAlive), isFalse);
    });
  });
}

HtmlContentViewerConfiguration _mobileResponsiveConfiguration() {
  return HtmlContentViewerConfiguration(
    content: const HtmlContentViewerContent(html: ''),
    layout: const HtmlContentViewerLayout(
      viewport: HtmlContentViewerViewport(
        constraints: BoxConstraints.tightFor(width: 360),
      ),
    ),
    behavior: HtmlContentViewerBehavior(features: {
      HtmlContentViewerFeature.mobileResponsiveLayout,
    }),
  );
}
