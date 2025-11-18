import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/shortcut/key_shortcut.dart';
import 'package:core/presentation/views/tooltip/iframe_tooltip_overlay.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:universal_html/html.dart' as html;

typedef OnClickHyperLinkAction = Function(Uri?);
typedef OnMailtoClicked = void Function(Uri? uri);
typedef OnIFrameKeyboardShortcutAction = void Function(KeyShortcut keyShortcut);
typedef OnIFrameClickAction = void Function();

class HtmlContentViewerOnWeb extends StatefulWidget {

  final String contentHtml;
  final double widthContent;
  final double heightContent;
  final TextDirection? direction;
  final double? contentPadding;
  final bool useDefaultFontStyle;
  final double fontSize;

  /// Handler for mailto: links
  final OnMailtoClicked? mailtoDelegate;

  final OnClickHyperLinkAction? onClickHyperLinkAction;

  final OnIFrameKeyboardShortcutAction? onIFrameKeyboardShortcutAction;

  final OnIFrameClickAction? onIFrameClickAction;

  // if widthContent is bigger than width of htmlContent, set this to true let widget able to resize to width of htmlContent
  final bool allowResizeToDocumentSize;

  final bool keepWidthWhileLoading;
  final ScrollController? scrollController;
  final bool enableQuoteToggle;
  final bool disableScrolling;
  final bool keepAlive;
  final double htmlContentMinHeight;
  final double htmlContentMinWidth;
  final double offsetHtmlContentHeight;
  final double? viewMaxHeight;
  final bool autoAdjustHeight;
  final bool useLinkTooltipOverlay;
  final IframeTooltipOptions? iframeTooltipOptions;

  const HtmlContentViewerOnWeb({
    Key? key,
    required this.contentHtml,
    required this.widthContent,
    this.heightContent = 200,
    this.allowResizeToDocumentSize = true,
    this.useDefaultFontStyle = false,
    this.mailtoDelegate,
    this.direction,
    this.onClickHyperLinkAction,
    this.keepWidthWhileLoading = false,
    this.contentPadding,
    this.scrollController,
    this.enableQuoteToggle = false,
    this.keepAlive = false,
    this.disableScrolling = false,
    this.autoAdjustHeight = false,
    this.useLinkTooltipOverlay = false,
    this.fontSize = 14,
    this.htmlContentMinHeight = ConstantsUI.htmlContentMinHeight,
    this.htmlContentMinWidth = ConstantsUI.htmlContentMinWidth,
    this.offsetHtmlContentHeight = ConstantsUI.htmlContentOffsetHeight,
    this.viewMaxHeight,
    this.onIFrameKeyboardShortcutAction,
    this.onIFrameClickAction,
    this.iframeTooltipOptions,
  }) : super(key: key);

  @override
  State<HtmlContentViewerOnWeb> createState() => _HtmlContentViewerOnWebState();
}

class _HtmlContentViewerOnWebState extends State<HtmlContentViewerOnWeb>
    with AutomaticKeepAliveClientMixin {
  /// The view ID for the IFrameElement. Must be unique.
  late String _createdViewId;
  /// The actual height of the content view, used to automatically set the height
  late double _actualHeight;
  /// The actual width of the content view, used to automatically set the width
  late double _actualWidth;

  Future<bool>? _webInit;
  String? _htmlData;
  bool _isLoading = true;
  late double minHeight;
  late final StreamSubscription<html.MessageEvent> _onMessageSubscription;
  bool _iframeLoaded = false;
  static const String iframeOnLoadMessage = 'iframeHasBeenLoaded';
  static const String onClickHyperLinkName = 'onClickHyperLink';
  static const String onScrollChangedEvent = 'onScrollChanged';
  static const String onScrollEndEvent = 'onScrollEnd';

  IframeTooltipOverlay? _tooltipOverlay;

  @override
  void initState() {
    super.initState();
    _actualHeight = widget.heightContent;
    _actualWidth = widget.widthContent;
    minHeight = widget.htmlContentMinHeight;
    if (PlatformInfo.isWebDesktop) {
      _tooltipOverlay = IframeTooltipOverlay(
        options: widget.iframeTooltipOptions ?? const IframeTooltipOptions(),
      );
    }
    _setUpWeb();
    _onMessageSubscription = html.window.onMessage.listen(_handleMessageEvent);
  }

  void _handleMessageEvent(html.MessageEvent event) {
    try {
      final data = json.decode(event.data);

      final viewId = data['view'];
      if (viewId != _createdViewId) return;

      final type = data['type'];
      if (_isScrollingIsAvailable && _isScrollChangedEventTriggered(type)) {
        _handleIframeOnScrollChangedListener(data, widget.scrollController!);
        return;
      } else if (_isScrollingIsAvailable && _isScrollEndEventTriggered(type)) {
        _handleIframeOnScrollEndListener(data, widget.scrollController!);
        return;
      } else if (_isIframeKeyboardEventTriggered(type)) {
        _handleOnIFrameKeyboardEvent(data);
        return;
      } else if (_isIframeClickEventTriggered(type)) {
        _handleOnIFrameClickEvent(data);
        return;
      } else if (_isIframeLinkHoverEventTriggered(type)) {
        _handleOnIFrameLinkHoverEvent(data);
        return;
      } else if (_isIframeLinkOutEventTriggered(type)) {
        _handleOnIFrameLinkOutEvent(data);
        return;
      }

      if (data['message'] == iframeOnLoadMessage) {
        _iframeLoaded = true;
      }
      if (!_iframeLoaded) return;

      if (_isHtmlContentHeightEventTriggered(type)) {
        _handleContentHeightEvent(data['height']);
      } else if (_isHtmlContentWidthEventTriggered(type)) {
        _handleContentWidthEvent(data['width']);
      } else if (_isMailtoLinkEventTriggered(type)) {
        _handleMailtoLinkEvent(data['url']);
      } else if (_isHyperLinkEventTriggered(type)) {
        _handleHyperLinkEvent(data['url']);
      }
    } catch (e) {
      logError('$runtimeType::_handleMessageEvent:Exception = $e');
    }
  }

  bool get _isScrollingIsAvailable {
    return widget.scrollController != null &&
        widget.scrollController?.hasClients == true;
  }

  bool _isScrollChangedEventTriggered(String? type) {
    return type?.contains('toDart: $onScrollChangedEvent') == true;
  }

  bool _isScrollEndEventTriggered(String? type) {
    return type?.contains('toDart: $onScrollEndEvent') == true;
  }

  void _handleIframeOnScrollChangedListener(
    dynamic data,
    ScrollController controller,
  ) {
    try {
      final deltaY = data['deltaY'] ?? 0.0;
      final target = controller.offset + deltaY;

      if (PlatformInfo.isWebTouchDevice) {
        final newOffset = target.clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent,
        );

        controller.animateTo(
          newOffset,
          duration: const Duration(milliseconds: 50),
          curve: Curves.linear,
        );
      } else {
        if (target < controller.position.minScrollExtent) {
          controller.jumpTo(controller.position.minScrollExtent);
        } else if (target > controller.position.maxScrollExtent) {
          controller.jumpTo(controller.position.maxScrollExtent);
        } else {
          controller.jumpTo(target);
        }
      }
    } catch (e) {
      logError('$runtimeType::_handleIframeOnScrollChangedListener:Exception = $e');
    }
  }

  void _handleIframeOnScrollEndListener(
    dynamic data,
    ScrollController controller,
  ) {
    final velocity = data['velocity'] ?? 0.0;

    final distance = velocity * 800;
    final target = controller.offset + distance;

    final newOffset = target.clamp(
      controller.position.minScrollExtent,
      controller.position.maxScrollExtent,
    );

    controller.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.decelerate,
    );
  }

  bool _isHtmlContentHeightEventTriggered(String? type) =>
      type?.contains('toDart: htmlHeight') == true;

  void _handleContentHeightEvent(dynamic height) {
    final docHeight = height ?? _actualHeight;
    if (docHeight != null && mounted) {
      final scrollHeightWithBuffer = docHeight + widget.offsetHtmlContentHeight;
      log('$runtimeType::_handleContentHeightEvent: ScrollHeightWithBuffer = $scrollHeightWithBuffer');
      bool isHeightChanged = widget.autoAdjustHeight
        ? scrollHeightWithBuffer >= minHeight
        : scrollHeightWithBuffer > minHeight;

      if (isHeightChanged) {
        setState(() {
          _actualHeight = scrollHeightWithBuffer;
          _isLoading = false;
        });
      }
    }
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isHtmlContentWidthEventTriggered(String? type) =>
      type?.contains('toDart: htmlWidth') == true &&
          !widget.keepWidthWhileLoading;

  void _handleContentWidthEvent(dynamic width) {
    final docWidth = width ?? _actualWidth;
    if (docWidth != null && mounted &&
        docWidth > widget.htmlContentMinWidth &&
        widget.allowResizeToDocumentSize) {
      setState(() => _actualWidth = docWidth);
    }
  }

  bool _isMailtoLinkEventTriggered(String? type) =>
      type?.contains('toDart: OpenLink') == true;

  void _handleMailtoLinkEvent(dynamic url) {
    if (url != null && mounted && url is String && url.startsWith('mailto:')) {
      widget.mailtoDelegate?.call(Uri.tryParse(url));
    }
  }

  bool _isHyperLinkEventTriggered(String? type) =>
      type?.contains('toDart: $onClickHyperLinkName') == true;

  void _handleHyperLinkEvent(dynamic url) {
    if (url != null && mounted && url is String) {
      widget.onClickHyperLinkAction?.call(Uri.tryParse(url));
    }
  }

  bool _isIframeKeyboardEventTriggered(String? type) {
    return widget.onIFrameKeyboardShortcutAction != null &&
        type?.contains('toDart: iframeKeydown') == true;
  }

  void _handleOnIFrameKeyboardEvent(dynamic data) {
    try {
      final shortcut = KeyShortcut(
        key: data['key'] as String,
        code: data['code'] as String,
        shift: data['shift'] == true,
      );
      log('$runtimeType::_handleOnIFrameKeyboardEvent:📥 Shortcut pressed: $shortcut');
      widget.onIFrameKeyboardShortcutAction?.call(shortcut);
    } catch (e) {
      logError('$runtimeType::_handleOnIFrameKeyboardEvent: Exception = $e');
    }
  }

  bool _isIframeClickEventTriggered(String? type) {
    return widget.useLinkTooltipOverlay &&
        type?.contains('toDart: iframeClick') == true;
  }

  void _handleOnIFrameClickEvent(dynamic data) {
    try {
      log('$runtimeType::_handleOnIFrameClickEvent: $data');
      widget.onIFrameClickAction?.call();
    } catch (e) {
      logError('$runtimeType::_handleOnIFrameClickEvent: Exception = $e');
    }
  }

  bool _isIframeLinkHoverEventTriggered(String? type) {
    return type?.contains('toDart: iframeLinkHover') == true;
  }

  bool _isIframeLinkOutEventTriggered(String? type) {
    return type?.contains('toDart: iframeLinkOut') == true;
  }

  void _handleOnIFrameLinkHoverEvent(dynamic data) {
    try {
      log('$runtimeType::_handleOnIFrameLinkHoverEvent: $data');
      final url = data['url'] ?? '';
      final rectData = data['rect'];

      if (rectData != null) {
        final rect = Rect.fromLTWH(
          rectData['x']?.toDouble() ?? 0,
          rectData['y']?.toDouble() ?? 0,
          rectData['width']?.toDouble() ?? 0,
          rectData['height']?.toDouble() ?? 0,
        );

        if (mounted) {
          _tooltipOverlay?.show(context, url, rect);
        }
      }
    } catch (e) {
      logError('$runtimeType::_handleOnIFrameLinkHoverEvent: Exception = $e');
    }
  }

  void _handleOnIFrameLinkOutEvent(dynamic data) {
    try {
      log('$runtimeType::_handleOnIFrameLinkOutEvent: $data');
      _tooltipOverlay?.hide();
    } catch (e) {
      logError('$runtimeType::_handleOnIFrameLinkOutEvent: Exception = $e');
    }
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewerOnWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('$runtimeType::didUpdateWidget():Old-Direction: ${oldWidget.direction} | Current-Direction: ${widget.direction}');
    if (widget.contentHtml != oldWidget.contentHtml ||
        widget.direction != oldWidget.direction) {
      _setUpWeb();
    }

    if (widget.heightContent != oldWidget.heightContent) {
      _actualHeight = widget.heightContent;
    }

    if (widget.widthContent != oldWidget.widthContent) {
      _actualWidth = widget.widthContent;
    }
  }

  String _getRandString(int len) {
    var random = math.Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  String _generateHtmlDocument(String content) {
    final webViewActionScripts = '''
      <script type="text/javascript">
        window.parent.addEventListener('message', handleMessage, false);
        window.addEventListener('load', handleOnLoad);
        window.addEventListener('pagehide', (event) => {
          window.parent.removeEventListener('message', handleMessage, false);
          window.removeEventListener('load', handleOnLoad);
        });
      
        function handleMessage(e) {
          if (e && e.data && e.data.includes("toIframe:")) {
            var data = JSON.parse(e.data);
            if (data["view"].includes("$_createdViewId")) {
              if (data["type"].includes("getHeight")) {
                var height = document.body.scrollHeight;
                window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: htmlHeight", "height": height}), "*");
              }
              if (data["type"].includes("getWidth")) {
                var width = document.body.scrollWidth;
                window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: htmlWidth", "width": width}), "*");
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

        ${!widget.autoAdjustHeight ? '''
          const resizeObserver = new ResizeObserver((entries) => {
            var height = document.body.scrollHeight;
            window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: htmlHeight", "height": height}), "*");
          });
        ''' : ''}
        
        ${widget.mailtoDelegate != null
            ? '''
                function handleOnClickEmailLink(e) {
                   var href = this.href;
                   window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: OpenLink", "url": "" + href}), "*");
                   e.preventDefault();
                }
              '''
            : ''}
        
        
        
        ${widget.onClickHyperLinkAction != null
            ? '''
                function onClickHyperLink(e) {
                   var href = this.href;
                   window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: $onClickHyperLinkName", "url": "" + href}), "*");
                   e.preventDefault();
                }
              '''
            : ''}
        
        function handleOnLoad() {
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "message": "$iframeOnLoadMessage"}), "*");
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toIframe: getHeight"}), "*");
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toIframe: getWidth"}), "*");
          
          ${widget.onClickHyperLinkAction != null
              ? '''
                  var hyperLinks = document.querySelectorAll('a');
                  for (var i=0; i < hyperLinks.length; i++){
                      hyperLinks[i].addEventListener('click', onClickHyperLink);
                  }
                '''
              : ''}
          
          ${widget.mailtoDelegate != null
              ? '''
                  var emailLinks = document.querySelectorAll('a[href^="mailto:"]');
                  for (var i=0; i < emailLinks.length; i++){
                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);
                  }
                '''
              : ''}
          
          ${!widget.autoAdjustHeight ? 'resizeObserver.observe(document.body);' : ''}
        }
      </script>
    ''';

    final processedContent = widget.enableQuoteToggle
        ? HtmlUtils.addQuoteToggle(content)
        : content;

    final combinedCss = [
      if (widget.enableQuoteToggle) HtmlUtils.quoteToggleStyle,
      if (widget.disableScrolling) HtmlTemplate.disableScrollingStyleCSS,
    ].join();

    final combinedScripts = [
      webViewActionScripts,
      HtmlInteraction.scriptsDisableZoom,
      HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
      HtmlInteraction.generateNormalizeImageScript(widget.widthContent),
      if (widget.enableQuoteToggle) HtmlUtils.quoteToggleScript,
      if (widget.scrollController != null)
        PlatformInfo.isWebTouchDevice
            ? HtmlInteraction.scriptsTouchEventListener(
                viewId: _createdViewId,
                onScrollChangedEvent: onScrollChangedEvent,
                onScrollEndEvent: onScrollEndEvent,
              )
            : HtmlInteraction.scriptsWheelEventListener(
                viewId: _createdViewId,
                onScrollChangedEvent: onScrollChangedEvent,
              ),
      if (widget.onIFrameKeyboardShortcutAction != null)
        HtmlInteraction.scriptHandleIframeKeyboardListener(_createdViewId),
      if (widget.useLinkTooltipOverlay)
        HtmlInteraction.scriptsHandleIframeClickListener(_createdViewId),
      if (PlatformInfo.isWebDesktop)
        HtmlInteraction.scriptsHandleIframeLinkHoverListener(_createdViewId),
    ].join();

    final htmlTemplate = HtmlUtils.generateHtmlDocument(
      content: processedContent,
      minHeight: minHeight,
      minWidth: widget.htmlContentMinWidth,
      styleCSS: combinedCss,
      javaScripts: combinedScripts,
      direction: widget.direction,
      contentPadding: widget.contentPadding,
      useDefaultFontStyle: widget.useDefaultFontStyle,
      fontSize: widget.fontSize,
    );

    return htmlTemplate;
  }

  void _setUpWeb() {
    _createdViewId = _getRandString(10);
    _htmlData = _generateHtmlDocument(widget.contentHtml);

    _webInit = Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.autoAdjustHeight) {
      return _buildHtmlElementView();
    } else {
      return LayoutBuilder(
        builder: (_, constraint) {
          minHeight = math.min(constraint.maxHeight, minHeight);
          return _buildHtmlElementView();
        },
      );
    }
  }

  Widget _buildHtmlElementView() {
    log('$runtimeType::_buildHtmlElementView: ActualHeight: $_actualHeight');
    final child = Stack(
      children: [
        if (_htmlData?.trim().isNotEmpty == true)
          FutureBuilder<bool>(
            future: _webInit,
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                final htmlView = HtmlElementView.fromTagName(
                  key: ValueKey('$_htmlData-${widget.key}'),
                  tagName: 'iframe',
                  onElementCreated: (element) {
                    (element as html.IFrameElement)
                      ..width = _actualWidth.toString()
                      ..height = _actualHeight.toString()
                      ..srcdoc = _htmlData ?? ''
                      ..style.border = 'none'
                      ..style.overflow = 'hidden'
                      ..style.width = '100%'
                      ..style.height = '100%';
                  },
                );

                if (widget.viewMaxHeight != null) {
                  return Container(
                    height: _actualHeight,
                    width: _actualWidth,
                    constraints: BoxConstraints(
                      maxHeight: widget.viewMaxHeight!,
                    ),
                    child: htmlView,
                  );
                } else {
                  return SizedBox(
                    height: _actualHeight,
                    width: _actualWidth,
                    child: htmlView,
                  );
                }
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        if (_isLoading)
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 30,
                height: 30,
                child: CupertinoActivityIndicator(color: AppColor.colorLoading),
              ),
            ),
          ),
      ],
    );

    if (widget.keepWidthWhileLoading) {
      return child;
    } else {
      return SizedBox(width: _actualWidth, child: child);
    }
  }

  @override
  void dispose() {
    _htmlData = null;
    _onMessageSubscription.cancel();
    if (PlatformInfo.isWebDesktop) {
      _tooltipOverlay?.hide();
      _tooltipOverlay = null;
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}