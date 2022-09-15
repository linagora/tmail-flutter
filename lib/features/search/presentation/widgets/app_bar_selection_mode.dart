
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icCloseComposer,
              color: AppColor.colorTextButton,
              fit: BoxFit.fill),
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          tooltip: AppLocalizations.of(context).cancel,
          onTap: onCancelSelection),
      Expanded(child: Text(
          AppLocalizations.of(context).count_email_selected(listEmail.length),
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorTextButton))),
      buildIconWeb(
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          icon: SvgPicture.asset(
              listEmail.isAllEmailRead
                  ? _imagePaths.icRead
                  : _imagePaths.icUnread,
              fit: BoxFit.fill),
          tooltip: listEmail.isAllEmailRead
              ? AppLocalizations.of(context).unread
              : AppLocalizations.of(context).read,
          onTap: () => onHandleEmailAction?.call(
              listEmail.isAllEmailRead
                  ? EmailActionType.markAsUnread
                  : EmailActionType.markAsRead,
              listEmail)),
      const SizedBox(width: 5),
      buildIconWeb(
          minSize: 25,
          iconSize: 25,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 15,
          icon: SvgPicture.asset(
              listEmail.isAllEmailStarred
                  ? _imagePaths.icUnStar
                  : _imagePaths.icStar,
              fit: BoxFit.fill),
          tooltip: listEmail.isAllEmailStarred
              ? AppLocalizations.of(context).not_starred
              : AppLocalizations.of(context).starred,
          onTap: () => onHandleEmailAction?.call(
              listEmail.isAllEmailStarred
                  ? EmailActionType.unMarkAsStarred
                  : EmailActionType.markAsStarred,
              listEmail)),
      const SizedBox(width: 5),
      if (canSpamAndMove)
        ... [
          buildIconWeb(
              minSize: 25,
              iconSize: 25,
              iconPadding: const EdgeInsets.all(5),
              splashRadius: 15,
              icon: SvgPicture.asset(_imagePaths.icMove, fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).move,
              onTap: () => onHandleEmailAction?.call(EmailActionType.moveToMailbox, listEmail)),
          const SizedBox(width: 5),
          buildIconWeb(
              minSize: 25,
              iconSize: 25,
              iconPadding: const EdgeInsets.all(5),
              splashRadius: 15,
              icon: SvgPicture.asset(isAllSpam
                  ? _imagePaths.icNotSpam
                  : _imagePaths.icSpam,
                  fit: BoxFit.fill),
              tooltip: isAllSpam
                  ? AppLocalizations.of(context).un_spam
                  : AppLocalizations.of(context).mark_as_spam,
              onTap: () => isAllSpam
                  ? onHandleEmailAction?.call(EmailActionType.unSpam, listEmail)
                  : onHandleEmailAction?.call(EmailActionType.moveToSpam, listEmail.listEmailCanSpam(mapMailbox))),
          const SizedBox(width: 5),
        ],
      if (isAllBelongToTheSameMailbox)
        ...[
          buildIconWeb(
              minSize: 25,
              iconSize: 25,
              iconPadding: const EdgeInsets.all(5),
              splashRadius: 15,
              icon: SvgPicture.asset(
                  canDeletePermanently
                      ? _imagePaths.icDeleteComposer
                      : _imagePaths.icDelete,
                  color: canDeletePermanently
                      ? AppColor.colorDeletePermanentlyButton
                      : AppColor.primaryColor,
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill),
              tooltip: canDeletePermanently
                  ? AppLocalizations.of(context).delete_permanently
                  : AppLocalizations.of(context).move_to_trash,
              onTap: () => canDeletePermanently
                  ? onHandleEmailAction?.call(EmailActionType.deletePermanently, listEmail)
                  : onHandleEmailAction?.call(EmailActionType.moveToTrash, listEmail)),
          const SizedBox(width: 10)
        ],
    ]);
  }
}