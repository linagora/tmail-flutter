import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class SignatureBuilder extends StatelessWidget {

  const SignatureBuilder(
    this.signatureSelected, {
    Key? key,
    this.width,
    this.height = 256
  }) : super(key: key);

  final String signatureSelected;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final signatureWidth = width ?? constraints.biggest.width;
        final signatureHeight = height;
        return Container(
          width: signatureWidth,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: _buildSignature(context, signatureWidth, signatureHeight),
        );
      }
    );
  }

  Widget _buildSignature(BuildContext context, double width, double height) {
    if (signatureSelected.isNotEmpty) {
      if (PlatformInfo.isWeb) {
        return HtmlContentViewerOnWeb(
          contentHtml: signatureSelected,
          widthContent: width,
          heightContent: height,
          allowResizeToDocumentSize: false,
          direction: AppUtils.getCurrentDirection(context),
        );
      } else {
        return LayoutBuilder(builder: (context, constraints) {
          return HtmlContentViewer(
            contentHtml: signatureSelected,
            initialWidth: constraints.maxWidth,
            direction: AppUtils.getCurrentDirection(context),
          );
        });
      }
    } else {
      return SizedBox(width: width, height: height);
    }
  }
}