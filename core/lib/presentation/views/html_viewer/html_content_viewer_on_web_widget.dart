import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_controller_for_web.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:universal_html/html.dart' as html;
import 'package:core/presentation/utils/shims/dart_ui.dart' as ui;

class HtmlContentViewerOnWeb extends StatefulWidget {

  final String contentHtml;
  final double widthContent;
  final HtmlViewerControllerForWeb controller;

  const HtmlContentViewerOnWeb({
    Key? key,
    required this.contentHtml,
    required this.widthContent,
    required this.controller,
  }) : super(key: key);

  @override
  _HtmlContentViewerOnWebState createState() => _HtmlContentViewerOnWebState();
}

class _HtmlContentViewerOnWebState extends State<HtmlContentViewerOnWeb> {

  /// The view ID for the IFrameElement. Must be unique.
  late String createdViewId;
  /// The actual height of the editor, used to automatically set the height
  late double actualHeight;

  Future<bool>? webInit;
  String? _htmlData;
  bool _isLoading = true;
  int minHeight = 100;

  @override
  void initState() {
    super.initState();
    actualHeight = 400;
    createdViewId = _getRandString(10);
    widget.controller.viewId = createdViewId;
    _setUpWeb();
  }

  String _getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  String _generateHtmlDocument(String content) {
    final htmlScripts = '''
      <script type="text/javascript">
        window.parent.addEventListener('message', handleMessage, false);
      
        function handleMessage(e) {
          if (e && e.data && e.data.includes("toIframe:")) {
            var data = JSON.parse(e.data);
            if (data["view"].includes("$createdViewId")) {
              if (data["type"].includes("getHeight")) {
                var height = document.body.scrollHeight;
                window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: htmlHeight", "height": height}), "*");
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
      </script>
    ''';

    final htmlTemplate = '''
      <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <style>
        #editor {
          outline: 0px solid transparent;
          min-height: ${minHeight}px;
          min-width: 300px;
          color: #000000;
          font-family: verdana;
        }
        table {
          width: 100%;
          max-width: 100%;
        }
        td {
          padding: 13px;
          margin: 0px;
        }
        th {
          padding: 13px;
          margin: 0px;
        }
      </style>
      $htmlScripts
      </head>
      <body>
      <div id="editor">$content</div>
      </body>
      </html> 
    ''';

    return htmlTemplate;
  }

  void _setUpWeb() {
    _htmlData = _generateHtmlDocument(widget.contentHtml);

    final iframe = html.IFrameElement()
      ..width = widget.widthContent.toString()
      ..height = actualHeight.toString()
      ..srcdoc = _htmlData ?? ''
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..onLoad.listen((event) async {
        var data = <String, Object>{'type': 'toIframe: getHeight'};
        data['view'] = createdViewId;
        final jsonEncoder = JsonEncoder();
        var jsonStr = jsonEncoder.convert(data);
        html.window.postMessage(jsonStr, '*');

        html.window.onBeforeUnload.listen((event) {
          event.preventDefault();
        });

        html.window.onMessage.listen((event) {
          var data = json.decode(event.data);
          developer.log('onMessage(): data: $data', name: 'HtmlContentViewerOnWeb');
          if (data['type'] != null &&
              data['type'].contains('toDart: htmlHeight') &&
              data['view'] == createdViewId) {
            final docHeight = data['height'] ?? actualHeight;
            developer.log('onMessage(): docHeight: $docHeight', name: 'HtmlContentViewerOnWeb');
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
          if (data['type'] != null &&
              data['type'].contains('toDart: onChangeContent') &&
              data['view'] == createdViewId) {
            if (Scrollable.of(context) != null) {
              Scrollable.of(context)!.position.ensureVisible(
                  context.findRenderObject()!,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeIn);
            }
          }
        });
      });

    iframe.setAttribute('scrolling', 'no');
    iframe.setAttribute('seamless', 'seamless');

    ui.platformViewRegistry.registerViewFactory(createdViewId, (int viewId) => iframe);

    if (mounted) {
      setState(() {
        webInit = Future.value(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox(
          height: actualHeight,
          width: widget.widthContent,
          child: _buildWebView(),
        ),
        if (_isLoading) _buildLoadingView()
      ],
    );
  }

  Widget _buildLoadingView() {
    return Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(color: AppColor.colorTextButton)));
  }

  Widget _buildWebView() {
    final htmlData = _htmlData;
    if (htmlData == null || htmlData.isEmpty) {
      return Container();
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: FutureBuilder<bool>(
        future: webInit,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HtmlElementView(
              key: ValueKey(htmlData),
              viewType: createdViewId,
            );
          } else {
            return Container();
          }
        }
      )
    );
  }
}