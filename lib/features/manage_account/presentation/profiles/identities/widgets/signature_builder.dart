import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_controller_for_web.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';

class SignatureBuilder extends StatelessWidget {

  const SignatureBuilder({
    Key? key,
    required this.identity,
    this.width,
    this.height = 256
  }) : super(key: key);

  final Identity identity;
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
    final signature = identity.signatureAsString;
    log('SignatureBuilder::_buildSignature():signature: $signature');
    if (signature.isNotEmpty) {
      final htmlSignatureDecoded = _decodeHtml(signature);
      if (BuildUtils.isWeb) {
        return HtmlContentViewerOnWeb(
          contentHtml: htmlSignatureDecoded,
          widthContent: width,
          heightContent: height,
          controller: HtmlViewerControllerForWeb(),
          allowResizeToDocumentSize: false
        );
      } else {
        return HtmlContentViewer(
          contentHtml: htmlSignatureDecoded,
          heightContent: height
        );
      }
    } else {
      return SizedBox(width: width, height: height);
    }
  }

  String _decodeHtml(String htmlString) {
    final unescape = HtmlUnescape();
    return unescape.convert(htmlString);
  }
}