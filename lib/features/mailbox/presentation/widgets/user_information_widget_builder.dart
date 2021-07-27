import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

typedef OnOpenUserInformationActionClick = void Function();

class UserInformationWidgetBuilder {
  final imagePath = Get.find<ImagePaths>();

  OnOpenUserInformationActionClick? _onOpenUserInformationActionClick;

  UserInformationWidgetBuilder();

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
        leading: SvgPicture.asset(imagePath.icTMailLogo, width: 40, height: 40, fit: BoxFit.fill),
        title: Transform(
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: Text(
            'John Doe',
            maxLines: 1,
            style: TextStyle(fontSize: 16, color: AppColor.nameUserColor, fontWeight: FontWeight.w500),
          )),
        subtitle: Transform(
          transform: Matrix4.translationValues(0.0, 4.0, 0.0),
          child: Text(
            'user@example.com',
            maxLines: 1,
            style: TextStyle(fontSize: 12, color: AppColor.emailUserColor, fontWeight: FontWeight.w500),
          )),
        trailing: Transform(
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: IconButton(
            icon: SvgPicture.asset(imagePath.icNextArrow, width: 7, height: 12, fit: BoxFit.fill),
            onPressed: () => {}))),
    );
  }
}