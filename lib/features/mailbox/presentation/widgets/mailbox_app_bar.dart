import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/base/widget/user_avatar_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/app_grid/app_grid_icon.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/support/contact_support_icon.dart';

typedef OnOpenSettingsAction = void Function();
typedef OnOpenAppGridAction = void Function();
typedef OnOpenContactSupportAction = void Function();

class MailboxAppBar extends StatelessWidget {
  final ImagePaths imagePaths;
  final String username;
  final OnOpenSettingsAction? openSettingsAction;
  final OnOpenAppGridAction? openAppGridAction;
  final OnOpenContactSupportAction? openContactSupportAction;

  const MailboxAppBar({
    super.key,
    required this.imagePaths,
    required this.username,
    this.openSettingsAction,
    this.openAppGridAction,
    this.openContactSupportAction,
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
          if (openContactSupportAction != null)
            ContactSupportIcon(
              icon: imagePaths.icHelp,
              onTapAction: openContactSupportAction!,
            ),
          if (openAppGridAction != null)
            AppGridIcon(
              icon: imagePaths.icAppDashboard,
              onTapAction: openAppGridAction!,
            ),
          UserAvatarBuilder(
            username: username.firstLetterToUpperCase,
            padding: const EdgeInsetsDirectional.only(start: 4),
            onTapAction: openSettingsAction,
          ),
        ],
      ),
    );
  }
}
