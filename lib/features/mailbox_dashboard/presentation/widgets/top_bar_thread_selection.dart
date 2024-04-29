
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEmailActionTypeAction = Function(List<PresentationEmail> listEmail, EmailActionType actionType);
typedef OnMoreSelectedEmailAction = Function(RelativeRect position);

class TopBarThreadSelection extends StatelessWidget{

  final imagePaths = Get.find<ImagePaths>();

  final List<PresentationEmail> listEmail;
  final Map<MailboxId, PresentationMailbox> mapMailbox;
  final OnEmailActionTypeAction? onEmailActionTypeAction;
  final VoidCallback? onCancelSelection;
  final bool isSelectAllEmailsEnabled;
  final PresentationMailbox? selectedMailbox;
  final OnMoreSelectedEmailAction? onMoreSelectedEmailAction;

  TopBarThreadSelection({
    super.key,
    required this.listEmail,
    required this.mapMailbox,
    required this.isSelectAllEmailsEnabled,
    this.selectedMailbox,
    this.onEmailActionTypeAction,
    this.onCancelSelection,
    this.onMoreSelectedEmailAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      TMailButtonWidget.fromIcon(
        icon: imagePaths.icClose,
        iconColor: AppColor.primaryColor,
        tooltipMessage: AppLocalizations.of(context).cancel,
        backgroundColor: Colors.transparent,
        iconSize: 28,
        padding: const EdgeInsets.all(3),
        onTapActionCallback: onCancelSelection
      ),
      if (!isSelectAllEmailsEnabled)
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 30),
          child: Text(
            AppLocalizations.of(context).count_email_selected(listEmail.length),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorTextButton
            )
          ),
        ),
      TMailButtonWidget.fromIcon(
        icon: _getIconForMarkAsRead(),
        tooltipMessage: _getTooltipMessageForMarkAsRead(context),
        backgroundColor: Colors.transparent,
        iconSize: 24,
        onTapActionCallback: () => onEmailActionTypeAction?.call(
          List.from(listEmail),
          _getActionTypeForMarkAsRead()
        )
      ),
      TMailButtonWidget.fromIcon(
        icon: _getIconForMarkAsStar(),
        tooltipMessage: _getTooltipMessageForMarkAsStar(context),
        backgroundColor: Colors.transparent,
        iconSize: 24,
        onTapActionCallback: () => onEmailActionTypeAction?.call(
          List.from(listEmail),
          _getActionTypeForMarkAsStar()
        )
      ),
    if (canSpamAndMove)
     ...[
       TMailButtonWidget.fromIcon(
         icon: imagePaths.icMove,
         iconSize: 22,
         tooltipMessage: _getTooltipMessageForMove(context),
         backgroundColor: Colors.transparent,
         onTapActionCallback: () => onEmailActionTypeAction?.call(
           List.from(listEmail),
           _getActionTypeForMove()
         )
       ),
       TMailButtonWidget.fromIcon(
         icon: _getIconForMoveToSpam(),
         backgroundColor: Colors.transparent,
         iconSize: 24,
         tooltipMessage: _getTooltipMessageForMoveToSpam(context),
         onTapActionCallback: () {
           onEmailActionTypeAction?.call(
             List.from(listEmail.listEmailCanSpam(mapMailbox)),
             _getActionTypeForMoveToSpam()
           );
         }
       )
      ],
      if (isAllBelongToTheSameMailbox)
        TMailButtonWidget.fromIcon(
          icon: imagePaths.icDeleteComposer,
          backgroundColor: Colors.transparent,
          iconSize: 20,
          iconColor: _getIconColorForMoveToTrash(),
          tooltipMessage: _getTooltipMessageForMoveToTrash(context),
          onTapActionCallback: () {
            onEmailActionTypeAction?.call(
              List.from(listEmail),
              _getActionTypeForMoveToTrash(),
            );
          }
        ),
      const Spacer(),
      if (isSelectAllEmailsEnabled)
        TMailButtonWidget.fromIcon(
          icon: imagePaths.icMoreVertical,
          iconSize: 22,
          iconColor: AppColor.primaryColor,
          tooltipMessage: AppLocalizations.of(context).more,
          backgroundColor: Colors.transparent,
          onTapActionAtPositionCallback: onMoreSelectedEmailAction
        ),
    ]);
  }

  bool get canDeletePermanently => listEmail.isAllCanDeletePermanently(mapMailbox);

  bool get canDeleteAllPermanently => isSelectAllEmailsEnabled
      && (selectedMailbox?.isTrash == true
          || selectedMailbox?.isSpam == true
          || selectedMailbox?.isDrafts == true);

  bool get canSpamAndMove => listEmail.isAllCanSpamAndMove(mapMailbox);

  bool get isAllSpam => listEmail.isAllSpam(mapMailbox);

  bool get isAllBelongToTheSameMailbox => listEmail.isAllBelongToTheSameMailbox(mapMailbox);

  EmailActionType _getActionTypeForMarkAsRead() {
    if (isSelectAllEmailsEnabled) {
      return EmailActionType.markAllAsRead;
    } else {
      return listEmail.isAllEmailRead
        ? EmailActionType.markAsUnread
        : EmailActionType.markAsRead;
    }
  }

  String _getIconForMarkAsRead() {
    if (isSelectAllEmailsEnabled) {
      return imagePaths.icRead;
    } else {
      return listEmail.isAllEmailRead
        ? imagePaths.icUnread
        : imagePaths.icRead;
    }
  }

  String _getTooltipMessageForMarkAsRead(BuildContext context) {
    if (isSelectAllEmailsEnabled) {
      return AppLocalizations.of(context).mark_all_as_read;
    } else {
      return listEmail.isAllEmailRead
        ? AppLocalizations.of(context).mark_as_unread
        : AppLocalizations.of(context).mark_as_read;
    }
  }

  String _getTooltipMessageForMove(BuildContext context) {
    if (isSelectAllEmailsEnabled) {
      return AppLocalizations.of(context).moveAll;
    } else {
      return AppLocalizations.of(context).move;
    }
  }

  EmailActionType _getActionTypeForMove() {
    if (isSelectAllEmailsEnabled) {
      return EmailActionType.moveAll;
    } else {
      return EmailActionType.moveToMailbox;
    }
  }

  Color _getIconColorForMoveToTrash() {
    if (canDeleteAllPermanently) {
      return AppColor.colorDeletePermanentlyButton;
    } else if (isSelectAllEmailsEnabled) {
      return AppColor.primaryColor;
    } else if (canDeletePermanently) {
      return AppColor.colorDeletePermanentlyButton;
    } else {
      return AppColor.primaryColor;
    }
  }

  String _getTooltipMessageForMoveToTrash(BuildContext context) {
    if (canDeleteAllPermanently) {
      return AppLocalizations.of(context).deleteAllPermanently;
    } else if (isSelectAllEmailsEnabled) {
      return AppLocalizations.of(context).moveAllToTrash;
    } else if (canDeletePermanently) {
      return AppLocalizations.of(context).delete_permanently;
    } else {
      return AppLocalizations.of(context).move_to_trash;
    }
  }

  EmailActionType _getActionTypeForMoveToTrash() {
    if (canDeleteAllPermanently) {
      return EmailActionType.deleteAllPermanently;
    } else if (isSelectAllEmailsEnabled) {
      return EmailActionType.moveAllToTrash;
    } else if (canDeletePermanently) {
      return EmailActionType.deletePermanently;
    } else {
      return EmailActionType.moveToTrash;
    }
  }

  String _getIconForMarkAsStar() {
    if (isSelectAllEmailsEnabled) {
      return imagePaths.icStar;
    } else {
      return listEmail.isAllEmailStarred
        ? imagePaths.icUnStar
        : imagePaths.icStar;
    }
  }

  String _getTooltipMessageForMarkAsStar(BuildContext context) {
    if (isSelectAllEmailsEnabled) {
      return AppLocalizations.of(context).allStarred;
    } else {
      return listEmail.isAllEmailStarred
        ? AppLocalizations.of(context).un_star
        : AppLocalizations.of(context).star;
    }
  }


  EmailActionType _getActionTypeForMarkAsStar() {
    if (isSelectAllEmailsEnabled) {
      return EmailActionType.markAllAsStarred;
    } else {
      return listEmail.isAllEmailStarred
        ? EmailActionType.unMarkAsStarred
        : EmailActionType.markAsStarred;
    }
  }

  String _getIconForMoveToSpam() {
    if (isSelectAllEmailsEnabled) {
      return selectedMailbox?.isSpam == true ? imagePaths.icNotSpam : imagePaths.icSpam;
    } else {
      return isAllSpam ? imagePaths.icNotSpam : imagePaths.icSpam;
    }
  }

  String _getTooltipMessageForMoveToSpam(BuildContext context) {
    if (isSelectAllEmailsEnabled) {
      return selectedMailbox?.isSpam == true
        ? AppLocalizations.of(context).allUnSpam
        : AppLocalizations.of(context).markAllAsSpam;
    } else {
      return isAllSpam
        ? AppLocalizations.of(context).un_spam
        : AppLocalizations.of(context).mark_as_spam;
    }
  }

  EmailActionType _getActionTypeForMoveToSpam() {
    if (isSelectAllEmailsEnabled) {
      return selectedMailbox?.isSpam == true
        ? EmailActionType.allUnSpam
        : EmailActionType.markAllAsSpam;
    } else {
      return isAllSpam
        ? EmailActionType.unSpam
        : EmailActionType.moveToSpam;
    }
  }
}