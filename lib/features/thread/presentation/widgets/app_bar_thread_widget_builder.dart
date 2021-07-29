import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

typedef OnOpenSearchMailActionClick = void Function();
typedef OnOpenListMailboxActionClick = void Function();
typedef OnOpenUserInformationActionClick = void Function();

class AppBarThreadWidgetBuilder {
  OnOpenSearchMailActionClick? _onOpenSearchMailActionClick;
  OnOpenListMailboxActionClick? _onOpenListMailboxActionClick;
  OnOpenUserInformationActionClick? _onOpenUserInformationActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final PresentationMailbox _presentationMailbox;

  AppBarThreadWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox
  );

  AppBarThreadWidgetBuilder onOpenUserInformationAction(
      OnOpenUserInformationActionClick onOpenUserInformationActionClick) {
    _onOpenUserInformationActionClick = onOpenUserInformationActionClick;
    return this;
  }

  AppBarThreadWidgetBuilder onOpenSearchMailActionClick(
      OnOpenSearchMailActionClick onOpenSearchMailActionClick) {
    _onOpenSearchMailActionClick = onOpenSearchMailActionClick;
    return this;
  }

  AppBarThreadWidgetBuilder onOpenListMailboxActionClick(
      OnOpenListMailboxActionClick onOpenListMailboxActionClick) {
    _onOpenListMailboxActionClick = onOpenListMailboxActionClick;
    return this;
  }

  Widget build() {
    return Container(
      key: Key('app_bar_thread_widget'),
      alignment: Alignment.center,
      color: Colors.white,
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_responsiveUtils.isMobile(_context)) _buildIconUser(),
            Expanded(child: _buildContentCenterAppBar()),
            _buildIconSearch(),
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
        padding: EdgeInsets.only(left: _responsiveUtils.isMobile(_context) ? 24 : 0),
        child: SvgPicture.asset(_imagePaths.icTMailLogo, width: 24, height: 24, fit: BoxFit.fill)));
  }

  Widget _buildIconSearch() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 0),
      child: IconButton(
        icon: SvgPicture.asset(_imagePaths.icSearch, width: 24, height: 24, fit: BoxFit.fill),
        onPressed: () => {
          if (_onOpenSearchMailActionClick != null) {
            _onOpenSearchMailActionClick!()
          }
        }
      ));
  }

  Widget _buildContentCenterAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => {
            if (_onOpenListMailboxActionClick != null) {
              _onOpenListMailboxActionClick!()
            }},
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '${_presentationMailbox.name?.name}',
              maxLines: 1,
              style: TextStyle(fontSize: 22, color: AppColor.titleAppBarMailboxListMail, fontWeight: FontWeight.w500),
            ))),
        if(_presentationMailbox.getCountUnReadEmails().isNotEmpty)
          Container(
            margin: EdgeInsets.only(left: 9),
            padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
            decoration:BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColor.bgNotifyCountAppBarMailboxListMail),
            child: Text(
              '${_presentationMailbox.getCountUnReadEmails()} new',
              maxLines: 1,
              style: TextStyle(fontSize: 10, color: AppColor.notifyCountAppBarMailboxListMail, fontWeight: FontWeight.w500),
            ))
      ]
    );
  }
}