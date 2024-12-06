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
  }) : super(key: key);

  final String value;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    if (PlatformInfo.isWeb) {
      return HtmlContentViewerOnWeb(
        contentHtml: value,
        widthContent: width,
        heightContent: height,
        contentPadding: 0,
        maxHeight: height,
        minWidth: height,
        allowResizeToDocumentSize: false,
        adjustHeight: true,
        direction: AppUtils.getCurrentDirection(context),
      );
    } else {
      return HtmlContentViewer(
        contentHtml: value,
        initialWidth: width,
        adjustHeight: true,
        contentPadding: 0,
        direction: AppUtils.getCurrentDirection(context),
      );
    }
  }
}