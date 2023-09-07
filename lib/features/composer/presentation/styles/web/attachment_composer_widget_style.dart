import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AttachmentComposerWidgetStyle {
  static const double maxHeight = 150;
  static const double listItemSpace = 8;

  static const Color backgroundColor = Colors.white;

  static const EdgeInsetsGeometry listItemPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16);

  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: AppColor.colorShadowBgContentEmail,
      blurRadius: 24
    ),
    BoxShadow(
      color: AppColor.colorShadowBgContentEmail,
      blurRadius: 2
    ),
  ];
}