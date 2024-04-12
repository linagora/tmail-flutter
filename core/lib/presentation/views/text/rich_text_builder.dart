import 'package:flutter/material.dart';

class RichTextBuilder extends StatelessWidget {

  final String textOrigin;
  final String wordToStyle;
  final TextStyle styleOrigin;
  final TextStyle styleWord;

  const RichTextBuilder({
    super.key,
    required this.textOrigin,
    required this.wordToStyle,
    required this.styleOrigin,
    required this.styleWord,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: styleOrigin,
        children: _getSpans(
          text: textOrigin,
          word: wordToStyle,
          styleOrigin: styleOrigin,
          styleWord: styleWord,
        )
      ),
      style: styleOrigin,
      maxLines: 1,
      overflow: TextOverflow.ellipsis
    );
  }

  List<TextSpan> _getSpans({
    required String text,
    required String word,
    required TextStyle styleOrigin,
    required TextStyle styleWord,
  }) {
    List<TextSpan> spans = [];
    int spanBoundary = 0;
    do {
      // look for the next match
      final startIndex = text.toLowerCase().indexOf(word.toLowerCase(), spanBoundary);
      // if no more matches then add the rest of the string without style
      if (startIndex == -1) {
        spans.add(TextSpan(text: text.substring(spanBoundary), style: styleOrigin));
        return spans;
      }
      // add any unStyled text before the next match
      if (startIndex > spanBoundary) {
        spans.add(TextSpan(text: text.substring(spanBoundary, startIndex), style: styleOrigin));
      }
      // style the matched text
      final endIndex = startIndex + word.length;
      final spanText = text.substring(startIndex, endIndex);
      spans.add(TextSpan(text: spanText, style: styleWord));
      // mark the boundary to start the next search from
      spanBoundary = endIndex;
      // continue until there are no more matches
    } while (spanBoundary < text.length);

    return spans;
  }
}