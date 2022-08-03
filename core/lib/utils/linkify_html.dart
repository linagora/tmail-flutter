
import 'package:collection/collection.dart';
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

    final listUrlMatch = regexLinkWithHttp.allMatches(replacedText)
        .map((regexMatch) => regexMatch.group(1))
        .whereNotNull()
        .toSet();

    log('ConvertUrlStringToHtmlLinksTransformers::_linkifyUrlAddress(): listUrlMatch: $listUrlMatch');

    if (listUrlMatch.isNotEmpty) {
      listUrlMatch.forEach((link) {
        replacedText = replacedText.replaceAll(
            link,
            '<a href="$link" target="_blank">$link</a>');
      });
    }

    // URLs starting with "www." without // before it or it'd re-link the ones done above.
    final regexLinkWithWWW = _generateRegExp(r'(^|[^\/])(www\.[\S]+(\b|\$))');

    final listLinkMatch = regexLinkWithWWW.allMatches(replacedText)
        .map((regexMatch) => regexMatch.group(2))
        .whereNotNull()
        .toSet();
    log('ConvertUrlStringToHtmlLinksTransformers::_linkifyUrlAddress(): listLinkMatch: $listLinkMatch');

    if (listLinkMatch.isNotEmpty) {
      listLinkMatch.forEach((link) {
        replacedText = replacedText.replaceAll(
            link,
            '<a href="https://$link" target="_blank">$link</a>');
      });
    }

    return replacedText;
  }

  /// Change email addresses to mailto:: links.
  String _linkifyMailToAddress(String inputText) {
    final regexMailTo = _generateRegExp(r'(([a-zA-Z0-9\-\_\.])+@[a-zA-Z\_]+?(\.[a-zA-Z]{2,6})+)');

    final listEmailAddressMatch = regexMailTo.allMatches(inputText)
        .map((regexMatch) => regexMatch.group(1))
        .whereNotNull()
        .toSet();

    log('ConvertUrlStringToHtmlLinksTransformers::generateLinkifyHtml(): listEmailAddressMatch: $listEmailAddressMatch');

    if (listEmailAddressMatch.isNotEmpty) {
      listEmailAddressMatch.forEach((emailAddress) {
        inputText = inputText.replaceAll(
            emailAddress,
            '<a href="mailto:$emailAddress">$emailAddress</a>');
      });
    }
    return inputText;
  }
}