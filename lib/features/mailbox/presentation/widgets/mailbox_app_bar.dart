import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/base/widget/user_avatar_builder.dart';

typedef OnOpenSettingsAction = void Function();

class MailboxAppBar extends StatelessWidget {
  final String username;
  final OnOpenSettingsAction? openSettingsAction;

  const MailboxAppBar({
    super.key,
    required this.username,
    this.openSettingsAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      height: 50,
      child: Row(
        children: [
          ApplicationLogoWidthTextWidget(iconSize: 22),
          const Spacer(),
          UserAvatarBuilder(
            username: username,
            onTapAction: openSettingsAction,
          ),
        ],
      ),
    );
  }
}
