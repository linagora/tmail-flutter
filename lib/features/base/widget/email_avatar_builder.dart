
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';

class EmailAvatarBuilder extends StatelessWidget {

  final String avatarText;
  final OnTapAvatarActionClick? onTapAvatarActionClick;
  final double? size;
  final List<Color>? avatarColors;

  const EmailAvatarBuilder({
    Key? key,
    required this.avatarText,
    this.onTapAvatarActionClick,
    this.size,
    this.avatarColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (AvatarBuilder()
      ..text(avatarText)
      ..size(size ?? 50)
      ..addTextStyle(ThemeUtils.textStyleHeadingH4(color: Colors.white))
      ..backgroundColor(AppColor.colorAvatar)
      ..addOnTapActionClick(onTapAvatarActionClick ?? () {})
      ..avatarColor(avatarColors))
    .build();
  }
}