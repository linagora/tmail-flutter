
import 'package:flutter/material.dart';

class TextOverflowBuilder extends StatelessWidget {

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? softWrap;
  final int? maxLines;
  final TextDirection? textDirection;
  final TextOverflow? overflow;

  const TextOverflowBuilder(
    this.data,
    {
      super.key,
      this.style,
      this.textAlign,
      this.softWrap = true,
      this.maxLines = 1,
      this.textDirection,
      this.overflow = TextOverflow.ellipsis,
    }
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
      textDirection: textDirection,
      overflow: overflow,
    );
  }
}