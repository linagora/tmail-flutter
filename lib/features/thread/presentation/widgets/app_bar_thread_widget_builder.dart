import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenSearchMailActionClick = void Function();
typedef OnOpenListMailboxActionClick = void Function();
typedef OnOpenUserInformationActionClick = void Function();

class AppBarThreadWidgetBuilder {
  // OnOpenSearchMailActionClick? _onOpenSearchMailActionClick;
  OnOpenListMailboxActionClick? _onOpenListMailboxActionClick;
  OnOpenUserInformationActionClick? _onOpenUserInformationActionClick;

  final BuildContext _context;
  // final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final PresentationMailbox? _presentationMailbox;
  final UserProfile? _userProfile;

  AppBarThreadWidgetBuilder(
    this._context,
    // this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox,
    this._userProfile,
  );

  void onOpenUserInformationAction(
      OnOpenUserInformationActionClick onOpenUserInformationActionClick) {
    _onOpenUserInformationActionClick = onOpenUserInformationActionClick;
  }

  // void onOpenSearchMailActionClick(OnOpenSearchMailActionClick onOpenSearchMailActionClick) {
  //   _onOpenSearchMailActionClick = onOpenSearchMailActionClick;
  // }

  void onOpenListMailboxActionClick(OnOpenListMailboxActionClick onOpenListMailboxActionClick) {
    _onOpenListMailboxActionClick = onOpenListMailboxActionClick;
  }

  Widget build() {
    return Container(
      key: Key('app_bar_thread_widget'),
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_responsiveUtils.isMobile(_context)) _buildIconUser(),
            Expanded(child: _buildContentCenterAppBar()),
            // _buildIconSearch(),
          ]
        )
      )
    );
  }

  Widget _buildIconUser() {
    return GestureDetector(
      onTap: () => {
        if (_onOpenUserInformationActionClick != null) {
          _onOpenUserInformationActionClick!()
        }},
      child: Padding(
        padding: EdgeInsets.zero,
        child: AvatarBuilder()
          .text(_userProfile != null ? _userProfile!.getAvatarText() : '')
          .size(36)
          .build()));
  }

  // Widget _buildIconSearch() {
  //   return Padding(
  //     padding: EdgeInsets.only(left: 16),
  //     child: IconButton(
  //       color: AppColor.baseTextColor,
  //       icon: SvgPicture.asset(_imagePaths.icSearch, color: AppColor.baseTextColor, fit: BoxFit.fill),
  //       onPressed: () => {
  //         if (_onOpenSearchMailActionClick != null) {
  //           _onOpenSearchMailActionClick!()
  //         }
  //       }
  //     ));
  // }

  Widget _buildContentCenterAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (_presentationMailbox != null && _presentationMailbox!.hasRole())
          ? GestureDetector(
              onTap: () => {
                if (_onOpenListMailboxActionClick != null) {
                  _onOpenListMailboxActionClick!()
                }},
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  '${_presentationMailbox?.name != null ? _presentationMailbox?.name?.name : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 22, color: AppColor.titleAppBarMailboxListMail, fontWeight: FontWeight.w500))))
          : Expanded(child: GestureDetector(
              onTap: () => {
                if (_onOpenListMailboxActionClick != null) {
                  _onOpenListMailboxActionClick!()
                }},
              child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    '${_presentationMailbox?.name != null ? _presentationMailbox?.name?.name : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 22, color: AppColor.titleAppBarMailboxListMail, fontWeight: FontWeight.w500))))),
        if(_presentationMailbox != null && _presentationMailbox!.hasRole() && _presentationMailbox!.getCountUnReadEmails().isNotEmpty)
          Container(
            margin: EdgeInsets.only(left: 9),
            padding: EdgeInsets.only(left: 8, right: 8, top: 2.5, bottom: 2.5),
            decoration:BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColor.bgNotifyCountAppBarMailboxListMail),
            child: Text(
              '${_presentationMailbox!.getCountUnReadEmails()} ${AppLocalizations.of(_context).unread_email_notification}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: AppColor.notifyCountAppBarMailboxListMail, fontWeight: FontWeight.w500),
            )),
      ]
    );
  }
}