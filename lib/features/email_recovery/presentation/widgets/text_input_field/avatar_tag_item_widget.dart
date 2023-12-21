import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/text_input_field/avatar_tag_item_widget_styles.dart';

class AvatarTagItemWidget extends StatelessWidget {
  final String tagName;

  const AvatarTagItemWidget({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AvatarTagItemWidgetStyles.size,
      height: AvatarTagItemWidgetStyles.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:AppColor.mapGradientColor[_generateIndex(tagName)]
        ),
        border: Border.all(
          color: AppColor.colorShadowBgContentEmail,
          width: AvatarTagItemWidgetStyles.borderWidth
        ),
      ),
      child: Text(
        tagName.isNotEmpty ? tagName[0].toUpperCase() : '',
        style: AvatarTagItemWidgetStyles.textStyle
      ),
    );
  }

  int _generateIndex(String tag) {
    if (tag.isNotEmpty) {
      final codeUnits = tag.codeUnits;
      if (codeUnits.isNotEmpty) {
        final sumCodeUnits = codeUnits.sum;
        final index = sumCodeUnits % AppColor.mapGradientColor.length;
        return index;
      }
    }
    return 0;
  }
}