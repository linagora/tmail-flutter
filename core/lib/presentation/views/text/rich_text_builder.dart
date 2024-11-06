import 'package:flutter/material.dart';

class RichTextBuilder extends StatefulWidget {

  final String textOrigin;
  final String wordToStyle;
  final TextStyle styleOrigin;
  final TextStyle styleWord;
  final String? preMarkedText;
  final bool ensureHighlightVisible;
  final bool? softWrap;

  const RichTextBuilder({
    super.key,
    required this.textOrigin,
    required this.wordToStyle,
    required this.styleOrigin,
    required this.styleWord,
    this.preMarkedText,
    this.ensureHighlightVisible = false,
    this.softWrap,
  });

  @override
  State<RichTextBuilder> createState() => _RichTextBuilderState();
}

class _RichTextBuilderState extends State<RichTextBuilder> with AutomaticKeepAliveClientMixin {
  static const String _startMark = '<mark>';
  static const String _endMark = '</mark>';
  final firstHighlightKey = GlobalKey();
  bool firstHighlightKeyed = false;

  void scrollDebounceListener() {
    if (!firstHighlightKeyed) return;
    if (firstHighlightKey.currentContext == null) return;

    final scrollable = Scrollable.maybeOf(
      firstHighlightKey.currentContext!,
      axis: Axis.horizontal);
    final renderBox = firstHighlightKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      scrollable?.position.ensureVisible(
        renderBox,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final text = Text.rich(
      TextSpan(
        style: widget.styleOrigin,
        children: widget.preMarkedText != null
          ? _getSpansFromPreMarkedText()
          : _getSpans(
              text: widget.textOrigin,
              word: widget.wordToStyle,
              styleOrigin: widget.styleOrigin,
              styleWord: widget.styleWord,
            )
      ),
      style: widget.styleOrigin,
      maxLines: 1,
      softWrap: widget.softWrap,
      overflow: TextOverflow.ellipsis
    );

    if (!widget.ensureHighlightVisible) return text;

    if (noHighlightAvailable) return text;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollDebounceListener();
    });

    return SingleChildScrollView(
      key: const PageStorageKey('rich_text_builder'),
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: text,
    );
  }

  bool get noHighlightAvailable {
    return widget.preMarkedText == null
      && widget.wordToStyle.isNotEmpty
      && !widget.textOrigin.toLowerCase().contains(widget.wordToStyle.toLowerCase());
  }

  List<InlineSpan> _getSpans({
    required String text,
    required String word,
    required TextStyle styleOrigin,
    required TextStyle styleWord,
  }) {
    if (word.isEmpty) {
      return [TextSpan(text: text, style: styleOrigin)];
    }

    List<InlineSpan> spans = [];
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

      if (!firstHighlightKeyed) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Text(
            spanText,
            key: firstHighlightKey,
            style: styleWord,
          ),
        ));
        firstHighlightKeyed = true;
      } else {
        spans.add(TextSpan(text: spanText, style: styleWord));
      }
      // mark the boundary to start the next search from
      spanBoundary = endIndex;
      // continue until there are no more matches
    } while (spanBoundary < text.length);

    return spans;
  }

  List<InlineSpan> _getSpansFromPreMarkedText() {
    List<InlineSpan> spans = [];
    String? processingText = widget.preMarkedText;
    
    while (processingText != null && processingText.isNotEmpty) {
      final startIndex = processingText.indexOf(_startMark);

      // There is no more <mark> in the text
      if (startIndex == -1) {
        spans.add(TextSpan(text: processingText, style: widget.styleOrigin));
        return spans;
      }

      final endIndex = processingText.indexOf(
        _endMark,
        startIndex + _startMark.length);
      // There is start <mark> but no end </mark>
      if (endIndex == -1) {
        spans.add(TextSpan(text: processingText, style: widget.styleOrigin));
        return spans;
      }
      
      // <mark> is not the left most in the text
      if (startIndex > 0) {
        spans.add(TextSpan(
          text: processingText.substring(0, startIndex),
          style: widget.styleOrigin));
      }

      // style the marked text
      final markedText = processingText.substring(
        startIndex + _startMark.length,
        endIndex);
      if (!firstHighlightKeyed) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Text(
            markedText,
            key: firstHighlightKey,
            style: widget.styleWord,
          ),
        ));
        firstHighlightKeyed = true;
      } else {
        spans.add(TextSpan( 
          text: markedText,
          style: widget.styleWord));
      }

      // Process the next <mark>
      processingText = processingText.substring(endIndex + _endMark.length);
    }

    return spans;
  }
  
  @override
  bool get wantKeepAlive => widget.ensureHighlightVisible;
}