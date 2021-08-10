import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';

typedef OnOpenMailActionClick = void Function();

class EmailTileBuilder {

  final SelectMode _selectMode;
  final ImagePaths _imagePaths;
  final PresentationEmail _presentationEmail;
  final BuildContext _context;
  final ResponsiveUtils _responsiveUtils;

  OnOpenMailActionClick? _onOpenMailActionClick;

  EmailTileBuilder(
    this._context,
    this._imagePaths,
    this._selectMode,
    this._presentationEmail,
    this._responsiveUtils,
  );

  EmailTileBuilder onOpenMailAction(OnOpenMailActionClick onOpenMailActionClick) {
    _onOpenMailActionClick = onOpenMailActionClick;
    return this;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: Key('thread_tile'),
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _selectMode== SelectMode.ACTIVE
            ? _responsiveUtils.isDesktop(_context)
              ? AppColor.mailboxSelectedBackgroundColor
              : _responsiveUtils.isMobile(_context) ? AppColor.bgMailboxListMail : Colors.white
            : _responsiveUtils.isMobile(_context) ? AppColor.bgMailboxListMail : Colors.white),
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
                color: _selectMode == SelectMode.ACTIVE
                    ? _responsiveUtils.isDesktop(_context) ? AppColor.mailboxSelectedIconColor : AppColor.mailboxIconColor
                    : AppColor.mailboxIconColor,
                fit: BoxFit.fill)),
            title: Padding(
              padding: EdgeInsets.only(left: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${_presentationEmail.getSenderName()}',
                      maxLines: 1,
                      overflow:TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectMode == SelectMode.ACTIVE
                            ? _responsiveUtils.isDesktop(_context) ? AppColor.mailboxSelectedTextColor : AppColor.mailboxTextColor
                            : AppColor.mailboxTextColor,
                        fontWeight: FontWeight.bold))),
                  Text(
                    '${_presentationEmail.getTimeThisYear()}',
                    maxLines: 1,
                    overflow:TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: _selectMode == SelectMode.ACTIVE
                          ? _responsiveUtils.isDesktop(_context) ? AppColor.mailboxSelectedTextColor : AppColor.mailboxTextColor
                          : AppColor.mailboxTextColor))
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
                      '${_presentationEmail.getEmailTitle()}',
                      maxLines: 1,
                      overflow:TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColor.baseTextColor,
                          fontWeight: FontWeight.bold))),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${_presentationEmail.getPartialContent()}',
                          maxLines: 1,
                          overflow:TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: AppColor.baseTextColor))),
                      if (_presentationEmail.hasAttachment == true) ButtonBuilder(_imagePaths.icShare).build(),
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