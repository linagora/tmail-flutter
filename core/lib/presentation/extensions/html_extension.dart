
extension HtmlExtension on String {

  static const String editorStartTags = '<p><br></p>';

  String removeFontSizeZeroPixel() => replaceAll(RegExp('font-size:0px;'), '');

  String removeHeightZeroPixel() => replaceAll(RegExp('height:0px;'), '');

  String removeWidthZeroPixel() => replaceAll(RegExp('width:0px;'), '');

  String removeMaxWidthZeroPixel() => replaceAll(RegExp('max-width:0px;'), '');

  String removeMaxHeightZeroPixel() => replaceAll(RegExp('max-height:0px;'), '');

  String changeStyleBackground() => replaceAll(RegExp('background:'), 'background-color:');

  String addBorderLefForBlockQuote() => replaceAll(RegExp('<blockquote'), '<blockquote style=\"margin-left:8px;margin-right:8px;padding-left:12px;padding-right:12px;border-left:6px solid #EFEFEF;\"');

  String addBlockTag(String tag, {String? attribute}) => attribute != null ? '<$tag $attribute>$this</$tag>' : '<$tag>$this</$tag>';

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