import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/shims/dart_ui.dart' as ui;
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:universal_html/html.dart' as html;

typedef OnClickHyperLinkAction = Function(Uri?);

class HtmlContentViewerOnWeb extends StatefulWidget {

  final String contentHtml;
  final double widthContent;
  final double heightContent;
  final TextDirection? direction;

  /// Handler for mailto: links
  final Function(Uri?)? mailtoDelegate;

  final OnClickHyperLinkAction? onClickHyperLinkAction;

  // if widthContent is bigger than width of htmlContent, set this to true let widget able to resize to width of htmlContent 
  final bool allowResizeToDocumentSize;
  
  const HtmlContentViewerOnWeb({
    Key? key,
    required this.contentHtml,
    required this.widthContent,
    required this.heightContent,
    this.allowResizeToDocumentSize = true,
    this.mailtoDelegate,
    this.direction,
    this.onClickHyperLinkAction,
  }) : super(key: key);

  @override
  State<HtmlContentViewerOnWeb> createState() => _HtmlContentViewerOnWebState();
}

class _HtmlContentViewerOnWebState extends State<HtmlContentViewerOnWeb> {

  static const double _minWidth = 300;
  /// The view ID for the IFrameElement. Must be unique.
  late String _createdViewId;
  /// The actual height of the content view, used to automatically set the height
  late double _actualHeight;
  /// The actual width of the content view, used to automatically set the width
  late double _actualWidth;

  Future<bool>? _webInit;
  String? _htmlData;
  bool _isLoading = true;
  double minHeight = 100;
  late final StreamSubscription<html.MessageEvent> sizeListener;
  bool _iframeLoaded = false;
  static const String iframeOnLoadMessage = 'iframeHasBeenLoaded';
  static const String onClickHyperLinkName = 'onClickHyperLink';

  @override
  void initState() {
    super.initState();
    _actualHeight = widget.heightContent;
    _actualWidth = widget.widthContent;
    _createdViewId = _getRandString(10);
    _setUpWeb();

    sizeListener = html.window.onMessage.listen((event) {
      var data = json.decode(event.data);

      if (data['view'] != _createdViewId) return;

      if (data['message'] == iframeOnLoadMessage) {
        _iframeLoaded = true;
      }

      if (!_iframeLoaded) return;

      if (data['type'] != null && data['type'].contains('toDart: htmlHeight')) {
        final docHeight = data['height'] ?? _actualHeight;
        if (docHeight != null && mounted) {
          final scrollHeightWithBuffer = docHeight + 30.0;
          if (scrollHeightWithBuffer > minHeight) {
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

      if (data['type'] != null && data['type'].contains('toDart: htmlWidth')) {
        final docWidth = data['width'] ?? _actualWidth;
        if (docWidth != null && mounted) {
          if (docWidth > _minWidth && widget.allowResizeToDocumentSize) {
            setState(() {
              _actualWidth = docWidth;
            });
          }
        }
      }

      if (data['type'] != null && data['type'].contains('toDart: OpenLink')) {
        final link = data['url'];
        if (link != null && mounted) {
          final urlString = link as String;
          if (urlString.startsWith('mailto:')) {
            widget.mailtoDelegate?.call(Uri.parse(urlString));
          }
        }
      }

      if (data['type'] != null && data['type'].contains('toDart: $onClickHyperLinkName')) {
        final link = data['url'] as String?;
        if (link != null && mounted) {
          widget.onClickHyperLinkAction?.call(Uri.parse(link));
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewerOnWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('_HtmlContentViewerOnWebState::didUpdateWidget():Old-Direction: ${oldWidget.direction} | Current-Direction: ${widget.direction}');
    if (widget.contentHtml != oldWidget.contentHtml ||
        widget.direction != oldWidget.direction) {
      _createdViewId = _getRandString(10);
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
        }
      </script>
    ''';

    const scriptsDisableZoom = '''
      <script type="text/javascript">
        document.addEventListener('wheel', function(e) {
          e.ctrlKey && e.preventDefault();
        }, {
          passive: false,
        });
        window.addEventListener('keydown', function(e) {
          if (event.metaKey || event.ctrlKey) {
            switch (event.key) {
              case '=':
              case '-':
                event.preventDefault();
                break;
            }
          }
        });
      </script>
    ''';

    final htmlTemplate = HtmlUtils.generateHtmlDocument(
      content: content,
      minHeight: minHeight,
      minWidth: _minWidth,
      styleCSS: HtmlTemplate.tooltipLinkCss,
      javaScripts: webViewActionScripts + scriptsDisableZoom + HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
      direction: widget.direction);

    return htmlTemplate;
  }

  void _setUpWeb() {
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
    return LayoutBuilder(builder: (context, constraint) {
      minHeight = math.max(constraint.maxHeight, minHeight);
      return Stack(
        children: [
          if (_htmlData?.isNotEmpty == false)
            const SizedBox.shrink()
          else
            FutureBuilder<bool>(
              future: _webInit,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SizedBox(
                    height: _actualHeight,
                    width: _actualWidth,
                    child: HtmlElementView(
                      key: ValueKey(_htmlData),
                      viewType: _createdViewId,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }
            ),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CupertinoActivityIndicator(
                    color: AppColor.colorLoading
                  )
                )
              )
            )
        ],
      );
    });
  }

  @override
  void dispose() {
    _htmlData = null;
    sizeListener.cancel();
    super.dispose();
  }
}