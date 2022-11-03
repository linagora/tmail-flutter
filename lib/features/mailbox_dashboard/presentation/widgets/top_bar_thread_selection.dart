
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEmailActionTypeAction = Function(List<PresentationEmail> listEmail, EmailActionType actionType);

class TopBarThreadSelection {

  final imagePaths = Get.find<ImagePaths>();

  final BuildContext context;
  final List<PresentationEmail> listEmail;
  final Map<MailboxId, PresentationMailbox> mapMailbox;
  final OnEmailActionTypeAction? onEmailActionTypeAction;
  final VoidCallback? onCancelSelection;

  TopBarThreadSelection(
    this.context,
    this.listEmail,
    this.mapMailbox, {
    this.onEmailActionTypeAction,
    this.onCancelSelection,
  });

  Widget build() {
    final canDeletePermanently = listEmail.isAllCanDeletePermanently(mapMailbox);
    final canSpamAndMove = listEmail.isAllCanSpamAndMove(mapMailbox);
    final isAllSpam = listEmail.isAllSpam(mapMailbox);
    final isAllBelongToTheSameMailbox = listEmail.isAllBelongToTheSameMailbox(mapMailbox);

    return Row(children: [
      buildIconWeb(
          icon: SvgPicture.asset(
              imagePaths.icCloseComposer,
              color: AppColor.colorTextButton,
              fit: BoxFit.fill),
          tooltip: AppLocalizations.of(context).cancel,
          onTap: onCancelSelection),
      Text(AppLocalizations.of(context).count_email_selected(listEmail.length),
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorTextButton)),
      const SizedBox(width: 30),
      buildIconWeb(
          icon: SvgPicture.asset(
              listEmail.isAllEmailRead
                  ? imagePaths.icUnread
                  : imagePaths.icRead,
              fit: BoxFit.fill),
          tooltip: listEmail.isAllEmailRead
              ? AppLocalizations.of(context).mark_as_unread
              : AppLocalizations.of(context).mark_as_read,
          onTap: () => onEmailActionTypeAction?.call(
              List.from(listEmail),
              listEmail.isAllEmailRead
                  ? EmailActionType.markAsUnread
                  : EmailActionType.markAsRead)),
      buildIconWeb(
          icon: SvgPicture.asset(
              listEmail.isAllEmailStarred
                  ? imagePaths.icUnStar
                  : imagePaths.icStar,
              fit: BoxFit.fill),
          tooltip: listEmail.isAllEmailStarred
              ? AppLocalizations.of(context).un_star
              : AppLocalizations.of(context).star,
          onTap: () => onEmailActionTypeAction?.call(
              List.from(listEmail),
              listEmail.isAllEmailStarred
                  ? EmailActionType.unMarkAsStarred
                  : EmailActionType.markAsStarred)),
    if (canSpamAndMove)
     ...[
       buildIconWeb(
           icon: SvgPicture.asset(imagePaths.icMove, fit: BoxFit.fill),
           tooltip: AppLocalizations.of(context).move,
           onTap: () => onEmailActionTypeAction?.call(
               List.from(listEmail),
               EmailActionType.moveToMailbox)),
       buildIconWeb(
           icon: SvgPicture.asset(
               isAllSpam ? imagePaths.icNotSpam : imagePaths.icSpam,
               fit: BoxFit.fill),
           tooltip: isAllSpam
               ? AppLocalizations.of(context).un_spam
               : AppLocalizations.of(context).mark_as_spam,
           onTap: () {
             if (isAllSpam) {
               onEmailActionTypeAction?.call(
                   List.from(listEmail),
                   EmailActionType.unSpam);
             } else {
               onEmailActionTypeAction?.call(
                   List.from(listEmail.listEmailCanSpam(mapMailbox)),
                   EmailActionType.moveToSpam);
             }
           })
      ],
      if (isAllBelongToTheSameMailbox)
        buildIconWeb(
          icon: SvgPicture.asset(
              canDeletePermanently
                  ? imagePaths.icDeleteComposer
                  : imagePaths.icDelete,
              color: canDeletePermanently
                  ? AppColor.colorDeletePermanentlyButton
                  : AppColor.primaryColor,
              width: 20,
              height: 20,
              fit: BoxFit.fill),
          tooltip: canDeletePermanently
              ? AppLocalizations.of(context).delete_permanently
              : AppLocalizations.of(context).move_to_trash,
          onTap: () {
            if (canDeletePermanently) {
              onEmailActionTypeAction?.call(
                  List.from(listEmail),
                  EmailActionType.deletePermanently);
            } else {
              onEmailActionTypeAction?.call(
                  List.from(listEmail),
                  EmailActionType.moveToTrash);
            }
          }),
    ]);
  }
}