import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HtmlContentView extends StatefulWidget {

  HtmlContentView(
    this.htmlContent
  );
  final String htmlContent;

  @override
  State<StatefulWidget> createState() {
     return _HtmlContentViewState();
  }
}

class _HtmlContentViewState extends State<HtmlContentView> {

    InAppWebViewController? webViewController;
    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        preferredContentMode: UserPreferredContentMode.MOBILE
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
        enableViewportScale: true,
        
      ));
   double webViewContentHeight = 1.0;

  @override
  Widget build(BuildContext context) {

      return Container(
        child: InAppWebView(
        initialOptions: options,
        initialData: InAppWebViewInitialData(data: widget.htmlContent),
        onWebViewCreated: (InAppWebViewController controller) { 
          webViewController = controller; 
        },
        onLoadStop: (controller, uri) {
          controller.evaluateJavascript(source: '''(() => { return document.body.scrollHeight;})()''').then((value) {
                if(value == null || value == '') {
                  return;
                }
                this.setState(() {
                    webViewContentHeight = double.parse('$value');
                });
                   
          });
        }),
        width: double.infinity,
        height: webViewContentHeight,
      );
  }
}