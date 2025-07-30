import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class SignatureBuilder extends StatelessWidget {

  const SignatureBuilder({
    Key? key,
    required this.value,
    this.height = 150,
    this.width = 280,
    this.scrollController,
  }) : super(key: key);

  final String value;
  final double width;
  final double height;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return HtmlContentViewerOnWeb(
        contentHtml: value,
        widthContent: width,
        heightContent: height,
        contentPadding: 0,
        viewMaxHeight: height,
        htmlContentMinWidth: width,
        htmlContentMinHeight: 0.0,
        offsetHtmlContentHeight: 0.0,
        allowResizeToDocumentSize: false,
        direction: AppUtils.getCurrentDirection(context),
        scrollController: scrollController,
        keepAlive: true,
        disableScrolling: true,
        autoAdjustHeight: true,
      );
    } else {
      return HtmlContentViewer(
        contentHtml: value,
        initialWidth: width,
        maxViewHeight: height,
        contentPadding: 0,
        htmlContentMinHeight: 0.0,
        offsetHtmlContentHeight: 0.0,
        direction: AppUtils.getCurrentDirection(context),
        keepAlive: true,
        disableScrolling: true,
      );
    }
  }
}