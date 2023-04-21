
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnSubtitleClick = void Function();

class UserInformationWidgetBuilder extends StatelessWidget {
  final ImagePaths _imagePaths;
  final UserProfile? _userProfile;
  final String? subtitle;
  final EdgeInsets? titlePadding;
  final OnSubtitleClick? onSubtitleClick;

  const UserInformationWidgetBuilder(
    this._imagePaths,
    this._userProfile,
    {
      Key? key,
      this.subtitle,
      this.titlePadding,
      this.onSubtitleClick,
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('user_information_widget'),
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        (AvatarBuilder()
            ..text(_userProfile != null ? _userProfile!.getAvatarText() : '')
            ..backgroundColor(Colors.white)
            ..textColor(Colors.black)
            ..addBoxShadows([const BoxShadow(
                color: AppColor.colorShadowBgContentEmail,
                spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))])
            ..size(GetPlatform.isWeb ? 48 : 56))
          .build(),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: titlePadding ?? EdgeInsets.only(
                  left: AppUtils.isDirectionRTL(context) ? 0 : 16,
                  right: AppUtils.isDirectionRTL(context) ? 16 : 0,
                  top: 10
                ),
                child: Text(
                    _userProfile != null ? '${_userProfile?.email}'.withUnicodeCharacter : '',
                    maxLines: 1,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    style: const TextStyle(fontSize: 17, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600)
                )
            ),
            subtitle != null
              ? Padding(
                  padding: EdgeInsets.only(
                    left: AppUtils.isDirectionRTL(context) ? 0 : 10,
                    right: AppUtils.isDirectionRTL(context) ? 10 : 0
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => onSubtitleClick?.call(),
                        child: Text(
                          AppLocalizations.of(context).manage_account,
                          style: const TextStyle(fontSize: 14, color: AppColor.colorTextButton),
                        ),
                      )
                    )
                  )
                )
              : const SizedBox.shrink()
        ])),
        if (!kIsWeb)
          Transform(
            transform: Matrix4.translationValues(
              AppUtils.isDirectionRTL(context) ? -14.0 : 14.0,
              0.0,
              0.0
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                AppUtils.isDirectionRTL(context) ? _imagePaths.icBack : _imagePaths.icCollapseFolder,
                fit: BoxFit.fill,
                colorFilter: AppColor.colorCollapseMailbox.asFilter()),
              onPressed: () => {}))
      ]),
    );
  }
}