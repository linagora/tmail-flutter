
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/user/user_profile.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSubtitleClick = void Function();

class UserInformationWidgetBuilder extends StatelessWidget {
  final ImagePaths _imagePaths;
  final UserProfile? _userProfile;
  final String? subtitle;
  final EdgeInsetsGeometry? titlePadding;
  final OnSubtitleClick? onSubtitleClick;
  final EdgeInsetsGeometry? padding;

  const UserInformationWidgetBuilder(
    this._imagePaths,
    this._userProfile,
    {
      Key? key,
      this.subtitle,
      this.titlePadding,
      this.onSubtitleClick,
      this.padding,
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.only(start: 16, end: 4, top: 16, bottom: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        (AvatarBuilder()
            ..text(_userProfile != null ? _userProfile!.getAvatarText() : '')
            ..backgroundColor(Colors.white)
            ..textColor(Colors.black)
            ..addBoxShadows([const BoxShadow(
                color: AppColor.colorShadowBgContentEmail,
                spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))])
            ..size(PlatformInfo.isWeb ? 48 : 56))
          .build(),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextOverflowBuilder(
              _userProfile != null ? '${_userProfile?.email}' : '',
              style: const TextStyle(
                fontSize: 17,
                color: AppColor.colorNameEmail,
                fontWeight: FontWeight.w600
              )
            ),
            const SizedBox(height: 10),
            if (subtitle != null)
              Transform(
                transform: Matrix4.translationValues(-8.0, 0.0, 0.0),
                child: MaterialTextButton(
                  label: AppLocalizations.of(context).manage_account,
                  onTap: onSubtitleClick,
                  borderRadius: 20,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
                  customStyle: const TextStyle(fontSize: 14, color: AppColor.colorTextButton),
                ),
              )
        ])),
        if (PlatformInfo.isMobile)
          SvgPicture.asset(
            DirectionUtils.isDirectionRTLByLanguage(context) ? _imagePaths.icBack : _imagePaths.icCollapseFolder,
            fit: BoxFit.fill,
            colorFilter: AppColor.colorCollapseMailbox.asFilter()
          ),
        const SizedBox(width: 16),
      ]),
    );
  }
}