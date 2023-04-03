import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_controller_for_web.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';

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
          child: _buildSignature(signatureWidth, signatureHeight),
        );
      }
    );
  }

  Widget _buildSignature(double width, double height) {
    if (signatureSelected.isNotEmpty) {
      if (BuildUtils.isWeb) {
        return HtmlContentViewerOnWeb(
          contentHtml: signatureSelected,
          widthContent: width,
          heightContent: height,
          controller: HtmlViewerControllerForWeb(),
          allowResizeToDocumentSize: false
        );
      } else {
        return HtmlContentViewer(
          contentHtml: signatureSelected,
          heightContent: height
        );
      }
    } else {
      return SizedBox(width: width, height: height);
    }
  }
}