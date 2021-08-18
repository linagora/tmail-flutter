import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/presentation_email_extension.dart';

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
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 6),
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
            contentPadding: EdgeInsets.zero,
            onTap: () => {
              if (_onOpenMailActionClick != null) {
                _onOpenMailActionClick!()
              }
            },
            leading: Transform(
              transform: Matrix4.translationValues(-10.0, -10.0, 0.0),
              child: AvatarBuilder()
                .text('${_presentationEmail.getAvatarText()}')
                .size(40)
                .iconStatus(_imagePaths.icOffline)
                .build()),
            title: Transform(
              transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${_presentationEmail.getSenderName().inCaps}',
                      maxLines: 1,
                      overflow:TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.mailboxTextColor,
                        fontWeight: _presentationEmail.isUnReadEmail() ? FontWeight.bold : FontWeight.w500))),
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text(
                      '${_presentationEmail.getTimeSentEmail('${Localizations.localeOf(_context).languageCode}_${Localizations.localeOf(_context).countryCode}')}',
                      maxLines: 1,
                      overflow:TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: _presentationEmail.isUnReadEmail() ? AppColor.sentTimeTextColorUnRead : AppColor.baseTextColor)))
                ],
              )
            ),
            subtitle: Transform(
              transform: Matrix4.translationValues(-10.0, 8.0, 0.0),
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
                          color: _presentationEmail.isUnReadEmail() ? AppColor.subjectEmailTextColorUnRead : AppColor.baseTextColor,
                          fontWeight: _presentationEmail.isUnReadEmail() ? FontWeight.bold : FontWeight.w500))),
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
                      if (_presentationEmail.hasAttachment == true) ButtonBuilder(_imagePaths.icShare).padding(2).build(),
                      SizedBox(width: 2),
                      ButtonBuilder(_presentationEmail.isFlaggedEmail() ? _imagePaths.icFlagged : _imagePaths.icFlag)
                          .padding(2)
                          .build(),
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