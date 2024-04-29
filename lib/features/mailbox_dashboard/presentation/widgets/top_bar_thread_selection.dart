
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
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
  final OnMoreSelectedEmailAction? onMoreSelectedEmailAction;

  TopBarThreadSelection({
    super.key,
    required this.listEmail,
    required this.mapMailbox,
    required this.isSelectAllEmailsEnabled,
    this.onEmailActionTypeAction,
    this.onCancelSelection,
    this.onMoreSelectedEmailAction,
  });

  @override
  Widget build(BuildContext context) {
    final canDeletePermanently = listEmail.isAllCanDeletePermanently(mapMailbox);
    final canSpamAndMove = listEmail.isAllCanSpamAndMove(mapMailbox);
    final isAllSpam = listEmail.isAllSpam(mapMailbox);
    final isAllBelongToTheSameMailbox = listEmail.isAllBelongToTheSameMailbox(mapMailbox);

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
        icon: listEmail.isAllEmailStarred
          ? imagePaths.icUnStar
          : imagePaths.icStar,
        tooltipMessage: listEmail.isAllEmailStarred
          ? AppLocalizations.of(context).un_star
          : AppLocalizations.of(context).star,
        backgroundColor: Colors.transparent,
        iconSize: 24,
        onTapActionCallback: () => onEmailActionTypeAction?.call(
          List.from(listEmail),
          listEmail.isAllEmailStarred ? EmailActionType.unMarkAsStarred : EmailActionType.markAsStarred
        )
      ),
    if (canSpamAndMove)
     ...[
       TMailButtonWidget.fromIcon(
         icon: imagePaths.icMove,
         iconSize: 22,
         tooltipMessage: AppLocalizations.of(context).move,
         backgroundColor: Colors.transparent,
         onTapActionCallback: () => onEmailActionTypeAction?.call(
           List.from(listEmail),
           EmailActionType.moveToMailbox
         )
       ),
       TMailButtonWidget.fromIcon(
         icon: isAllSpam ? imagePaths.icNotSpam : imagePaths.icSpam,
         backgroundColor: Colors.transparent,
         iconSize: 24,
         tooltipMessage: isAllSpam
           ? AppLocalizations.of(context).un_spam
           : AppLocalizations.of(context).mark_as_spam,
         onTapActionCallback: () {
           if (isAllSpam) {
             onEmailActionTypeAction?.call(
               List.from(listEmail),
               EmailActionType.unSpam
             );
           } else {
             onEmailActionTypeAction?.call(
               List.from(listEmail.listEmailCanSpam(mapMailbox)),
               EmailActionType.moveToSpam
             );
           }
         }
       )
      ],
      if (isAllBelongToTheSameMailbox)
        TMailButtonWidget.fromIcon(
          icon: imagePaths.icDeleteComposer,
          backgroundColor: Colors.transparent,
          iconSize: 20,
          iconColor: canDeletePermanently
            ? AppColor.colorDeletePermanentlyButton
            : AppColor.primaryColor,
          tooltipMessage: canDeletePermanently
            ? AppLocalizations.of(context).delete_permanently
            : AppLocalizations.of(context).move_to_trash,
          onTapActionCallback: () {
            if (canDeletePermanently) {
              onEmailActionTypeAction?.call(
                List.from(listEmail),
                EmailActionType.deletePermanently
              );
            } else {
              onEmailActionTypeAction?.call(
                List.from(listEmail),
                EmailActionType.moveToTrash
              );
            }
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
}