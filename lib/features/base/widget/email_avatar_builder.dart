
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';

class EmailAvatarBuilder extends StatelessWidget {

  final PresentationEmail emailSelected;

  const EmailAvatarBuilder({
    Key? key,
    required this.emailSelected
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (AvatarBuilder()
      ..text(emailSelected.getAvatarText())
      ..size(50)
      ..addTextStyle(const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 21,
          color: Colors.white))
      ..backgroundColor(AppColor.colorAvatar)
      ..avatarColor(emailSelected.avatarColors))
    .build();
  }
}