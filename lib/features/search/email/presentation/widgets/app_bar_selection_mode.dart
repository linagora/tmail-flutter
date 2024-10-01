
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

class AppBarSelectionMode extends StatelessWidget {

  final _imagePaths = Get.find<ImagePaths>();

  final List<PresentationEmail> listEmail;
  final Map<MailboxId, PresentationMailbox> mapMailbox;
  final Function()? onCancelSelection;
  final Function(EmailActionType actionType, List<PresentationEmail> emails)? onHandleEmailAction;

  AppBarSelectionMode(
      this.listEmail,
      this.mapMailbox, {
      Key? key,
      this.onCancelSelection,
      this.onHandleEmailAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canDeletePermanently = listEmail.isAllCanDeletePermanently(mapMailbox);
    final canSpamAndMove = listEmail.isAllCanSpamAndMove(mapMailbox);
    final isAllSpam = listEmail.isAllSpam(mapMailbox);
    final isAllBelongToTheSameMailbox = listEmail.isAllBelongToTheSameMailbox(mapMailbox);

    return Row(children: [
      TMailButtonWidget.fromIcon(
        icon: _imagePaths.icClose,
        iconSize: 25,
        iconColor: AppColor.colorTextButton,
        backgroundColor: Colors.transparent,
        tooltipMessage: AppLocalizations.of(context).cancel,
        onTapActionCallback: onCancelSelection,
      ),
      Expanded(
        child: Text(
          AppLocalizations.of(context).count_email_selected(listEmail.length),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColor.colorTextButton
          )
        )
      ),
      TMailButtonWidget.fromIcon(
        icon: listEmail.isAllEmailRead
          ? _imagePaths.icUnread
          : _imagePaths.icRead,
        iconSize: 25,
        backgroundColor: Colors.transparent,
        tooltipMessage: listEmail.isAllEmailRead
          ? AppLocalizations.of(context).unread
          : AppLocalizations.of(context).read,
        onTapActionCallback: () => onHandleEmailAction?.call(
          listEmail.isAllEmailRead
            ? EmailActionType.markAsUnread
            : EmailActionType.markAsRead,
          listEmail
        ),
      ),
      const SizedBox(width: 5),
      TMailButtonWidget.fromIcon(
        icon: listEmail.isAllEmailStarred
          ? _imagePaths.icUnStar
          : _imagePaths.icStar,
        iconSize: 25,
        backgroundColor: Colors.transparent,
        tooltipMessage: listEmail.isAllEmailStarred
          ? AppLocalizations.of(context).not_starred
          : AppLocalizations.of(context).starred,
        onTapActionCallback: () => onHandleEmailAction?.call(
          listEmail.isAllEmailStarred
            ? EmailActionType.unMarkAsStarred
            : EmailActionType.markAsStarred,
          listEmail
        ),
      ),
      const SizedBox(width: 5),
      if (canSpamAndMove)
        ... [
          TMailButtonWidget.fromIcon(
            icon: _imagePaths.icMove,
            iconSize: 25,
            backgroundColor: Colors.transparent,
            tooltipMessage: AppLocalizations.of(context).move,
            onTapActionCallback: () => onHandleEmailAction?.call(
              EmailActionType.moveToMailbox,
              listEmail
            ),
          ),
          const SizedBox(width: 5),
          TMailButtonWidget.fromIcon(
            icon: isAllSpam
              ? _imagePaths.icNotSpam
              : _imagePaths.icSpam,
            iconSize: 25,
            backgroundColor: Colors.transparent,
            tooltipMessage: isAllSpam
              ? AppLocalizations.of(context).un_spam
              : AppLocalizations.of(context).mark_as_spam,
            onTapActionCallback: () => isAllSpam
              ? onHandleEmailAction?.call(EmailActionType.unSpam, listEmail)
              : onHandleEmailAction?.call(EmailActionType.moveToSpam, listEmail.listEmailCanSpam(mapMailbox)),
          ),
          const SizedBox(width: 5),
        ],
      if (isAllBelongToTheSameMailbox)
        TMailButtonWidget.fromIcon(
          icon: _imagePaths.icDeleteComposer,
          iconSize: 20,
          backgroundColor: Colors.transparent,
          iconColor: canDeletePermanently
            ? AppColor.colorDeletePermanentlyButton
            : AppColor.primaryColor,
          tooltipMessage: canDeletePermanently
            ? AppLocalizations.of(context).delete_permanently
            : AppLocalizations.of(context).move_to_trash,
          onTapActionCallback: () => canDeletePermanently
            ? onHandleEmailAction?.call(EmailActionType.deletePermanently, listEmail)
            : onHandleEmailAction?.call(EmailActionType.moveToTrash, listEmail),
        ),
    ]);
  }
}