
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';

class TextOverflowBuilder extends StatelessWidget {

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? softWrap;
  final int? maxLines;
  final TextDirection? textDirection;
  final TextOverflow? overflow;

  const TextOverflowBuilder(this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.softWrap = CommonTextStyle.defaultSoftWrap,
    this.maxLines = 1,
    this.textDirection,
    this.overflow = CommonTextStyle.defaultTextOverFlow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data.overflow,
      style: style,
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
      textDirection: textDirection,
      overflow: overflow,
    );
  }
}