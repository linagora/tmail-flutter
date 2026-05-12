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
  final bool quoteStartCollapsed;
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
    this.quoteStartCollapsed = true,
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
  static String? _activeFindViewId;

  Future<bool>? _webInit;
  String? _htmlData;
  bool _isLoading = true;
  late double minHeight;
  late final StreamSubscription<html.MessageEvent> _onMessageSubscription;
  late final StreamSubscription<html.KeyboardEvent>
  _onWindowKeyDownSubscription;
  bool _iframeLoaded = false;
  bool _findBarVisible = false;
  int _findMatchCount = 0;
  int _findActiveIndex = -1;
  html.IFrameElement? _iframeElement;
  final TextEditingController _findTextController = TextEditingController();
  final FocusNode _findFocusNode = FocusNode();
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
    _onWindowKeyDownSubscription = html.window.onKeyDown.listen(
      _handleWindowKeyDown,
    );
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
      } else if (_isIframeFindShortcutEventTriggered(type)) {
        _handleIFrameFindShortcutEvent();
        return;
      } else if (_isIframeFindResultEventTriggered(type)) {
        _handleIFrameFindResultEvent(data);
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
      logWarning('$runtimeType::_handleMessageEvent:Exception = $e');
    }
  }

  bool _isActiveFindView() => _activeFindViewId == _createdViewId;

  void _markAsActiveFindView() {
    _activeFindViewId = _createdViewId;
  }

  void _clearActiveFindView() {
    if (_activeFindViewId == _createdViewId) {
      _activeFindViewId = null;
    }
  }

  void _handleWindowKeyDown(html.KeyboardEvent event) {
    if (!_isActiveFindView() && !_findBarVisible) {
      return;
    }

    if (_isBrowserFindShortcut(event)) {
      event.preventDefault();
      event.stopPropagation();
      _showFindBar();
      return;
    }

    if (!_findBarVisible) {
      return;
    }

    if (event.key == 'Escape') {
      event.preventDefault();
      _closeFindBar();
    } else if (event.key == 'Enter') {
      event.preventDefault();
      event.shiftKey ? _findPrevious() : _findNext();
    }
  }

  bool _isBrowserFindShortcut(html.KeyboardEvent event) {
    return (event.ctrlKey || event.metaKey) &&
        !event.altKey &&
        (event.key ?? '').toLowerCase() == 'f';
  }

  void _handleIFrameFindShortcutEvent() {
    _markAsActiveFindView();
    _showFindBar();
  }

  bool _isIframeFindShortcutEventTriggered(String? type) {
    return type?.contains(
          'toDart: ${HtmlInteraction.iframeFindShortcutEvent}',
        ) ==
        true;
  }

  bool _isIframeFindResultEventTriggered(String? type) {
    return type?.contains('toDart: ${HtmlInteraction.iframeFindResultEvent}') ==
        true;
  }

  void _handleIFrameFindResultEvent(dynamic data) {
    if (!mounted) return;

    final total = data['total'];
    final active = data['active'];
    setState(() {
      _findMatchCount = total is int ? total : 0;
      _findActiveIndex = active is int ? active : -1;
    });
  }

  void _showFindBar() {
    if (!mounted) return;

    if (!_findBarVisible) {
      setState(() {
        _findBarVisible = true;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _findFocusNode.requestFocus();
      _findTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _findTextController.text.length,
      );
    });
  }

  void _closeFindBar() {
    _findTextController.clear();
    _postMessageToIFrame(HtmlInteraction.iframeFindClearEvent);

    if (!mounted) return;
    setState(() {
      _findBarVisible = false;
      _findMatchCount = 0;
      _findActiveIndex = -1;
    });
  }

  void _applyFindQuery(String query) {
    _postMessageToIFrame(
      HtmlInteraction.iframeFindApplyEvent,
      data: {'query': query},
    );
  }

  void _findNext() {
    _postMessageToIFrame(HtmlInteraction.iframeFindNextEvent);
  }

  void _findPrevious() {
    _postMessageToIFrame(HtmlInteraction.iframeFindPreviousEvent);
  }

  void _postMessageToIFrame(
    String event, {
    Map<String, dynamic> data = const {},
  }) {
    final contentWindow = _iframeElement?.contentWindow;
    if (contentWindow == null) return;

    contentWindow.postMessage(
      json.encode({
        'view': _createdViewId,
        'type': 'toIframe: $event',
        ...data,
      }),
      '*',
    );
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
      logWarning(
        '$runtimeType::_handleIframeOnScrollChangedListener:Exception = $e',
      );
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
      log(
        '$runtimeType::_handleContentHeightEvent: ScrollHeightWithBuffer = $scrollHeightWithBuffer',
      );
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
    if (docWidth != null &&
        mounted &&
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
        ctrl: data['ctrl'] == true,
        meta: data['meta'] == true,
        alt: data['alt'] == true,
      );
      log(
        '$runtimeType::_handleOnIFrameKeyboardEvent:📥 Shortcut pressed: $shortcut',
      );
      widget.onIFrameKeyboardShortcutAction?.call(shortcut);
    } catch (e) {
      logWarning('$runtimeType::_handleOnIFrameKeyboardEvent: Exception = $e');
    }
  }

  bool _isIframeClickEventTriggered(String? type) {
    return widget.useLinkTooltipOverlay &&
        type?.contains('toDart: iframeClick') == true;
  }

  void _handleOnIFrameClickEvent(dynamic data) {
    try {
      log('$runtimeType::_handleOnIFrameClickEvent: $data');
      _markAsActiveFindView();
      widget.onIFrameClickAction?.call();
    } catch (e) {
      logWarning('$runtimeType::_handleOnIFrameClickEvent: Exception = $e');
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
      logWarning('$runtimeType::_handleOnIFrameLinkHoverEvent: Exception = $e');
    }
  }

  void _handleOnIFrameLinkOutEvent(dynamic data) {
    try {
      log('$runtimeType::_handleOnIFrameLinkOutEvent: $data');
      _tooltipOverlay?.hide();
    } catch (e) {
      logWarning('$runtimeType::_handleOnIFrameLinkOutEvent: Exception = $e');
    }
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewerOnWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    log(
      '$runtimeType::didUpdateWidget():Old-Direction: ${oldWidget.direction} | Current-Direction: ${widget.direction}',
    );
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

  String _generateHtmlDocument(String content) {
    final webViewActionScripts =
        '''
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
        
        ${widget.mailtoDelegate != null ? '''
                function handleOnClickEmailLink(e) {
                   var href = this.href;
                   window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: OpenLink", "url": "" + href}), "*");
                   e.preventDefault();
                }
              ''' : ''}
        
        
        
        ${widget.onClickHyperLinkAction != null ? '''
                function onClickHyperLink(e) {
                   var href = this.href;
                   window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: $onClickHyperLinkName", "url": "" + href}), "*");
                   e.preventDefault();
                }
              ''' : ''}
        
        function handleOnLoad() {
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "message": "$iframeOnLoadMessage"}), "*");
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toIframe: getHeight"}), "*");
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toIframe: getWidth"}), "*");
          
          ${widget.onClickHyperLinkAction != null ? '''
                  var hyperLinks = document.querySelectorAll('a');
                  for (var i=0; i < hyperLinks.length; i++){
                      hyperLinks[i].addEventListener('click', onClickHyperLink);
                  }
                ''' : ''}
          
          ${widget.mailtoDelegate != null ? '''
                  var emailLinks = document.querySelectorAll('a[href^="mailto:"]');
                  for (var i=0; i < emailLinks.length; i++){
                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);
                  }
                ''' : ''}
          
          ${!widget.autoAdjustHeight ? 'resizeObserver.observe(document.body);' : ''}
        }
      </script>
    ''';

    final processedContent = widget.enableQuoteToggle
        ? HtmlUtils.addQuoteToggle(
            content,
            startCollapsed: widget.quoteStartCollapsed,
          )
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
      HtmlInteraction.scriptHandleIframeFindShortcutListener(_createdViewId),
      HtmlInteraction.scriptHandleIframeContentFind(_createdViewId),
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
    _createdViewId = HtmlUtils.getRandString(10);
    _htmlData = _generateHtmlDocument(widget.contentHtml);
    _iframeElement = null;
    _iframeLoaded = false;
    _findMatchCount = 0;
    _findActiveIndex = -1;
    _findBarVisible = false;
    _findTextController.clear();

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

  String get _findMatchLabel {
    if (_findTextController.text.trim().isEmpty) {
      return '';
    }

    if (_findMatchCount == 0) {
      return '0/0';
    }

    return '${_findActiveIndex + 1}/$_findMatchCount';
  }

  Widget _buildFindBar() {
    final hasMatches = _findMatchCount > 0;

    return Positioned(
      top: 8,
      right: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.colorDividerEmailView),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 34,
                child: CupertinoTextField(
                  controller: _findTextController,
                  focusNode: _findFocusNode,
                  placeholder: 'Find in message',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.search,
                      size: 16,
                      color: Color(0xFF7A869A),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColor.colorDividerEmailView),
                  ),
                  onChanged: (query) {
                    setState(() {
                      _findMatchCount = 0;
                      _findActiveIndex = -1;
                    });
                    _applyFindQuery(query);
                  },
                  onSubmitted: (_) => _findNext(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                child: Text(
                  _findMatchLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4C566A),
                    fontSize: 13,
                  ),
                ),
              ),
              _buildFindButton(
                icon: CupertinoIcons.chevron_up,
                onPressed: hasMatches ? _findPrevious : null,
              ),
              _buildFindButton(
                icon: CupertinoIcons.chevron_down,
                onPressed: hasMatches ? _findNext : null,
              ),
              _buildFindButton(
                icon: CupertinoIcons.xmark,
                onPressed: _closeFindBar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return CupertinoButton(
      minimumSize: const Size(30, 30),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 17,
        color: onPressed == null
            ? const Color(0xFFB8C0CC)
            : const Color(0xFF334054),
      ),
    );
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
                    _iframeElement = element as html.IFrameElement;
                    _iframeElement!
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
        if (_findBarVisible) _buildFindBar(),
      ],
    );

    final activeAwareChild = MouseRegion(
      onEnter: (_) => _markAsActiveFindView(),
      onExit: (_) {
        if (!_findBarVisible) {
          _clearActiveFindView();
        }
      },
      child: child,
    );

    if (widget.keepWidthWhileLoading) {
      return activeAwareChild;
    } else {
      return SizedBox(width: _actualWidth, child: activeAwareChild);
    }
  }

  @override
  void dispose() {
    _htmlData = null;
    _onMessageSubscription.cancel();
    _onWindowKeyDownSubscription.cancel();
    _findTextController.dispose();
    _findFocusNode.dispose();
    _clearActiveFindView();
    if (PlatformInfo.isWebDesktop) {
      _tooltipOverlay?.hide();
      _tooltipOverlay = null;
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
