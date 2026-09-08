import 'package:core/presentation/constants/constants_ui.dart';
import 'package:flutter/material.dart';

enum HtmlContentViewerFeature {
  keepAlive,
  keepWidthWhileLoading,
  quoteToggle,
  disableScrolling,
  mobileResponsiveLayout,
}

enum HtmlContentViewerFontStyle {
  html,
  defaultStyle,
}

enum HtmlContentViewerPlatform {
  mobile,
  desktop,
}

enum HtmlContentViewerHorizontalDirection {
  left,
  right,
}

enum HtmlContentViewerWidthState {
  overflowed,
}

enum HtmlContentViewerContentClipping {
  clipped,
}

typedef OnScrollHorizontalEndAction = void Function(
  HtmlContentViewerHorizontalDirection direction,
);
typedef OnLoadWidthHtmlViewerAction = void Function(
  HtmlContentViewerWidthState state,
);
typedef OnMailtoDelegateAction = Future<void> Function(Uri? uri);
typedef OnPreviewEMLDelegateAction = Future<void> Function(Uri? uri);
typedef OnDownloadAttachmentDelegateAction = Future<void> Function(Uri? uri);
typedef OnHtmlContentClippedAction = void Function(
  HtmlContentViewerContentClipping clipping,
);

/// The HTML payload and its text direction are kept together because both
/// values are used to build the same document.
class HtmlContentViewerContent {

  final String html;
  final TextDirection? direction;

  const HtmlContentViewerContent({
    required this.html,
    this.direction,
  });
}

/// A semantic length avoids passing unrelated raw dimensions through the
/// viewer's public API.
class HtmlContentViewerLength {

  final double value;

  const HtmlContentViewerLength(this.value);
}

class HtmlContentViewerViewport {

  final BoxConstraints? constraints;

  const HtmlContentViewerViewport({this.constraints});

  double? get width => constraints?.hasBoundedWidth == true
      ? constraints!.maxWidth
      : null;
}

class HtmlContentViewerHeightConfiguration {

  final BoxConstraints contentConstraints;
  final BoxConstraints? viewConstraints;
  final HtmlContentViewerLength offset;

  const HtmlContentViewerHeightConfiguration({
    this.contentConstraints = const BoxConstraints(
      minHeight: ConstantsUI.htmlContentMinHeight,
    ),
    this.viewConstraints,
    this.offset = const HtmlContentViewerLength(
      ConstantsUI.htmlContentOffsetHeight,
    ),
  });

  double get minContentHeight => contentConstraints.minHeight;

  double? get maxContentHeight => contentConstraints.hasBoundedHeight
      ? contentConstraints.maxHeight
      : null;

  double? get maxViewHeight => viewConstraints?.hasBoundedHeight == true
      ? viewConstraints!.maxHeight
      : null;
}

class HtmlContentViewerLayout {

  final HtmlContentViewerViewport viewport;
  final HtmlContentViewerHeightConfiguration height;
  final HtmlContentViewerLength? contentPadding;

  const HtmlContentViewerLayout({
    this.viewport = const HtmlContentViewerViewport(),
    this.height = const HtmlContentViewerHeightConfiguration(),
    this.contentPadding,
  });
}

class HtmlContentViewerTypography {

  final HtmlContentViewerFontStyle fontStyle;
  final HtmlContentViewerLength? textSize;

  const HtmlContentViewerTypography({
    this.fontStyle = HtmlContentViewerFontStyle.html,
    this.textSize,
  });

  bool get usesDefaultFontStyle =>
      fontStyle == HtmlContentViewerFontStyle.defaultStyle;

  double get fontSize => textSize?.value ?? 16;
}

class HtmlContentViewerBehavior {

  final Set<HtmlContentViewerFeature> _features;

  const HtmlContentViewerBehavior._(this._features);

  const HtmlContentViewerBehavior.empty() : _features = const {};

  factory HtmlContentViewerBehavior({
    Set<HtmlContentViewerFeature> features = const {},
  }) => HtmlContentViewerBehavior._(Set.unmodifiable(features));

  bool has(HtmlContentViewerFeature feature) => _features.contains(feature);
}

class HtmlContentViewerCallbacks {

  final OnLoadWidthHtmlViewerAction? onLoadWidth;
  final OnMailtoDelegateAction? onMailto;
  final OnScrollHorizontalEndAction? onScrollHorizontalEnd;
  final OnPreviewEMLDelegateAction? onPreviewEML;
  final OnDownloadAttachmentDelegateAction? onDownloadAttachment;
  final OnHtmlContentClippedAction? onContentClipped;

  const HtmlContentViewerCallbacks({
    this.onLoadWidth,
    this.onMailto,
    this.onScrollHorizontalEnd,
    this.onPreviewEML,
    this.onDownloadAttachment,
    this.onContentClipped,
  });
}

/// Groups the document settings by their responsibility, which keeps the
/// viewer API extensible without adding another primitive constructor argument.
class HtmlContentViewerConfiguration {

  final HtmlContentViewerContent content;
  final HtmlContentViewerLayout layout;
  final HtmlContentViewerTypography typography;
  final HtmlContentViewerBehavior behavior;
  final HtmlContentViewerCallbacks callbacks;

  const HtmlContentViewerConfiguration({
    required this.content,
    this.layout = const HtmlContentViewerLayout(),
    this.typography = const HtmlContentViewerTypography(),
    this.behavior = const HtmlContentViewerBehavior.empty(),
    this.callbacks = const HtmlContentViewerCallbacks(),
  });
}
