
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnLogoutActionClick = void Function();

class UserInformationWidgetBuilder {
  final ImagePaths _imagePaths;
  final UserProfile? _userProfile;
  final BuildContext _context;

  OnLogoutActionClick? _onLogoutActionClick;

  UserInformationWidgetBuilder(
    this._imagePaths,
    this._context,
    this._userProfile,
  );

  void addOnLogoutAction(OnLogoutActionClick onLogoutActionClick) {
    _onLogoutActionClick = onLogoutActionClick;
  }

  Widget build() {
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
                padding: const EdgeInsets.only(left: 16, top: 10),
                child: Text(
                    _userProfile != null ? '${_userProfile?.email}' : '',
                    maxLines: 1,
                    overflow: GetPlatform.isWeb ? TextOverflow.clip : TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600)
                )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _onLogoutActionClick?.call(),
                        child: Text(
                          AppLocalizations.of(_context).manage_account,
                          style: const TextStyle(fontSize: 14, color: AppColor.colorTextButton),
                        ),
                      )
                  )
              )
            )
        ])),
        if (!kIsWeb)
          Transform(
            transform: Matrix4.translationValues(14.0, 0.0, 0.0),
            child: IconButton(
              icon: SvgPicture.asset(_imagePaths.icCollapseFolder, fit: BoxFit.fill, color: AppColor.colorCollapseMailbox),
              onPressed: () => {}))
      ]),
    );
  }
}