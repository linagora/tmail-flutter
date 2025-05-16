
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';

class EmailAvatarBuilder extends StatelessWidget {

  final PresentationEmail emailSelected;
  final OnTapAvatarActionClick? onTapAvatarActionClick;

  const EmailAvatarBuilder({
    Key? key,
    required this.emailSelected,
    this.onTapAvatarActionClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (AvatarBuilder()
      ..text(emailSelected.getAvatarText())
      ..size(50)
      ..addTextStyle(ThemeUtils.textStyleHeadingH4(color: Colors.white))
      ..backgroundColor(AppColor.colorAvatar)
      ..addOnTapActionClick(onTapAvatarActionClick ?? () {})
      ..avatarColor(emailSelected.avatarColors))
    .build();
  }
}