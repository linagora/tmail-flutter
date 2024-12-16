
import 'dart:convert';

extension HtmlExtension on String {

  static const String editorStartTags = '<div><br><br></div>';
  static const String signaturePrefix = '--&nbsp;';

  String addBlockTag(String tag, {String? attribute}) =>
      attribute != null
          ? '<$tag $attribute>$this</$tag>'
          : '<$tag>$this</$tag>';

  String append(String value) => this + value;

  String addNewLineTag({int count = 1}) {
    if (count == 1) return '$this</br>';

    var htmlString = this;
    for (var i = 0; i < count; i++) {
      htmlString = '$htmlString</br>';
    }
    return htmlString;
  }

  String addBlockQuoteTag() => addBlockTag(
    'blockquote',
    attribute: 'style="margin-left:8px;margin-right:8px;padding-left:12px;padding-right:12px;border-left:5px solid #eee;"');

  String signaturePrefixTagHtml() => '<span class="tmail_signature_prefix">$signaturePrefix</span>';

  String asSignatureHtml() => '${signaturePrefixTagHtml()}<br>$this<br>';

  String removeEditorStartTag() {
    if (trim() == editorStartTags) {
      return '';
    }
    return this;
  }

  String addCiteTag() => addBlockTag(
    'cite',
    attribute: 'style="text-align: left;display: block;"'
  );
}

extension HtmlNullableExtension on String? {
  String escapeHtmlString({HtmlEscapeMode escapeMode = HtmlEscapeMode.unknown}) {
    try {
      if (this?.trim().isNotEmpty != true) return '';

      return HtmlEscape(escapeMode).convert(this!);
    } catch (e) {
      return '';
    }
  }

  String escapeLtGtHtmlString() =>
      escapeHtmlString(escapeMode: HtmlEscapeMode.element);
}