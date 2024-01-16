
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/user/user_profile.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AccountProfileWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final UserProfile? userProfile;
  final VoidCallback? onOpenAccountPicker;
  final EdgeInsetsGeometry? padding;

  const AccountProfileWidget({
    Key? key,
    required this.imagePaths,
    this.userProfile,
    this.onOpenAccountPicker,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarBuilder(
            text: userProfile?.getAvatarText() ?? '',
            size: 56,
            textColor: Colors.black,
            bgColor: Colors.white,
            boxShadows: const [
              BoxShadow(
                color: AppColor.colorShadowBgContentEmail,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 0.5)
              )
            ]
          ),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: TextOverflowBuilder(
                  userProfile?.email ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )
                ),
              ),
              TMailButtonWidget(
                text: AppLocalizations.of(context).switchAccounts,
                icon: imagePaths.icSwitchAccount,
                onTapActionCallback: onOpenAccountPicker,
                mainAxisSize: MainAxisSize.min,
                margin: const EdgeInsetsDirectional.only(start: 8),
                backgroundColor: Colors.transparent,
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColor.primaryColor
                ))
          ]))
        ]
      ),
    );
  }
}