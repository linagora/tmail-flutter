import 'package:core/presentation/views/html_viewer/html_content_viewer_configuration.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/html/mobile_email_responsive_layout_script.dart';
import 'package:flutter/widgets.dart';

/// Inputs of the document [HtmlViewerDocumentBuilder.buildWebDocument]
/// loads into the web viewer's iframe `srcdoc`.
///
/// Each `has*`/`use*` flag mirrors whether the matching widget callback or
/// option is set, because the iframe only gets the scripts it can talk to.
class HtmlWebViewerDocumentInput {
  const HtmlWebViewerDocumentInput({
    required this.content,
    required this.viewId,
    required this.widthContent,
    required this.minHeight,
    required this.minWidth,
    this.direction,
    this.contentPadding,
    this.useDefaultFontStyle = false,
    this.fontSize = 14,
    this.enableQuoteToggle = false,
    this.disableScrolling = false,
    this.autoAdjustHeight = false,
    this.hasMailtoDelegate = false,
    this.hasHyperLinkAction = false,
    this.hasScrollController = false,
    this.hasKeyboardShortcutAction = false,
    this.useLinkTooltipOverlay = false,
    this.isWebTouchDevice = false,
    this.isWebDesktop = false,
  });

  final String content;
  final String viewId;
  final double widthContent;
  final double minHeight;
  final double minWidth;
  final TextDirection? direction;
  final double? contentPadding;
  final bool useDefaultFontStyle;
  final double fontSize;
  final bool enableQuoteToggle;
  final bool disableScrolling;
  final bool autoAdjustHeight;
  final bool hasMailtoDelegate;
  final bool hasHyperLinkAction;
  final bool hasScrollController;
  final bool hasKeyboardShortcutAction;
  final bool useLinkTooltipOverlay;
  final bool isWebTouchDevice;
  final bool isWebDesktop;
}

/// Builds the exact HTML document each email viewer loads, so tests render
/// emails with the same scripts and styles as the app.
class HtmlViewerDocumentBuilder {
  const HtmlViewerDocumentBuilder._();

  static const String iframeOnLoadMessage = 'iframeHasBeenLoaded';
  static const String onClickHyperLinkName = 'onClickHyperLink';
  static const String onScrollChangedEvent = 'onScrollChanged';
  static const String onScrollEndEvent = 'onScrollEnd';

  static bool shouldApplyMobileResponsiveLayout(
    HtmlContentViewerConfiguration configuration,
    HtmlContentViewerPlatform platform,
  ) => configuration.behavior.has(
        HtmlContentViewerFeature.mobileResponsiveLayout,
      ) &&
      platform == HtmlContentViewerPlatform.mobile &&
      configuration.layout.viewport.width != null &&
      !configuration.behavior.has(HtmlContentViewerFeature.disableScrolling);

  /// Document of the native `HtmlContentViewer` (Android/iOS webview).
  static String buildNativeDocument({
    required HtmlContentViewerConfiguration configuration,
    required HtmlContentViewerPlatform platform,
    required bool isAndroid,
  }) {
    final enableQuoteToggle = configuration.behavior.has(
      HtmlContentViewerFeature.quoteToggle,
    );
    final disableScrolling = configuration.behavior.has(
      HtmlContentViewerFeature.disableScrolling,
    );
    final initialWidth = configuration.layout.viewport.width;
    final contentHtml = configuration.content.html;

    final processedContent = enableQuoteToggle
        ? HtmlUtils.addQuoteToggle(contentHtml)
        : contentHtml;

    final combinedCss = [
      if (enableQuoteToggle) HtmlUtils.quoteToggleStyle,
      if (disableScrolling) HtmlTemplate.disableScrollingStyleCSS,
    ].join();

    final combinedScripts = [
      HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
      if (enableQuoteToggle) HtmlUtils.quoteToggleScript,
      if (initialWidth != null)
        HtmlInteraction.generateNormalizeImageScript(initialWidth),
      if (shouldApplyMobileResponsiveLayout(configuration, platform))
        MobileEmailResponsiveLayoutScript.generate(
          contentSizeChangedEventJSChannelName:
              HtmlInteraction.contentSizeChangedEventJSChannelName,
        ),
      if (isAndroid)
        HtmlInteraction.scriptsHandleContentSizeChanged,
    ].join();

    return HtmlUtils.generateHtmlDocument(
      content: processedContent,
      direction: configuration.content.direction,
      javaScripts: combinedScripts,
      styleCSS: combinedCss,
      contentPadding: configuration.layout.contentPadding?.value,
      useDefaultFontStyle: configuration.typography.usesDefaultFontStyle,
      fontSize: configuration.typography.fontSize,
    );
  }

  /// Document of `IosHtmlContentViewerWidget` (EML previewer, composer
  /// fullscreen). It has no quote toggle and no responsive layout script.
  static String buildIosDocument({
    required String content,
    TextDirection? direction,
    bool useDefaultFontStyle = true,
  }) => HtmlUtils.generateHtmlDocument(
        content: content,
        direction: direction,
        javaScripts: HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
        useDefaultFontStyle: useDefaultFontStyle,
        fontSize: 16,
      );

  /// Document of `HtmlContentViewerOnWeb`, loaded as the iframe `srcdoc`.
  static String buildWebDocument(HtmlWebViewerDocumentInput input) {
    final viewId = input.viewId;
    final webViewActionScripts = '''
      <script type="text/javascript">
        window.parent.addEventListener('message', handleMessage, false);
        window.addEventListener('load', handleOnLoad);
        window.addEventListener('pagehide', (event) => {
          window.parent.removeEventListener('message', handleMessage, false);
          window.removeEventListener('load', handleOnLoad);
          ${!input.autoAdjustHeight ? '''
            clearTimeout(_resizeDebounceTimer);
            if (typeof resizeObserver !== 'undefined') resizeObserver.disconnect();
          ''' : ''}
        });
      
        function handleMessage(e) {
          if (e && e.data && typeof e.data === 'string' && e.data.includes("toIframe:")) {
            var data;
            try {
              data = JSON.parse(e.data);
            } catch (error) {
              return;
            }
            if (data
                && typeof data["view"] === 'string'
                && data["view"].includes("$viewId")
                && typeof data["type"] === 'string') {
              if (data["type"].includes("getHeight")) {
                var height = document.body.scrollHeight;
                window.parent.postMessage(JSON.stringify({"view": "$viewId", "type": "toDart: htmlHeight", "height": height}), "*");
              }
              if (data["type"].includes("getWidth")) {
                var width = document.body.scrollWidth;
                window.parent.postMessage(JSON.stringify({"view": "$viewId", "type": "toDart: htmlWidth", "width": width}), "*");
              }
              if (data["type"].includes("execCommand")) {
                if (data["argument"] === null) {
                  document.execCommand(data["command"], false);
                } else {
                  document.execCommand(data["command"], false, data["argument"]);
                }
              }
            }
          }
        }

        ${!input.autoAdjustHeight ? '''
          var _lastResizeHeight = 0;
          var _resizeDebounceTimer;
          const resizeObserver = new ResizeObserver((entries) => {
            clearTimeout(_resizeDebounceTimer);
            _resizeDebounceTimer = setTimeout(function() {
              var height = document.body.scrollHeight;
              if (height === _lastResizeHeight) return;
              _lastResizeHeight = height;
              window.parent.postMessage(JSON.stringify({"view": "$viewId", "type": "toDart: htmlHeight", "height": height}), "*");
            }, 50);
          });
        ''' : ''}
        
        ${input.hasMailtoDelegate
            ? '''
                function handleOnClickEmailLink(e) {
                   var href = this.href;
                   window.parent.postMessage(JSON.stringify({"view": "$viewId", "type": "toDart: OpenLink", "url": "" + href}), "*");
                   e.preventDefault();
                }
              '''
            : ''}
        
        
        
        ${input.hasHyperLinkAction
            ? '''
                function onClickHyperLink(e) {
                   var href = this.href;
                   window.parent.postMessage(JSON.stringify({"view": "$viewId", "type": "toDart: $onClickHyperLinkName", "url": "" + href}), "*");
                   e.preventDefault();
                }
              '''
            : ''}
        
        function handleOnLoad() {
          window.parent.postMessage(JSON.stringify({"view": "$viewId", "message": "$iframeOnLoadMessage"}), "*");
          window.parent.postMessage(JSON.stringify({"view": "$viewId", "type": "toIframe: getHeight"}), "*");
          window.parent.postMessage(JSON.stringify({"view": "$viewId", "type": "toIframe: getWidth"}), "*");
          
          ${input.hasHyperLinkAction
              ? '''
                  var hyperLinks = document.querySelectorAll('a');
                  for (var i=0; i < hyperLinks.length; i++){
                      hyperLinks[i].addEventListener('click', onClickHyperLink);
                  }
                '''
              : ''}
          
          ${input.hasMailtoDelegate
              ? '''
                  var emailLinks = document.querySelectorAll('a[href^="mailto:"]');
                  for (var i=0; i < emailLinks.length; i++){
                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);
                  }
                '''
              : ''}
          
          ${!input.autoAdjustHeight ? 'resizeObserver.observe(document.body);' : ''}
        }
      </script>
    ''';

    final processedContent = input.enableQuoteToggle
        ? HtmlUtils.addQuoteToggle(input.content)
        : input.content;

    final combinedCss = [
      if (input.enableQuoteToggle) HtmlUtils.quoteToggleStyle,
      if (input.disableScrolling) HtmlTemplate.disableScrollingStyleCSS,
    ].join();

    final combinedScripts = [
      webViewActionScripts,
      HtmlInteraction.scriptsDisableZoom,
      HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
      HtmlInteraction.generateNormalizeImageScript(input.widthContent),
      if (input.enableQuoteToggle) HtmlUtils.quoteToggleScript,
      if (input.hasScrollController)
        input.isWebTouchDevice
            ? HtmlInteraction.scriptsTouchEventListener(
                viewId: viewId,
                onScrollChangedEvent: onScrollChangedEvent,
                onScrollEndEvent: onScrollEndEvent,
              )
            : HtmlInteraction.scriptsWheelEventListener(
                viewId: viewId,
                onScrollChangedEvent: onScrollChangedEvent,
              ),
      if (input.hasKeyboardShortcutAction)
        HtmlInteraction.scriptHandleIframeKeyboardListener(viewId),
      if (input.useLinkTooltipOverlay)
        HtmlInteraction.scriptsHandleIframeClickListener(viewId),
      if (input.isWebDesktop)
        HtmlInteraction.scriptsHandleIframeLinkHoverListener(viewId),
    ].join();

    return HtmlUtils.generateHtmlDocument(
      content: processedContent,
      minHeight: input.minHeight,
      minWidth: input.minWidth,
      styleCSS: combinedCss,
      javaScripts: combinedScripts,
      direction: input.direction,
      contentPadding: input.contentPadding,
      useDefaultFontStyle: input.useDefaultFontStyle,
      fontSize: input.fontSize,
    );
  }
}
