import 'sane_html_validator.dart' show SaneHtmlValidator;
import 'package:core/core.dart';

class HtmlMessagePurifier {
  String purifyHtmlMessage(
    String html,
    {
      Set<String>? allowElementIds,
      Set<String>? allowClassNames,
      Set<String>? allowAttributes
    }
  ) {
    return sanitizeHtml(
        html,
        allowElementId: (elementId) => allowElementIds != null ? allowElementIds.contains(elementId) : false,
        allowClassName: (className) => allowClassNames != null ? allowClassNames.contains(className) : false,
        allowAttributes: (attribute) => allowAttributes != null ? allowAttributes.contains(attribute) : false)
      .changeStyleBackground()
      .removeFontSizeZeroPixel()
      .removeMaxHeightZeroPixel()
      .removeMaxWidthZeroPixel()
      .removeHeightZeroPixel()
      .removeWidthZeroPixel();
  }

  String sanitizeHtml(
    String htmlString,
    {
      bool Function(String)? allowElementId,
      bool Function(String)? allowClassName,
      bool Function(String)? allowAttributes,
      Iterable<String>? Function(String)? addLinkRel
    }
  ) {
    return SaneHtmlValidator(
      allowElementId: allowElementId,
      allowClassName: allowClassName,
      allowAttributes: allowAttributes,
      addLinkRel: addLinkRel,
    ).sanitize(htmlString);
  }
}