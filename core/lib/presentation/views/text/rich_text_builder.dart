import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';

class RichTextBuilder {

  final String _textOrigin;
  final String _wordToStyle;
  final TextStyle _styleOrigin;
  final TextStyle _styleWord;

  Key? _key;
  int? _maxLines;
  TextOverflow? _overflow;

  RichTextBuilder(
    this._textOrigin,
    this._wordToStyle,
    this._styleOrigin,
    this._styleWord,
  );

  void key(Key key) {
    _key = key;
  }

  void maxLines(int maxLines) {
    _maxLines = maxLines;
  }

  void setOverflow(TextOverflow textOverflow) {
    _overflow = textOverflow;
  }

  RichText build() {
    return RichText(
      key: _key,
      maxLines: _maxLines ?? 1,
      softWrap: CommonTextStyle.defaultSoftWrap,
      overflow: _overflow ?? CommonTextStyle.defaultTextOverFlow,
      text: TextSpan(
        style: _styleOrigin,
        children: _getSpans(_textOrigin, _wordToStyle, _styleWord)));
  }

  List<TextSpan> _getSpans(String text, String matchWord, TextStyle style) {
    List<TextSpan> spans = [];
    int spanBoundary = 0;
    do {
      // look for the next match
      final startIndex = text.toLowerCase().indexOf(matchWord.toLowerCase(), spanBoundary);
      // if no more matches then add the rest of the string without style
      if (startIndex == -1) {
        spans.add(TextSpan(text: text.substring(spanBoundary)));
        return spans;
      }
      // add any unStyled text before the next match
      if (startIndex > spanBoundary) {
        spans.add(TextSpan(text: text.substring(spanBoundary, startIndex)));
      }
      // style the matched text
      final endIndex = startIndex + matchWord.length;
      final spanText = text.substring(startIndex, endIndex);
      spans.add(TextSpan(text: spanText, style: style));
      // mark the boundary to start the next search from
      spanBoundary = endIndex;
      // continue until there are no more matches
    } while (spanBoundary < text.length);

    return spans;
  }
}