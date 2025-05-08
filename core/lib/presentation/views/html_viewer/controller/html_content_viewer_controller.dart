import 'package:core/presentation/views/html_viewer/utils/iframe_handler.dart';
import 'package:flutter/material.dart';

class HtmlContentViewerController {
  IframeHandler? iframeHandler;
  GlobalKey? htmlElementKey;
  bool isIFrameLoaded = false;

  void initializeIframe({
    required String id,
    required String content,
    required double width,
    required double height,
  }) {
    if (isIFrameLoaded) return;

    iframeHandler = IframeHandler();
    htmlElementKey = GlobalKey();

    iframeHandler?.initialize(
      id: id,
      content: content,
      width: width,
      height: height,
    );

    isIFrameLoaded = true;
  }

  void handlePointerEvent(PointerEvent event) {
    iframeHandler?.handlePointerEvent(
      event: event,
      htmlElementKey: htmlElementKey,
    );
  }

  void dispose() {
    htmlElementKey = null;
    iframeHandler = null;
    isIFrameLoaded = false;
  }
}
