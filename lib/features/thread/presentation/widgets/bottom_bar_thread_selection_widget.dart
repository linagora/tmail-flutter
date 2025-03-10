import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
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
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(
          color: AppColor.colorDividerHorizontal,
          width: 0.5,
        )),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (_currentMailbox?.isDrafts == false)
              Expanded(
                child: TMailButtonWidget(
                  key: const Key('mark_as_read_selected_email_button'),
                  text: _listSelectionEmail.isAllEmailRead
                    ? AppLocalizations.of(context).unread
                    : AppLocalizations.of(context).read,
                  icon: _listSelectionEmail.isAllEmailRead ? _imagePaths.icUnread : _imagePaths.icRead,
                  borderRadius: 0,
                  iconSize: 20,
                  iconColor: AppColor.steelGrayA540,
                  flexibleText: true,
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  backgroundColor: Colors.transparent,
                  textStyle: const TextStyle(fontSize: 12, color: AppColor.steelGrayA540),
                  verticalDirection: _verticalDirection(context),
                  onTapActionCallback: () {
                    onPressEmailSelectionActionClick?.call(
                      _listSelectionEmail.isAllEmailRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
                      _listSelectionEmail
                    );
                  },
                ),
              ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('mark_as_star_selected_email_button'),
                text: _listSelectionEmail.isAllEmailStarred
                  ? AppLocalizations.of(context).un_star
                  : AppLocalizations.of(context).star,
                icon: _listSelectionEmail.isAllEmailStarred ? _imagePaths.icUnStar : _imagePaths.icStar,
                borderRadius: 0,
                iconSize: 20,
                iconColor: _listSelectionEmail.isAllEmailStarred
                  ? AppColor.steelGrayA540
                  : null,
                flexibleText: true,
                textAlign: TextAlign.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                backgroundColor: Colors.transparent,
                textStyle: const TextStyle(fontSize: 12, color: AppColor.steelGrayA540),
                verticalDirection: _verticalDirection(context),
                onTapActionCallback: () {
                  onPressEmailSelectionActionClick?.call(
                    _listSelectionEmail.isAllEmailStarred ? EmailActionType.unMarkAsStarred : EmailActionType.markAsStarred,
                    _listSelectionEmail
                  );
                },
              ),
            ),
            if (_currentMailbox?.isDrafts == false)
              Expanded(
                child: TMailButtonWidget(
                  key: const Key('move_selected_email_to_mailbox_button'),
                  text: AppLocalizations.of(context).move,
                  icon: _imagePaths.icMoveMailbox,
                  borderRadius: 0,
                  iconSize: 20,
                  iconColor: AppColor.steelGrayA540,
                  textAlign: TextAlign.center,
                  flexibleText: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  backgroundColor: Colors.transparent,
                  textStyle: const TextStyle(fontSize: 12, color: AppColor.steelGrayA540),
                  verticalDirection: _verticalDirection(context),
                  onTapActionCallback: () {
                    onPressEmailSelectionActionClick?.call(EmailActionType.moveToMailbox, _listSelectionEmail);
                  },
                ),
              ),
            if (_currentMailbox?.isDrafts == false)
              Expanded(
                child: TMailButtonWidget(
                  key: const Key('move_selected_email_to_spam_button'),
                  text: _currentMailbox?.isSpam == true
                    ? AppLocalizations.of(context).un_spam
                    : AppLocalizations.of(context).spam,
                  icon: _currentMailbox?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam,
                  borderRadius: 0,
                  iconSize: 20,
                  iconColor: AppColor.steelGrayA540,
                  flexibleText: true,
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  backgroundColor: Colors.transparent,
                  textStyle: const TextStyle(fontSize: 12, color: AppColor.steelGrayA540),
                  verticalDirection: _verticalDirection(context),
                  onTapActionCallback: () {
                    if (_currentMailbox?.isSpam == true) {
                      onPressEmailSelectionActionClick?.call(EmailActionType.unSpam, _listSelectionEmail);
                    } else {
                      onPressEmailSelectionActionClick?.call(EmailActionType.moveToSpam, _listSelectionEmail);
                    }
                  },
                ),
              ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('delete_selected_email_button'),
                text: AppLocalizations.of(context).delete,
                icon: _imagePaths.icDeleteComposer,
                borderRadius: 0,
                iconSize: 20,
                iconColor: AppColor.steelGrayA540,
                flexibleText: true,
                textAlign: TextAlign.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                backgroundColor: Colors.transparent,
                textStyle: const TextStyle(fontSize: 12, color: AppColor.steelGrayA540),
                verticalDirection: _verticalDirection(context),
                onTapActionCallback: () {
                  if (canDeletePermanently) {
                    onPressEmailSelectionActionClick?.call(EmailActionType.deletePermanently, _listSelectionEmail);
                  } else {
                    onPressEmailSelectionActionClick?.call(EmailActionType.moveToTrash, _listSelectionEmail);
                  }
                },
              ),
            ),
          ]
        ),
      )
    );
  }

  bool get canDeletePermanently {
    return _currentMailbox?.isTrash == true || _currentMailbox?.isDrafts == true || _currentMailbox?.isSpam == true;
  }

  bool _verticalDirection(BuildContext context) {
    return _responsiveUtils.isLandscapeMobile(context) ||
      _responsiveUtils.isPortraitMobile(context) ||
      _responsiveUtils.isTabletLarge(context);
  }
}