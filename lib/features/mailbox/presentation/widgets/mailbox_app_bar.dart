import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/base/widget/user_avatar_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/app_grid/app_grid_icon.dart';

typedef OnOpenSettingsAction = void Function();
typedef OnOpenAppGridAction = void Function();

class MailboxAppBar extends StatelessWidget {
  final ImagePaths imagePaths;
  final String username;
  final OnOpenSettingsAction? openSettingsAction;
  final OnOpenAppGridAction? onOpenAppGridAction;

  const MailboxAppBar({
    super.key,
    required this.imagePaths,
    required this.username,
    this.openSettingsAction,
    this.onOpenAppGridAction,
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
          if (onOpenAppGridAction != null)
            AppGridIcon(
              icon: imagePaths.icAppDashboard,
              onTapAction: onOpenAppGridAction!,
            ),
          UserAvatarBuilder(
            username: username,
            padding: const EdgeInsetsDirectional.only(start: 4),
            onTapAction: openSettingsAction,
          ),
        ],
      ),
    );
  }
}
