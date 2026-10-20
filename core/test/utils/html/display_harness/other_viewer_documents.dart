import 'dart:async';

import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_configuration.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:core/utils/print_utils.dart';
import 'package:flutter/widgets.dart';

/// Documents of the viewers other than the Email View: each mirrors the
/// options its widget passes (`HtmlAttachmentPreviewer`,
/// `EventBodyContentWidget`, `SignatureBuilder`, `PrintUtils.printEmail`).

HtmlContentViewerViewport _viewport(int width) => HtmlContentViewerViewport(
      constraints: BoxConstraints.tightFor(width: width.toDouble()),
    );

String attachmentDocument(String content, int width, TextDirection? direction) =>
    HtmlViewerDocumentBuilder.buildNativeDocument(
      configuration: HtmlContentViewerConfiguration(
        content: HtmlContentViewerContent(html: content, direction: direction),
        layout: HtmlContentViewerLayout(viewport: _viewport(width)),
        behavior: HtmlContentViewerBehavior(
          features: {HtmlContentViewerFeature.keepWidthWhileLoading},
        ),
      ),
      platform: HtmlContentViewerPlatform.mobile,
      isAndroid: false,
    );

String calendarNativeDocument(
  String content,
  int width,
  TextDirection? direction,
) =>
    HtmlViewerDocumentBuilder.buildNativeDocument(
      configuration: HtmlContentViewerConfiguration(
        content: HtmlContentViewerContent(html: content, direction: direction),
        layout: HtmlContentViewerLayout(viewport: _viewport(width)),
        typography: const HtmlContentViewerTypography(
          fontStyle: HtmlContentViewerFontStyle.defaultStyle,
        ),
      ),
      platform: HtmlContentViewerPlatform.mobile,
      isAndroid: false,
    );

String calendarWebDocument(
  String content,
  int width,
  TextDirection? direction,
) =>
    HtmlViewerDocumentBuilder.buildWebDocument(
      HtmlWebViewerDocumentInput(
        content: content,
        viewId: 'displayHarnessCalendar',
        widthContent: width.toDouble(),
        minHeight: ConstantsUI.htmlContentMinHeight,
        minWidth: ConstantsUI.htmlContentMinWidth,
        direction: direction,
        useDefaultFontStyle: true,
        hasScrollController: true,
        useLinkTooltipOverlay: true,
        isWebDesktop: true,
      ),
    );

/// Mobile passes `width: double.infinity` (`identity_list_tile_builder.dart`),
/// so the viewport has no width and no image-normalize script; the iframe
/// still lays out at [width].
String signatureNativeDocument(
  String content,
  int width,
  TextDirection? direction,
) =>
    HtmlViewerDocumentBuilder.buildNativeDocument(
      configuration: HtmlContentViewerConfiguration(
        content: HtmlContentViewerContent(html: content, direction: direction),
        layout: const HtmlContentViewerLayout(
          viewport: HtmlContentViewerViewport(
            constraints: BoxConstraints.tightFor(width: double.infinity),
          ),
          contentPadding: HtmlContentViewerLength(0),
        ),
        behavior: HtmlContentViewerBehavior(
          features: {
            HtmlContentViewerFeature.keepAlive,
            HtmlContentViewerFeature.disableScrolling,
          },
        ),
      ),
      platform: HtmlContentViewerPlatform.mobile,
      isAndroid: false,
    );

String signatureWebDocument(
  String content,
  int width,
  TextDirection? direction,
) =>
    HtmlViewerDocumentBuilder.buildWebDocument(
      HtmlWebViewerDocumentInput(
        content: content,
        viewId: 'displayHarnessSignature',
        widthContent: width.toDouble(),
        minHeight: 0,
        minWidth: width.toDouble(),
        direction: direction,
        contentPadding: 0,
        disableScrolling: true,
        autoAdjustHeight: true,
        isWebDesktop: true,
      ),
    );

/// The document `PrintUtils.printEmail` opens, without its `window.print()`
/// trigger so the test page is not blocked. The `tmail-content` div only
/// marks the body for the frame; no print CSS targets it.
String printDocument(String content, int width, TextDirection? direction) {
  String? printed;
  unawaited(
    PrintUtils(openHtmlDocument: (html) => printed = html).printEmail(
      appName: 'Twake Mail',
      userName: 'user@example.com',
      subject: 'Subject',
      emailContent:
          '<div class="tmail-content"${direction == TextDirection.rtl ? ' dir="rtl"' : ''}>$content</div>',
      senderName: 'Sender',
      senderEmailAddress: 'sender@example.com',
      dateTime: 'today',
      fromPrefix: 'From',
      toPrefix: 'To',
      ccPrefix: 'Cc',
      bccPrefix: 'Bcc',
      replyToPrefix: 'Reply to',
      titleAttachment: 'attachments',
    ),
  );
  final html = printed;
  if (html == null) {
    throw StateError('PrintUtils.printEmail no longer builds the document synchronously');
  }
  const trigger = 'window.print();';
  if (!html.contains(trigger)) throw StateError('print trigger not found');
  return html.replaceFirst(trigger, '');
}
