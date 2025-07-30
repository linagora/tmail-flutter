import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/shims/dart_ui.dart' as ui;
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

typedef OnClickHyperLinkAction = Function(Uri?);
typedef OnMailtoClicked = void Function(Uri? uri);

class HtmlContentViewerOnWeb extends StatefulWidget {

  final String contentHtml;
  final double widthContent;
  final double heightContent;
  final TextDirection? direction;
  final double? contentPadding;
  final bool useDefaultFont;

  /// Handler for mailto: links
  final OnMailtoClicked? mailtoDelegate;

  final OnClickHyperLinkAction? onClickHyperLinkAction;

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

  const HtmlContentViewerOnWeb({
    Key? key,
    required this.contentHtml,
    required this.widthContent,
    required this.heightContent,
    this.allowResizeToDocumentSize = true,
    this.useDefaultFont = false,
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
    this.htmlContentMinHeight = ConstantsUI.htmlContentMinHeight,
    this.htmlContentMinWidth = ConstantsUI.htmlContentMinWidth,
    this.offsetHtmlContentHeight = ConstantsUI.htmlContentOffsetHeight,
    this.viewMaxHeight,
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

  @override
  void initState() {
    super.initState();
    _actualHeight = widget.heightContent;
    _actualWidth = widget.widthContent;
    minHeight = widget.htmlContentMinHeight;
    _setUpWeb();
    _onMessageSubscription = html.window.onMessage.listen(_handleMessageEvent);
  }

  void _handleMessageEvent(html.MessageEvent event) {
    try {
      final data = json.decode(event.data);

      final viewId = data['view'];
      if (viewId != _createdViewId) return;

      final type = data['type'];
      if (_isScrollChangedEventTriggered(type)) {
        _handleIframeOnScrollChangedListener(data, widget.scrollController!);
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
      logError('_HtmlContentViewerOnWebState::_handleMessageEvent:Exception = $e');
    }
  }

  bool _isScrollChangedEventTriggered(String? type) {
    return widget.scrollController != null &&
        widget.scrollController?.hasClients == true &&
        type?.contains('toDart: $onScrollChangedEvent') == true;
  }

  void _handleIframeOnScrollChangedListener(
    dynamic data,
    ScrollController controller,
  ) {
    final deltaY = data['deltaY'] ?? 0.0;
    final newOffset = controller.offset + deltaY;
    log('_HtmlContentViewerOnWebState::_handleIframeOnScrollChangedListener:deltaY = $deltaY | newOffset = $newOffset');
    if (newOffset < controller.position.minScrollExtent) {
      controller.jumpTo(controller.position.minScrollExtent);
    } else if (newOffset > controller.position.maxScrollExtent) {
      controller.jumpTo(controller.position.maxScrollExtent);
    } else {
      controller.jumpTo(newOffset);
    }
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

  @override
  void didUpdateWidget(covariant HtmlContentViewerOnWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('_HtmlContentViewerOnWebState::didUpdateWidget():Old-Direction: ${oldWidget.direction} | Current-Direction: ${widget.direction}');
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
        
        ${widget.scrollController != null ? '''
          window.addEventListener('wheel', function (event) {
            const deltaY = event.deltaY;
            window.parent.postMessage(JSON.stringify({
              "view": "$_createdViewId",
              "type": "toDart: $onScrollChangedEvent",
              "deltaY": deltaY
            }), "*");
          });
        ''' : ''}
      </script>
    ''';

    final processedContent = widget.enableQuoteToggle
        ? HtmlUtils.addQuoteToggle(content)
        : content;

    final combinedCss = [
      HtmlTemplate.tooltipLinkCss,
      if (widget.enableQuoteToggle) HtmlUtils.quoteToggleStyle,
      if (widget.disableScrolling) HtmlTemplate.disableScrollingStyleCSS,
    ].join();

    final combinedScripts = [
      webViewActionScripts,
      HtmlInteraction.scriptsDisableZoom,
      HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
      HtmlInteraction.generateNormalizeImageScript(widget.widthContent),
      if (widget.enableQuoteToggle) HtmlUtils.quoteToggleScript,
    ].join();

    final htmlTemplate = HtmlUtils.generateHtmlDocument(
      content: processedContent,
      minHeight: minHeight,
      minWidth: widget.htmlContentMinWidth,
      styleCSS: combinedCss,
      javaScripts: combinedScripts,
      direction: widget.direction,
      contentPadding: widget.contentPadding,
      useDefaultFont: widget.useDefaultFont,
    );

    return htmlTemplate;
  }

  void _setUpWeb() {
    _createdViewId = _getRandString(10);
    _htmlData = _generateHtmlDocument(widget.contentHtml);

    final iframe = html.IFrameElement()
      ..width = _actualWidth.toString()
      ..height = _actualHeight.toString()
      ..srcdoc = _htmlData ?? ''
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..style.width = '100%'
      ..style.height = '100%';

    ui.platformViewRegistry.registerViewFactory(_createdViewId, (int viewId) => iframe);

    if (mounted) {
      setState(() {
        _webInit = Future.value(true);
      });
    }
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
                final htmlView = HtmlElementView(
                  key: ValueKey('$_htmlData-${widget.key}'),
                  viewType: _createdViewId,
                );

                if (widget.viewMaxHeight != null) {
                  return Container(
                    height: _actualHeight,
                    width: _actualWidth,
                    color: Colors.greenAccent,
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
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}