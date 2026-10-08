import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_configuration.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:flutter/widgets.dart';

/// The email viewers rendered by the display rule tests, each with the email
/// pane widths it is shown at and the options its Email View call site uses.
enum DisplayViewer {
  /// `HtmlContentViewer` on Android/iOS phones and tablets, with the mobile
  /// responsive layout script.
  native('native', [296, 336, 390, 744]),

  /// `HtmlContentViewerOnWeb` at the web email pane widths.
  web('web', [524, 760, 1000]),

  /// `IosHtmlContentViewerWidget` (EML previewer, composer fullscreen). It has
  /// no responsive script and no quote toggle, so only generic rules apply.
  ios('ios', [296, 336, 390]);

  const DisplayViewer(this.label, this.widths);

  final String label;

  /// Visible email pane widths: what the webview/iframe is laid out at.
  final List<int> widths;

  /// Horizontal `Padding` the Email View puts around the viewer
  /// (`EmailViewStyles.mobileEmailContentPadding` 12+12,
  /// `emailContentPadding` 16+16). The app hands the viewer the full body
  /// width, so its scripts get `pane + padding` while it renders at `pane`.
  int get horizontalPadding => switch (this) {
        DisplayViewer.native => 24,
        DisplayViewer.web => 32,
        DisplayViewer.ios => 0,
      };

  /// Width the app passes to the viewer (`bodyConstraints.maxWidth`).
  int appWidth(int paneWidth) => paneWidth + horizontalPadding;

  /// Below 600 logical px of device width the app uses its mobile layout
  /// (16px text, touch on web). The device width is taken as the body width.
  bool isMobileDevice(int paneWidth) => appWidth(paneWidth) < 600;

  bool get genericRulesOnly => this == DisplayViewer.ios;

  bool get hasQuoteToggle => this != DisplayViewer.ios;

  /// The HTML pipeline the app runs before this viewer; plain-text bodies go
  /// through [TransformConfiguration.forPlainTextEmail] on every viewer.
  TransformConfiguration transformConfiguration() => switch (this) {
        DisplayViewer.web => TransformConfiguration.forPreviewEmailOnWeb(),
        DisplayViewer.native || DisplayViewer.ios =>
          TransformConfiguration.forPreviewEmail(),
      };

  /// The exact document the viewer loads for [content] at pane [width].
  /// [quoteToggle] is only turned off by mutation tests.
  String buildDocument(
    String content,
    int width, {
    TextDirection? direction,
    bool quoteToggle = true,
  }) =>
      switch (this) {
        DisplayViewer.native => HtmlViewerDocumentBuilder.buildNativeDocument(
            configuration: _nativeEmailConfiguration(
              content,
              (width: appWidth(width), mobile: isMobileDevice(width), quoteToggle: quoteToggle),
              direction,
            ),
            platform: HtmlContentViewerPlatform.mobile,
            isAndroid: false,
          ),
        DisplayViewer.web => HtmlViewerDocumentBuilder.buildWebDocument(
            _webEmailInput(
              content,
              (width: appWidth(width), mobile: isMobileDevice(width), quoteToggle: quoteToggle),
              direction,
            ),
          ),
        DisplayViewer.ios => HtmlViewerDocumentBuilder.buildIosDocument(
            content: content,
            direction: direction,
          ),
      };
}

typedef _AppViewport = ({int width, bool mobile, bool quoteToggle});

/// Mirrors the native `HtmlContentViewer` options of the Email View.
HtmlContentViewerConfiguration _nativeEmailConfiguration(
  String content,
  _AppViewport viewport,
  TextDirection? direction,
) =>
    HtmlContentViewerConfiguration(
      content: HtmlContentViewerContent(html: content, direction: direction),
      layout: HtmlContentViewerLayout(
        viewport: HtmlContentViewerViewport(
          constraints: BoxConstraints.tightFor(width: viewport.width.toDouble()),
        ),
        contentPadding: const HtmlContentViewerLength(0),
      ),
      typography: HtmlContentViewerTypography(
        fontStyle: HtmlContentViewerFontStyle.defaultStyle,
        textSize: HtmlContentViewerLength(viewport.mobile ? 16 : 14),
      ),
      behavior: HtmlContentViewerBehavior(features: {
        HtmlContentViewerFeature.keepAlive,
        if (viewport.quoteToggle) HtmlContentViewerFeature.quoteToggle,
        HtmlContentViewerFeature.mobileResponsiveLayout,
      }),
    );

/// Mirrors the `HtmlContentViewerOnWeb` options of the Email View; a mobile
/// device gets the mobile-responsive (touch, 16px) web layout.
HtmlWebViewerDocumentInput _webEmailInput(
  String content,
  _AppViewport viewport,
  TextDirection? direction,
) {
  final isDesktop = !viewport.mobile;
  return HtmlWebViewerDocumentInput(
    content: content,
    viewId: 'displayHarnessView',
    widthContent: viewport.width.toDouble(),
    minHeight: ConstantsUI.htmlContentMinHeight,
    minWidth: ConstantsUI.htmlContentMinWidth,
    direction: direction,
    contentPadding: 0,
    useDefaultFontStyle: true,
    fontSize: isDesktop ? 14 : 16,
    enableQuoteToggle: viewport.quoteToggle,
    hasMailtoDelegate: true,
    hasScrollController: true,
    hasKeyboardShortcutAction: true,
    useLinkTooltipOverlay: true,
    isWebTouchDevice: !isDesktop,
    isWebDesktop: isDesktop,
  );
}
