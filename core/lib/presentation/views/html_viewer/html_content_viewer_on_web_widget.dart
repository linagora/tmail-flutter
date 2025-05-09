import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/shims/dart_ui.dart' as ui;
import 'package:core/presentation/views/html_viewer/controller/html_content_viewer_controller.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
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
  final HtmlContentViewerController? viewerController;

  /// Handler for mailto: links
  final OnMailtoClicked? mailtoDelegate;

  final OnClickHyperLinkAction? onClickHyperLinkAction;

  // if widthContent is bigger than width of htmlContent, set this to true let widget able to resize to width of htmlContent
  final bool allowResizeToDocumentSize;

  final bool keepWidthWhileLoading;

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
    this.viewerController,
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

  ValueNotifier<SystemMouseCursor>? _contentCursorNotifier;

  @override
  void initState() {
    super.initState();
    _actualHeight = widget.heightContent;
    _actualWidth = widget.widthContent;
    _createdViewId = _getRandString(10);
    if (widget.viewerController != null) {
      _contentCursorNotifier = ValueNotifier<SystemMouseCursor>(SystemMouseCursors.basic);
    }
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

      if (data['type'] != null && data['type'].contains('toDart: htmlWidth') && !widget.keepWidthWhileLoading) {
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

      if (data['type'] != null && data['type'].contains('toDart: changeCursor')) {
        final cursor = data['value'] as String?;
        if (cursor != null && mounted) {
          if (cursor == 'pointer') {
            _contentCursorNotifier?.value = SystemMouseCursors.click;
          } else if (cursor == 'text') {
            _contentCursorNotifier?.value = SystemMouseCursors.text;
          } else {
            _contentCursorNotifier?.value = SystemMouseCursors.basic;
          }
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

        const resizeObserver = new ResizeObserver((entries) => {
          var height = document.body.scrollHeight;
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: htmlHeight", "height": height}), "*");
        });
        
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
          
          resizeObserver.observe(document.body);
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

    StringBuffer scriptBuffer = StringBuffer()
      ..write(webViewActionScripts)
      ..write(scriptsDisableZoom)
      ..write(HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage);

    if (widget.viewerController != null) {
      scriptBuffer.write(
        HtmlInteraction.scriptHandleEventListeners(viewId: _createdViewId),
      );
    }

    final htmlTemplate = HtmlUtils.generateHtmlDocument(
      content: content,
      minHeight: minHeight,
      minWidth: _minWidth,
      styleCSS: HtmlTemplate.tooltipLinkCss,
      javaScripts: scriptBuffer.toString(),
      direction: widget.direction,
      contentPadding: widget.contentPadding,
      useDefaultFont: widget.useDefaultFont,
      disableFocusOutline: widget.viewerController != null,
    );

    return htmlTemplate;
  }

  void _setUpWeb() {
    _htmlData = _generateHtmlDocument(widget.contentHtml);

    if (widget.viewerController != null) {
      widget.viewerController?.initializeIframe(
        id: _createdViewId,
        content: _htmlData!,
        width: _actualWidth,
        height: _actualHeight,
      );
    } else {
      final iframe = html.IFrameElement()
        ..width = _actualWidth.toString()
        ..height = _actualHeight.toString()
        ..srcdoc = _htmlData ?? ''
        ..style.border = 'none'
        ..style.overflow = 'hidden'
        ..style.width = '100%'
        ..style.height = '100%';

      ui.platformViewRegistry.registerViewFactory(
        _createdViewId,
        (int viewId) => iframe,
      );
    }

    if (mounted) {
      setState(() {
        _webInit = Future.value(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      minHeight = math.min(constraint.maxHeight, minHeight);
      final child = Stack(
        children: [
          if (_htmlData?.isNotEmpty == false)
            const SizedBox.shrink()
          else
            FutureBuilder<bool>(
              future: _webInit,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (widget.viewerController != null &&
                      widget.viewerController!.iframeHandler != null) {
                    final eventOverlayView = PointerInterceptor(
                      child: Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: widget.viewerController!.handlePointerEvent,
                        onPointerMove: widget.viewerController!.handlePointerEvent,
                        onPointerUp: widget.viewerController!.handlePointerEvent,
                        onPointerHover: widget.viewerController!.handlePointerEvent,
                        child: Container(
                          height: _actualHeight,
                          width: _actualWidth,
                          color: Colors.transparent,
                        ),
                      ),
                    );

                    return Stack(
                      children: [
                        SizedBox(
                          height: _actualHeight,
                          width: _actualWidth,
                          child: HtmlElementView(
                            key: widget.viewerController!.htmlElementKey,
                            viewType: widget.viewerController!.iframeHandler!.viewId,
                          ),
                        ),
                        if (_contentCursorNotifier != null)
                          ValueListenableBuilder(
                            valueListenable: _contentCursorNotifier!,
                            builder: (context, value, child) {
                              return MouseRegion(
                                cursor: value,
                                child: child,
                              );
                            },
                            child: eventOverlayView,
                          )
                        else
                          MouseRegion(
                            cursor: SystemMouseCursors.text,
                            child: eventOverlayView,
                          ),
                      ],
                    );
                  } else {
                    return SizedBox(
                      height: _actualHeight,
                      width: _actualWidth,
                      child: HtmlElementView(
                        viewType: _createdViewId,
                      ),
                    );
                  }
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

      if (!widget.keepWidthWhileLoading) return child;

      return SizedBox(
        width: _actualWidth,
        child: child,
      );
    });
  }

  @override
  void dispose() {
    _htmlData = null;
    sizeListener.cancel();
    _contentCursorNotifier?.dispose();
    _contentCursorNotifier = null;
    super.dispose();
  }
}