import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/oidc_user_info_extension.dart';
import 'package:model/oidc/response/oidc_user_info.dart';
import 'package:tmail_ui_user/features/base/widget/user_avatar_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenCommonSetting = void Function(OidcUserInfo oidcUserInfo);

class SettingUserInfoWidget extends StatelessWidget {
  final String ownEmailAddress;
  final String ownDisplayName;
  final OidcUserInfo? oidcUserInfo;
  final ImagePaths imagePaths;
  final OnOpenCommonSetting? onOpenCommonSetting;

  const SettingUserInfoWidget({
    Key? key,
    required this.ownEmailAddress,
    required this.imagePaths,
    this.ownDisplayName = '',
    this.oidcUserInfo,
    this.onOpenCommonSetting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              UserAvatarBuilder(
                username: ownEmailAddress.firstLetterToUpperCase,
                size: 94,
                textStyle: ThemeUtils.textStyleInter500().copyWith(
                  fontSize: 50,
                  height: 80 / 50,
                  letterSpacing: 0.24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ownDisplayName.isNotEmpty)
                      Text(
                        ownDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ThemeUtils.textStyleInter600().copyWith(
                          fontSize: 22,
                          height: 28 / 22,
                          color: AppColor.gray424244,
                        ),
                      ),
                    Text(
                      ownEmailAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ThemeUtils.textStyleM3BodyMedium.copyWith(
                        color: AppColor.textSecondary.withValues(alpha: 0.48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (oidcUserInfo?.isWorkplaceFqdnValid == true)
            Container(
              constraints: const BoxConstraints(minWidth: 253),
              height: 40,
              margin: const EdgeInsetsDirectional.only(top: 16),
              child: ConfirmDialogButton(
                label: AppLocalizations.of(context).manageYourTwakeAccount,
                backgroundColor: Colors.white,
                textColor: AppColor.primaryMain,
                borderColor: AppColor.primaryMain,
                icon: imagePaths.icUser,
                iconSize: 18,
                onTapAction: () => onOpenCommonSetting?.call(oidcUserInfo!),
              ),
            )
        ],
      ),
    );
  }
}
