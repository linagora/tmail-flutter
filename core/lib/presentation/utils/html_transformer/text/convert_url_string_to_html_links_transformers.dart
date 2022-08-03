
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/linkify_html.dart';

class ConvertUrlStringToHtmlLinksTransformers extends TextTransformer {

  const ConvertUrlStringToHtmlLinksTransformers();

  @override
  String process(String text) {
    log('ConvertUrlStringToHtmlLinksTransformers::process(): BEFORE: $text');
    final texValid = LinkifyHtml().generateLinkify(text);
    log('ConvertUrlStringToHtmlLinksTransformers::process(): AFTER: $texValid');
    return texValid;
  }
}