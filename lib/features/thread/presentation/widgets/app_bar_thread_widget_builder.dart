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
      children: [
        GestureDetector(
          onTap: () => {
            if (_onOpenListMailboxActionClick != null) {
              _onOpenListMailboxActionClick!()
            }},
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Container(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              constraints: BoxConstraints(maxWidth: _getMaxWidthAppBarTitle()),
              child: Text(
                '${ _presentationMailbox?.name?.name ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 22, color: AppColor.titleAppBarMailboxListMail, fontWeight: FontWeight.w500))
            ))),
        if(_presentationMailbox?.getCountUnReadEmails().isNotEmpty == true)
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(left: 8, right: 8, top: 2.5, bottom: 2.5),
            decoration:BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColor.backgroundCounterMailboxColor),
            child: Text(
              '${_presentationMailbox?.getCountUnReadEmails() ?? ''} ${AppLocalizations.of(_context).unread_email_notification}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: AppColor.counterMailboxColor, fontWeight: FontWeight.w500),
            )),
      ]
    );
  }

  double _getMaxWidthAppBarTitle() {
    var width = MediaQuery.of(_context).size.width;
    var widthSiblingsWidget = _presentationMailbox?.getCountUnReadEmails().isNotEmpty == true
      ? 150
      : 100;
    if (_responsiveUtils.isTablet(_context)) {
      width = width * 0.7;
      widthSiblingsWidget = _presentationMailbox?.getCountUnReadEmails().isNotEmpty == true
        ? 70
        : 0;
    } else if (_responsiveUtils.isDesktop(_context)) {
      width = width * 0.2;
      widthSiblingsWidget = _presentationMailbox?.getCountUnReadEmails().isNotEmpty == true
        ? 50
        : 0;
    }
    final maxWidth = width - widthSiblingsWidget;
    return maxWidth;
  }
}