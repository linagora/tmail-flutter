import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_configuration.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:flutter/widgets.dart';

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import 'other_viewer_documents.dart';

/// The viewers rendered by the display rule tests, each with the pane widths
/// it is shown at and the options its call site uses.
enum DisplayViewer {
  /// `HtmlContentViewer` on Android/iOS phones and tablets, with the mobile
  /// responsive layout script.
  native('native', [296, 336, 390, 744]),

  /// `HtmlContentViewerOnWeb` at the web email pane widths.
  web('web', [524, 760, 1000]),

  /// `IosHtmlContentViewerWidget` (EML previewer, composer fullscreen). It has
  /// no responsive script and no quote toggle, so only generic rules apply.
  ios('ios', [296, 336, 390]),

  /// A cached draft opened in the native `HtmlContentViewer` (Email View,
  /// `forDraftsEmail`): the native options at the native pane widths.
  drafts('drafts', [296, 336, 390, 744]),

  /// `HtmlAttachmentPreviewer` native (`forAttachmentPreview`): the full
  /// width on a phone, 0.8 of a 768 tablet.
  attachment('attachment', [320, 360, 414, 614]),

  /// `EventBodyContentWidget` native (`forCalendarEvent`). The email body
  /// (320/360/414/768) minus 88: card margin 16+16, padding 16+16, inner 16+8.
  calendarNative('calendar-native', [232, 272, 326, 680]),

  /// `EventBodyContentWidget` web: the email body (556/792/1032) minus 92
  /// (the native 88 plus the web end padding 4).
  calendarWeb('calendar-web', [464, 700, 940]),

  /// `SignatureBuilder` native (`forSignatureIdentity`), phone width.
  signatureNative('signature-native', [296, 390]),

  /// `SignatureBuilder` web, desktop `width: 280`.
  signatureWeb('signature-web', [280]),

  /// The print document of `PrintUtils.printEmail` (`forPrintEmail`). The app
  /// sets no page width; A4 at 96 dpi.
  print('print', [794]);

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
        DisplayViewer.drafts => 24,
        _ => 0,
      };

  /// Width the app passes to the viewer (`bodyConstraints.maxWidth`).
  int appWidth(int paneWidth) => paneWidth + horizontalPadding;

  /// Below 600 logical px of device width the app uses its mobile layout
  /// (16px text, touch on web). The device width is taken as the body width.
  bool isMobileDevice(int paneWidth) => appWidth(paneWidth) < 600;

  bool get genericRulesOnly =>
      this != DisplayViewer.native && this != DisplayViewer.web;

  bool get hasQuoteToggle =>
      this == DisplayViewer.native ||
      this == DisplayViewer.web ||
      this == DisplayViewer.drafts;

  /// Print gets the reading-pane output (`emailLoaded.htmlContent`), not the
  /// raw email.
  TransformConfiguration? get upstreamConfiguration =>
      this == DisplayViewer.print
          ? TransformConfiguration.forPreviewEmailOnWeb()
          : null;

  /// Fixture categories shown on this viewer: signatures and calendar
  /// descriptions are not emails, so they get their own fixtures.
  bool shows(HtmlEmailCorpusFixture fixture) => switch (this) {
        DisplayViewer.signatureNative ||
        DisplayViewer.signatureWeb =>
          fixture.category == 'signatures',
        DisplayViewer.calendarNative ||
        DisplayViewer.calendarWeb =>
          fixture.category == 'calendar_descriptions',
        _ => fixture.category != 'signatures' &&
            fixture.category != 'calendar_descriptions',
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
        DisplayViewer.native ||
        DisplayViewer.drafts =>
          HtmlViewerDocumentBuilder.buildNativeDocument(
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
        DisplayViewer.attachment => attachmentDocument(content, width, direction),
        DisplayViewer.calendarNative =>
          calendarNativeDocument(content, width, direction),
        DisplayViewer.calendarWeb => calendarWebDocument(content, width, direction),
        DisplayViewer.signatureNative =>
          signatureNativeDocument(content, width, direction),
        DisplayViewer.signatureWeb => signatureWebDocument(content, width, direction),
        DisplayViewer.print => printDocument(content, width, direction),
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
