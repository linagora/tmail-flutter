
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_button.dart';
import 'package:tmail_ui_user/features/base/widget/user_avatar_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSubtitleClick = void Function();

class UserInformationWidget extends StatelessWidget {

  final String ownEmailAddress;
  final String? subtitle;
  final EdgeInsetsGeometry? titlePadding;
  final OnSubtitleClick? onSubtitleClick;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const UserInformationWidget({
    Key? key,
    required this.ownEmailAddress,
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
        UserAvatarBuilder(
          username: ownEmailAddress.firstLetterToUpperCase,
          size: 51,
          textStyle: ThemeUtils.textStyleInter500().copyWith(
            fontSize: 25.5,
            height: 38.3 / 25.5,
            letterSpacing: 0.24,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              ownEmailAddress,
              maxLines: 1,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
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
                    customStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontSize: 14,
                      color: AppColor.colorTextButton,
                    ),
                  ),
                ),
              )
        ])),
        const SizedBox(width: 16),
      ]),
    );
  }
}