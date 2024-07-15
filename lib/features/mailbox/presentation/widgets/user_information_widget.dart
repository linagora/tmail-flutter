
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/username_extension.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSubtitleClick = void Function();

class UserInformationWidget extends StatelessWidget {
  final UserName? userName;
  final String? subtitle;
  final EdgeInsetsGeometry? titlePadding;
  final OnSubtitleClick? onSubtitleClick;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const UserInformationWidget({
    Key? key,
    this.userName,
    this.subtitle,
    this.titlePadding,
    this.onSubtitleClick,
    this.padding,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsetsDirectional.only(start: 16, end: 4, top: 16, bottom: 16),
      decoration: BoxDecoration(border: border),
      child: Row(children: [
        (AvatarBuilder()
            ..text(userName?.firstCharacter ?? '')
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
            SelectableText(
              userName?.value ?? '',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 17,
                color: AppColor.colorNameEmail,
                fontWeight: FontWeight.w600
              )
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 10),
                child: Transform(
                  transform: Matrix4.translationValues(-8.0, 0.0, 0.0),
                  child: MaterialTextButton(
                    label: AppLocalizations.of(context).manage_account,
                    onTap: onSubtitleClick,
                    borderRadius: 20,
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
                    customStyle: const TextStyle(fontSize: 14, color: AppColor.colorTextButton),
                  ),
                ),
              )
        ])),
        const SizedBox(width: 16),
      ]),
    );
  }
}