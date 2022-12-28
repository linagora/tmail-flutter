import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_controller_for_web.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class SignatureBuilder extends StatelessWidget {

  const SignatureBuilder({
    Key? key,
    this.width,
    this.height,
    this.htmlSignature,
    this.textSignature,
  }) : super(key: key);

  final Signature? htmlSignature;
  final Signature? textSignature;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final signatureWidth = width ?? constraints.biggest.width;
        final signatureHeight = height ?? constraints.biggest.height;
        return Container(
          width: signatureWidth,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: _buildSignature(signatureWidth, signatureHeight),
        );
      }
    );
  }

  Widget _buildSignature(double width, double height) {
    Widget signature;
    if (htmlSignature != null && htmlSignature!.value.isNotEmpty) {
      final htmlSignatureDecoded = _decodeHtml(htmlSignature!.value);
      if (BuildUtils.isWeb) {
        signature = HtmlContentViewerOnWeb(
          contentHtml: htmlSignatureDecoded,
          widthContent: width, 
          heightContent: height, 
          controller: HtmlViewerControllerForWeb(),
          allowResizeToDocumentSize: false);
      } else {
        signature = HtmlContentViewer(contentHtml: htmlSignatureDecoded, heightContent: height);
      }
    } else if (textSignature != null) {
      signature = Text(textSignature!.value);
    } else {
      signature = SizedBox.fromSize(size: Size(width, height));
    }
    return signature;
  }

  String _decodeHtml(String htmlString) {
    final unescape = HtmlUnescape();
    return unescape.convert(htmlString);
  }
}