import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/html_transformer/html_template.dart';
import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:core/presentation/utils/icon_utils.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_controller_for_web.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:universal_html/html.dart' as html;
import 'package:core/presentation/utils/shims/dart_ui.dart' as ui;

class HtmlContentViewerOnWeb extends StatefulWidget {

  final String contentHtml;
  final double widthContent;
  final double heightContent;
  final HtmlViewerControllerForWeb controller;
  final TextDirection? direction;

  /// Handler for mailto: links
  final Function(Uri?)? mailtoDelegate;

  // if widthContent is bigger than width of htmlContent, set this to true let widget able to resize to width of htmlContent 
  final bool allowResizeToDocumentSize;
  
  const HtmlContentViewerOnWeb({
    Key? key,
    required this.contentHtml,
    required this.widthContent,
    required this.heightContent,
    required this.controller,
    this.allowResizeToDocumentSize = true,
    this.mailtoDelegate,
    this.direction,
  }) : super(key: key);

  @override
  State<HtmlContentViewerOnWeb> createState() => _HtmlContentViewerOnWebState();
}

class _HtmlContentViewerOnWebState extends State<HtmlContentViewerOnWeb> {

  /// The view ID for the IFrameElement. Must be unique.
  late String createdViewId;
  /// The actual height of the content view, used to automatically set the height
  late double actualHeight;
  /// The actual width of the content view, used to automatically set the width
  late double actualWidth;

  Future<bool>? webInit;
  String? _htmlData;
  bool _isLoading = true;
  double minHeight = 100;
  double minWidth = 300;
  final jsonEncoder = const JsonEncoder();

  @override
  void initState() {
    super.initState();
    actualHeight = widget.heightContent;
    actualWidth = widget.widthContent;
    createdViewId = _getRandString(10);
    widget.controller.viewId = createdViewId;
    _setUpWeb();
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewerOnWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('_HtmlContentViewerOnWebState::didUpdateWidget():Old-Direction: ${oldWidget.direction} | Current-Direction: ${widget.direction}');
    if (widget.contentHtml != oldWidget.contentHtml ||
        widget.direction != oldWidget.direction) {
      createdViewId = _getRandString(10);
      widget.controller.viewId = createdViewId;
      _setUpWeb();
    }

    if (widget.heightContent != oldWidget.heightContent) {
      actualHeight = widget.heightContent;
    }

    if (widget.widthContent != oldWidget.widthContent) {
      actualWidth = widget.widthContent;
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
        window.addEventListener('click', handleOnClickLink, true);
      
        function handleMessage(e) {
          if (e && e.data && e.data.includes("toIframe:")) {
            var data = JSON.parse(e.data);
            if (data["view"].includes("$createdViewId")) {
              if (data["type"].includes("showSignature")) {
                ${HtmlUtils.runScriptsCollapsedExpandedSignature}
              }
              
              if (data["type"].includes("getHeight")) {
                var height = document.body.scrollHeight;
                window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: htmlHeight", "height": height}), "*");
              }
              if (data["type"].includes("getWidth")) {
                var width = document.body.scrollWidth;
                window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: htmlWidth", "width": width}), "*");
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
        
        function handleOnClickLink(e) {
           let link = e.target;
           let textContent = e.target.textContent;
           if (link && isValidMailtoLink(link)) {
              window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: OpenLink", "url": "" + link}), "*");
              e.preventDefault();
           } else if (textContent && isValidMailtoLink(textContent)) {
              window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: OpenLink", "url": "" + textContent}), "*");
              e.preventDefault();
           }
        }
        
        function isValidMailtoLink(string) {
          let url;
          
          try {
            url = new URL(string);
          } catch (_) {
            return false;  
          }
        
          return url.protocol === "mailto:";
        }
        
        function handleOnClickSignature() {
          console.log("handleOnClickSignature");
          const contentElement = document.querySelector('.tmail-content > .tmail-signature > .tmail-signature-content');
          const buttonElement = document.querySelector('.tmail-content > .tmail-signature > .tmail-signature-button');
          console.log("contentElement: " + contentElement);
          console.log("buttonElement: " + buttonElement);
          if (contentElement && buttonElement) {
            if (contentElement.style.display === 'block') {
              contentElement.style.display = 'none';
              buttonElement.style.backgroundImage = `${IconUtils.chevronDownSVGIconUrlEncoded}`;
            } else {
              contentElement.style.display = 'block';
              buttonElement.style.backgroundImage = `${IconUtils.chevronUpSVGIconUrlEncoded}`;
            }
          }
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

    final htmlTemplate = generateHtml(content,
      minHeight: minHeight,
      minWidth: minWidth,
      styleCSS: tooltipLinkCss,
      javaScripts: webViewActionScripts + scriptsDisableZoom + HtmlUtils.scriptLazyLoadImage,
      direction: widget.direction);

    return htmlTemplate;
  }

  void _setUpWeb() {
    _htmlData = _generateHtmlDocument(widget.contentHtml);

    final iframe = html.IFrameElement()
      ..width = actualWidth.toString()
      ..height = actualHeight.toString()
      ..srcdoc = _htmlData ?? ''
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..style.width = '100%'
      ..style.height = '100%'
      ..onLoad.listen((event) async {
        _sendMessageToWebViewForGetHeight();
        _sendMessageToWebViewForGetWidth();
        _sendMessageToWebViewForShowSignature();

        html.window.onMessage.listen((event) {
          var data = json.decode(event.data);
          if (data['type'] != null && data['type'].contains('toDart: htmlHeight') && data['view'] == createdViewId) {
            final docHeight = data['height'] ?? actualHeight;
            if (docHeight != null && mounted) {
              final scrollHeightWithBuffer = docHeight + 30.0;
              if (scrollHeightWithBuffer > minHeight) {
                setState(() {
                  actualHeight = scrollHeightWithBuffer;
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

          if (data['type'] != null && data['type'].contains('toDart: htmlWidth') && data['view'] == createdViewId) {
            final docWidth = data['width'] ?? actualWidth;
            if (docWidth != null && mounted) {
              if (docWidth > minWidth && widget.allowResizeToDocumentSize) {
                setState(() {
                  actualWidth = docWidth;
                });
              }
            }
          }

          if (data['type'] != null && data['type'].contains('toDart: OpenLink') && data['view'] == createdViewId) {
            final link = data['url'];
            if (link != null && mounted) {
              final urlString = link as String;
              if (urlString.startsWith('mailto:')) {
                widget.mailtoDelegate?.call(Uri.parse(urlString));
              }
            }
          }
        });
      });

    ui.platformViewRegistry.registerViewFactory(createdViewId, (int viewId) => iframe);

    if (mounted) {
      setState(() {
        webInit = Future.value(true);
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
              future: webInit,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SizedBox(
                    height: actualHeight,
                    width: actualWidth,
                    child: HtmlElementView(
                      key: ValueKey(_htmlData),
                      viewType: createdViewId,
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

  void _sendMessageToWebViewForGetHeight() {
    final dataGetHeight = <String, Object>{
      'type': 'toIframe: getHeight',
      'view' : createdViewId
    };
    final jsonGetHeight = jsonEncoder.convert(dataGetHeight);

    html.window.postMessage(jsonGetHeight, '*');
  }

  void _sendMessageToWebViewForGetWidth() {
    final dataGetWidth = <String, Object>{
      'type': 'toIframe: getWidth',
      'view' : createdViewId
    };
    final jsonGetWidth = jsonEncoder.convert(dataGetWidth);

    html.window.postMessage(jsonGetWidth, '*');
  }

  void _sendMessageToWebViewForShowSignature() {
    final dataShowSignature = <String, Object>{
      'type': 'toIframe: showSignature',
      'view' : createdViewId
    };
    final jsonShowSignature = jsonEncoder.convert(dataShowSignature);

    html.window.postMessage(jsonShowSignature, '*');
  }
}