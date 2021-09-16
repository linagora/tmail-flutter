import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';

typedef OnOpenUserInformationActionClick = void Function();

class UserInformationWidgetBuilder {
  final ImagePaths _imagePaths;
  final UserProfile? _userProfile;

  OnOpenUserInformationActionClick? _onOpenUserInformationActionClick;

  UserInformationWidgetBuilder(this._imagePaths, this._userProfile);

  UserInformationWidgetBuilder onOpenUserInformationAction(
      OnOpenUserInformationActionClick onOpenUserInformationActionClick) {
    _onOpenUserInformationActionClick = onOpenUserInformationActionClick;
    return this;
  }

  Widget build() {
    return Container(
      key: Key('user_information_widget'),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColor.userInformationBackgroundColor),
      child: ListTile(
        onTap: () {
          if (_onOpenUserInformationActionClick != null) {
            _onOpenUserInformationActionClick!();
          }
        },
        leading: AvatarBuilder()
          .text(_userProfile != null ? _userProfile!.getAvatarText() : '')
          .size(40)
          .build(),
        title: Transform(
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: Text(
            _userProfile != null ? _userProfile!.email : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: AppColor.nameUserColor, fontWeight: FontWeight.w500),
          )),
        trailing: Transform(
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: IconButton(
            icon: SvgPicture.asset(_imagePaths.icNextArrow, width: 7, height: 12, fit: BoxFit.fill),
            onPressed: () => {}))),
    );
  }
}