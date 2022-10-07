
import 'package:core/utils/app_logger.dart';

class LinkifyHtml {

  String generateLinkify(String inputText) {
    var replacedText = _linkifyUrlAddress(inputText);
    replacedText = _linkifyMailToAddress(replacedText);
    return replacedText;
  }

  RegExp _generateRegExp(String pattern) {
    return RegExp(pattern, multiLine: true, caseSensitive: false);
  }

  /// URLs starting with http://, https://, ftp://, or "www." without //.
  String _linkifyUrlAddress(String inputText) {
    var replacedText = inputText;

    // URLs starting with http://, https://, ftp://
    final regexLinkWithHttp = _generateRegExp(r'(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])');
    final newReplacedTextWithHttp = replacedText.replaceAllMapped(regexLinkWithHttp, (regexMatch) {
      final link = regexMatch.group(1);
      final newLinkWithHttp = link?.isNotEmpty == true
          ? '<a href="$link" target="_blank">$link</a>'
          : '';
      log('ConvertUrlStringToHtmlLinksTransformers::_linkifyUrlAddress(): newLinkWithHttp: $newLinkWithHttp');
      return newLinkWithHttp;
    });
    replacedText = newReplacedTextWithHttp;

    // URLs starting with "www." without // before it or it'd re-link the ones done above.
    final regexLinkWithWWW = _generateRegExp(r'(^|[^\/])(www\.[\S]+(\b|\$))');
    final newReplacedTextWithWWW = replacedText.replaceAllMapped(regexLinkWithWWW, (regexMatch) {
      final previousChar = regexMatch.group(1);
      log('LinkifyHtml::_linkifyUrlAddress(): previousChar: $previousChar');
      final link = regexMatch.group(2);
      final newLinkWithWWW = link?.isNotEmpty == true
          ? '$previousChar<a href="https://$link" target="_blank">$link</a>'
          : '';
      log('ConvertUrlStringToHtmlLinksTransformers::_linkifyUrlAddress(): newLinkWithWWW: $newLinkWithWWW');
      return newLinkWithWWW;
    });
    replacedText = newReplacedTextWithWWW;

    return replacedText;
  }

  /// Change email addresses to mailto:: links.
  String _linkifyMailToAddress(String inputText) {
    final regexMailTo = _generateRegExp(r'(([a-zA-Z0-9\-\_\.])+@[a-zA-Z\_]+?(\.[a-zA-Z]{2,6})+)');

    final newReplacedTextWitMailTo = inputText.replaceAllMapped(regexMailTo, (regexMatch) {
      final emailAddress = regexMatch.group(1);
      final newMailToLink = emailAddress?.isNotEmpty == true
        ? '<a href="mailto:$emailAddress">$emailAddress</a>'
        : '';
      log('ConvertUrlStringToHtmlLinksTransformers::_linkifyUrlAddress(): newMailToLink: $newMailToLink');
      return newMailToLink;
    });

    return newReplacedTextWitMailTo;
  }
}