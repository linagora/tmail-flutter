
extension HtmlExtension on String {

  String removeFontSizeZeroPixel() => replaceAll(RegExp('font-size:0px;'), '');

  String removeHeightZeroPixel() => replaceAll(RegExp('height:0px;'), '');

  String removeWidthZeroPixel() => replaceAll(RegExp('width:0px;'), '');

  String removeMaxWidthZeroPixel() => replaceAll(RegExp('max-width:0px;'), '');

  String removeMaxHeightZeroPixel() => replaceAll(RegExp('max-height:0px;'), '');

  String changeStyleBackground() => replaceAll(RegExp('background:'), 'background-color:');
}
