
extension HtmlExtension on String {

  static const String editorStartTags = '<p><br></p>';

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
    attribute: 'style=\"margin-left:8px;margin-right:8px;padding-left:12px;padding-right:12px;border-left:5px solid #eee;\"');

  String asSignatureHtml() => '--<br><br>$this';

  String toSignatureBlock() =>
      '<br class="tmail-break-tag"><div class="tmail-signature">${asSignatureHtml()}</div><br class="tmail-break-tag">';

  String removeEditorStartTag() {
    if (trim() == editorStartTags) {
      return '';
    }
    return this;
  }
}