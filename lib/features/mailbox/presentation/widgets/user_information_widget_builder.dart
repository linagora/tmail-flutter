
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      key: Key('user_information_widget'),
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () {},
        leading: Transform(
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: (AvatarBuilder()
              ..text(_userProfile != null ? _userProfile!.getAvatarText() : '')
              ..backgroundColor(Colors.white)
              ..textColor(Colors.black)
              ..addBoxShadows([BoxShadow(
                color: AppColor.colorShadowBgContentEmail,
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 1), // changes position of shadow
              )])
              ..size(56))
            .build(),
        ),
        title: Transform(
          transform: Matrix4.translationValues(8.0, 16.0, 0.0),
          child: Text(
            _userProfile != null ? _userProfile!.email : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 17, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600))
        ),
        subtitle: Transform(
          transform: Matrix4.translationValues(0.0, 8.0, 0.0),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _onLogoutActionClick?.call(),
                child: Text(
                  AppLocalizations.of(_context).logout,
                  style: TextStyle(fontSize: 14, color: AppColor.colorTextButton),
                ),
              )
            )
          )
        ),
        trailing: Transform(
          transform: Matrix4.translationValues(10.0, 0.0, 0.0),
          child: IconButton(
            icon: SvgPicture.asset(_imagePaths.icNextArrow, width: 7, height: 12, fit: BoxFit.fill, color: AppColor.colorArrowUserMailbox),
            onPressed: () => {}))),
    );
  }
}