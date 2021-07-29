import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';

typedef OnOpenMailActionClick = void Function();

class MailTileBuilder {

  final SelectMode _selectMode;
  final ImagePaths _imagePaths;
  final PresentationMail _presentationMail;

  OnOpenMailActionClick? _onOpenMailActionClick;

  MailTileBuilder(
    this._imagePaths,
    this._selectMode,
    this._presentationMail,
  );

  MailTileBuilder onOpenMailAction(OnOpenMailActionClick onOpenMailActionClick) {
    _onOpenMailActionClick = onOpenMailActionClick;
    return this;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: Key('mail_list_tile'),
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _selectMode== SelectMode.ACTIVE
            ? AppColor.mailboxSelectedBackgroundColor
            : AppColor.mailboxBackgroundColor),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: ListTile(
            focusColor: AppColor.primaryLightColor,
            hoverColor: AppColor.primaryLightColor,
            contentPadding: EdgeInsets.zero,
            onTap: () => {
              if (_onOpenMailActionClick != null) {
                _onOpenMailActionClick!()
              }
            },
            leading: Transform(
              transform: Matrix4.translationValues(0.0, -12.0, 0.0),
              child: SvgPicture.asset(
                _imagePaths.icTMailLogo,
                width: 32,
                height: 32,
                color: _selectMode == SelectMode.ACTIVE ? AppColor.mailboxSelectedIconColor : AppColor.mailboxIconColor,
                fit: BoxFit.fill)),
            title: Padding(
              padding: EdgeInsets.only(left: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'TMail app',
                      maxLines: 1,
                      overflow:TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectMode == SelectMode.ACTIVE ? AppColor.mailboxSelectedTextColor : AppColor.mailboxTextColor,
                        fontWeight: FontWeight.bold))),
                  Text(
                    '9:29 AM',
                    maxLines: 1,
                    overflow:TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: _selectMode == SelectMode.ACTIVE ? AppColor.mailboxSelectedTextColor : AppColor.mailboxTextColor))
                ],
              )
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(left: 0, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Welcome to TMail!',
                      maxLines: 1,
                      overflow:TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColor.appColor,
                          fontWeight: FontWeight.bold))),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${_presentationMail.message}',
                          maxLines: 1,
                          overflow:TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: AppColor.baseTextColor))),
                      ButtonBuilder(_imagePaths.icCalendar).build(),
                      SizedBox(width: 12),
                      ButtonBuilder(_imagePaths.icShare).build(),
                      SizedBox(width: 12),
                      ButtonBuilder(_imagePaths.icStar).build(),
                    ],
                  )
                ],
              )
            ),
          ),
        )
      )
    );
  }
}