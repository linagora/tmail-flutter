import 'dart:math';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

typedef OnOpenEmailActionClick = void Function(PresentationEmail selectedEmail);
typedef OnSelectEmailActionClick = void Function(PresentationEmail selectedEmail);
typedef OnMarkAsStarEmailActionClick = void Function(PresentationEmail selectedEmail);

class EmailTileBuilder {

  final SelectMode _selectMode;
  final ImagePaths _imagePaths;
  final PresentationEmail _presentationEmail;
  final BuildContext _context;
  final ResponsiveUtils _responsiveUtils;
  final SelectMode _selectModeAll;
  final Role? _mailboxRole;

  OnOpenEmailActionClick? _onOpenEmailActionClick;
  OnSelectEmailActionClick? _onSelectEmailActionClick;
  OnMarkAsStarEmailActionClick? _onMarkAsStarEmailActionClick;

  EmailTileBuilder(
    this._context,
    this._imagePaths,
    this._selectMode,
    this._presentationEmail,
    this._responsiveUtils,
    this._mailboxRole,
    this._selectModeAll,
  );

  void onOpenEmailAction(OnOpenEmailActionClick onOpenEmailActionClick) {
    _onOpenEmailActionClick = onOpenEmailActionClick;
  }

  void onSelectEmailAction(OnSelectEmailActionClick onSelectEmailActionClick) {
    _onSelectEmailActionClick = onSelectEmailActionClick;
  }

  void addOnMarkAsStarEmailActionClick(OnMarkAsStarEmailActionClick onMarkAsStarEmailActionClick) {
    _onMarkAsStarEmailActionClick = onMarkAsStarEmailActionClick;
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
          borderRadius: BorderRadius.circular(_selectModeAll == SelectMode.ACTIVE ? 0 : 16),
          color: _getBackgroundColorItem()),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => {
              if (_onOpenEmailActionClick != null) {
                _onOpenEmailActionClick!(_presentationEmail)
              }
            },
            onLongPress: () => {
              if (_onSelectEmailActionClick != null) {
                _onSelectEmailActionClick!(_presentationEmail)
              }
            },
            leading: Transform(
              transform: Matrix4.translationValues(-10.0, -10.0, 0.0),
              child: _buildAvatarIcon()),
            title: Transform(
              transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      (_mailboxRole == PresentationMailbox.roleSent
                        || _mailboxRole == PresentationMailbox.roleDrafts
                        || _mailboxRole == PresentationMailbox.roleOutbox)
                          ? '${_presentationEmail.recipientsName()}'
                          : '${_presentationEmail.getSenderName()}',
                      maxLines: 1,
                      overflow:TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.mailboxTextColor,
                        fontWeight: _presentationEmail.isUnReadEmail() ? FontWeight.bold : FontWeight.w500))),
                  Expanded(
                      child: Text(
                          '${_presentationEmail.id}',
                          maxLines: 1,
                          overflow:TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColor.mailboxTextColor,
                              fontWeight: _presentationEmail.isUnReadEmail() ? FontWeight.bold : FontWeight.w500))),
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text(
                      '${_presentationEmail.getReceivedAt(Localizations.localeOf(_context).toLanguageTag())}',
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
                      if (_presentationEmail.hasAttachment == true)
                        (ButtonBuilder(_imagePaths.icShare)
                            ..padding(5)
                            ..size(20))
                          .build(),
                      (ButtonBuilder(_presentationEmail.isFlaggedEmail() ? _imagePaths.icFlagged : _imagePaths.icFlag)
                          ..padding(5)
                          ..size(20)
                          ..onPressActionClick(() {
                              if (_onMarkAsStarEmailActionClick != null) {
                                _onMarkAsStarEmailActionClick!(_presentationEmail);
                              }
                            }))
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

  Widget _buildAvatarIcon () {
    if (_selectModeAll == SelectMode.ACTIVE) {
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 600),
        transitionBuilder: __transitionBuilder,
        child: _presentationEmail.selectMode == SelectMode.ACTIVE
          ? (IconBuilder(_imagePaths.icSelected)
                ..addOnTapActionClick(() {
                  if (_selectModeAll == SelectMode.ACTIVE && _onSelectEmailActionClick != null) {
                    _onSelectEmailActionClick!(_presentationEmail);
                  }}))
              .build()
          : AvatarBuilder()
              .text('${_presentationEmail.getAvatarText()}')
              .size(40)
              // .iconStatus(_imagePaths.icOffline)
              .addOnTapActionClick(() {
                  if (_selectModeAll == SelectMode.ACTIVE && _onSelectEmailActionClick != null) {
                  _onSelectEmailActionClick!(_presentationEmail);
                  }})
              .build()
      );
    } else {
      return AvatarBuilder()
        .text('${_presentationEmail.getAvatarText()}')
        .size(40)
        // .iconStatus(_imagePaths.icOffline)
        .build();
    }
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = _presentationEmail.selectMode == SelectMode.ACTIVE;
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationY(value),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }

  Color _getBackgroundColorItem() {
    if (_selectModeAll == SelectMode.ACTIVE) {
      if (_presentationEmail.selectMode == SelectMode.ACTIVE) {
        return AppColor.mailboxSelectedBackgroundColor;
      } else {
        return _responsiveUtils.isMobile(_context) ? AppColor.bgMailboxListMail : Colors.white;
      }
    } else {
      if (_responsiveUtils.isMobile(_context)) {
        return AppColor.bgMailboxListMail;
      } else if (_responsiveUtils.isDesktop(_context)) {
        return _selectMode == SelectMode.ACTIVE ? AppColor.mailboxSelectedBackgroundColor : Colors.white;
      } else {
        return Colors.white;
      }
    }
  }
}