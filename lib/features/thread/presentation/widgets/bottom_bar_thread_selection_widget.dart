import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnPressEmailSelectionActionClick = void Function(EmailActionType, List<PresentationEmail>);

class BottomBarThreadSelectionWidget extends StatelessWidget{

  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final List<PresentationEmail> _listSelectionEmail;
  final PresentationMailbox? _currentMailbox;
  final OnPressEmailSelectionActionClick? onPressEmailSelectionActionClick;

  const BottomBarThreadSelectionWidget(
    this._imagePaths,
    this._responsiveUtils,
    this._listSelectionEmail,
    this._currentMailbox,
    {
      super.key,
      this.onPressEmailSelectionActionClick,
    }
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bottom_bar_thread_selection_widget'),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(
          color: AppColor.lineItemListColor,
          width: 0.2,
        )),
        color: Colors.white
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(_currentMailbox?.isDrafts == false)
            Expanded(child: (ButtonBuilder(_listSelectionEmail.isAllEmailRead ? _imagePaths.icUnread : _imagePaths.icRead)
              ..key(const Key('button_mark_read_email'))
              ..padding(const EdgeInsets.all(8))
              ..radiusSplash(8)
              ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
              ..onPressActionClick(() {
                onPressEmailSelectionActionClick?.call(
                  _listSelectionEmail.isAllEmailRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
                  _listSelectionEmail
                );
              })
              ..text(_getTextButtonMarkAsRead(context), isVertical: _responsiveUtils.isMobile(context)))
            .build()),
          Expanded(child: (ButtonBuilder(_listSelectionEmail.isAllEmailStarred ? _imagePaths.icUnStar : _imagePaths.icStar)
            ..key(const Key('button_mark_as_star_email'))
            ..padding(const EdgeInsets.all(8))
            ..radiusSplash(8)
            ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              onPressEmailSelectionActionClick?.call(
                _listSelectionEmail.isAllEmailStarred ? EmailActionType.unMarkAsStarred : EmailActionType.markAsStarred,
                _listSelectionEmail
              );
            })
            ..text(_getTextButtonMarkAsStar(context), isVertical: _responsiveUtils.isMobile(context)))
          .build()),
          if (_currentMailbox?.isDrafts == false)
            Expanded(child: (ButtonBuilder(_imagePaths.icMove)
              ..key(const Key('button_move_to_mailbox'))
              ..padding(const EdgeInsets.all(8))
              ..radiusSplash(8)
              ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
              ..onPressActionClick(() {
                onPressEmailSelectionActionClick?.call(EmailActionType.moveToMailbox, _listSelectionEmail);
              })
              ..text(_getTextButtonMove(context), isVertical: _responsiveUtils.isMobile(context)))
            .build()),
          if (_currentMailbox?.isDrafts == false)
            Expanded(child: (ButtonBuilder(_currentMailbox?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam)
              ..key(const Key('button_move_to_spam'))
              ..padding(const EdgeInsets.all(8))
              ..radiusSplash(8)
              ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
              ..onPressActionClick(() {
                if (_currentMailbox?.isSpam == true) {
                  onPressEmailSelectionActionClick?.call(EmailActionType.unSpam, _listSelectionEmail);
                } else {
                  onPressEmailSelectionActionClick?.call(EmailActionType.moveToSpam, _listSelectionEmail);
                }
              })
              ..text(_getTextButtonSpam(context), isVertical: _responsiveUtils.isMobile(context)))
            .build()),
          Expanded(child: (ButtonBuilder(canDeletePermanently ? _imagePaths.icDeleteComposer : _imagePaths.icDelete)
            ..key(const Key('button_delete_email'))
            ..iconColor(canDeletePermanently ? AppColor.colorDeletePermanentlyButton : AppColor.primaryColor)
            ..padding(const EdgeInsets.all(8))
            ..radiusSplash(8)
            ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (canDeletePermanently) {
                onPressEmailSelectionActionClick?.call(EmailActionType.deletePermanently, _listSelectionEmail);
              } else {
                onPressEmailSelectionActionClick?.call(EmailActionType.moveToTrash, _listSelectionEmail);
              }
            })
            ..text(_getTextButtonDelete(context), isVertical: _responsiveUtils.isMobile(context)))
          .build())
        ]
      )
    );
  }

  bool get canDeletePermanently {
    return _currentMailbox?.isTrash == true || _currentMailbox?.isDrafts == true;
  }

  String? _getTextButtonMarkAsRead(BuildContext context) {
    if (!_isMailboxDashboardSplitView(context)) {
      return _listSelectionEmail.isAllEmailRead
        ? AppLocalizations.of(context).unread
        : AppLocalizations.of(context).read;
    }
    return null;
  }

  String? _getTextButtonMarkAsStar(BuildContext context) {
    if (!_isMailboxDashboardSplitView(context)) {
      return _listSelectionEmail.isAllEmailStarred
        ? AppLocalizations.of(context).un_star
        : AppLocalizations.of(context).star;
    }
    return null;
  }

  String? _getTextButtonMove(BuildContext context) {
    if (!_isMailboxDashboardSplitView(context)) {
      return AppLocalizations.of(context).move;
    }
    return null;
  }

  String? _getTextButtonSpam(BuildContext context) {
    if (!_isMailboxDashboardSplitView(context)) {
      return _currentMailbox?.isSpam == true
        ? AppLocalizations.of(context).un_spam
        : AppLocalizations.of(context).spam;
    }
    return null;
  }

  String? _getTextButtonDelete(BuildContext context) {
    if (!_isMailboxDashboardSplitView(context)) {
      return AppLocalizations.of(context).delete;
    }
    return null;
  }

  bool _isMailboxDashboardSplitView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return _responsiveUtils.isTabletLarge(context);
    } else {
      return _responsiveUtils.isLandscapeTablet(context) ||
        _responsiveUtils.isTabletLarge(context) ||
        _responsiveUtils.isDesktop(context);
    }
  }
}