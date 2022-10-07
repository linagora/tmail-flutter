
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/utils/linkify_html.dart';

class ConvertUrlStringToHtmlLinksTransformers extends TextTransformer {

  const ConvertUrlStringToHtmlLinksTransformers();

  @override
  String process(String text) {
    final texValid = LinkifyHtml().generateLinkify(text);
    return texValid;
  }
}