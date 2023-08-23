import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/avatar_tag_item_style.dart';

class AvatarTagItemWidget extends StatelessWidget {
  final String tagName;

  const AvatarTagItemWidget({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AvatarTagItemStyle.iconSize,
      height: AvatarTagItemStyle.iconSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColor.mapGradientColor[_generateIndex(tagName)],
        ),
        border: Border.all(
          color: AvatarTagItemStyle.iconBorderColor,
          width: AvatarTagItemStyle.iconBorderSize
        )
      ),
      child: Text(
        tagName.isNotEmpty ? tagName[0].toUpperCase() : '',
        style: AvatarTagItemStyle.labelTextStyle
      )
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
