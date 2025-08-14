
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/top_bar_thread_selection_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEmailActionTypeAction = Function(List<PresentationEmail> listEmail, EmailActionType actionType);

class TopBarThreadSelection extends StatelessWidget{

  final List<PresentationEmail> listEmail;
  final Map<MailboxId, PresentationMailbox> mapMailbox;
  final OnEmailActionTypeAction? onEmailActionTypeAction;
  final VoidCallback? onCancelSelection;
  final ImagePaths imagePaths;

  const TopBarThreadSelection (
    this.listEmail,
    this.mapMailbox,
    this.imagePaths,
    {
      super.key,
      this.onEmailActionTypeAction,
      this.onCancelSelection,
    }
  );

  @override
  Widget build(BuildContext context) {
    final isDeletePermanentlyDisabled = listEmail.isDeletePermanentlyDisabled(mapMailbox);
    final isMarkAsSpamEnabled = listEmail.isMarkAsSpamEnabled(mapMailbox);
    final isAllEmailRead = listEmail.isAllEmailRead;
    final isAllEmailStarred = listEmail.isAllEmailStarred;

    return Row(children: [
      Text(
        AppLocalizations.of(context).count_email_selected(listEmail.length),
        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: TopBarThreadSelectionStyle.iconColor,
        )
      ),
      TMailButtonWidget.fromIcon(
        icon: imagePaths.icCancel,
        iconColor: TopBarThreadSelectionStyle.iconColor,
        tooltipMessage: AppLocalizations.of(context).cancel,
        backgroundColor: Colors.transparent,
        iconSize: TopBarThreadSelectionStyle.iconSize,
        onTapActionCallback: onCancelSelection,
      ),
      const SizedBox(width: 30),
      TMailButtonWidget.fromIcon(
        icon: isAllEmailRead
          ? imagePaths.icUnread
          : imagePaths.icRead,
        iconColor: TopBarThreadSelectionStyle.iconColor,
        tooltipMessage: isAllEmailRead
          ? AppLocalizations.of(context).mark_as_unread
          : AppLocalizations.of(context).mark_as_read,
        backgroundColor: Colors.transparent,
        iconSize: TopBarThreadSelectionStyle.iconSize,
        onTapActionCallback: () => onEmailActionTypeAction?.call(
          List.from(listEmail),
          isAllEmailRead
            ? EmailActionType.markAsUnread
            : EmailActionType.markAsRead
        )
      ),
      TMailButtonWidget.fromIcon(
        icon: isAllEmailStarred
          ? imagePaths.icUnStar
          : imagePaths.icStar,
        iconColor: isAllEmailStarred
          ? TopBarThreadSelectionStyle.iconColor
          : null,
        tooltipMessage: isAllEmailStarred
          ? AppLocalizations.of(context).un_star
          : AppLocalizations.of(context).star,
        backgroundColor: Colors.transparent,
        iconSize: TopBarThreadSelectionStyle.iconSize,
        onTapActionCallback: () => onEmailActionTypeAction?.call(
          List.from(listEmail),
          isAllEmailStarred
            ? EmailActionType.unMarkAsStarred
            : EmailActionType.markAsStarred,
        ),
      ),
      TMailButtonWidget.fromIcon(
        icon: imagePaths.icMoveMailbox,
        iconSize: TopBarThreadSelectionStyle.iconSize,
        iconColor: TopBarThreadSelectionStyle.iconColor,
        tooltipMessage: AppLocalizations.of(context).move,
        backgroundColor: Colors.transparent,
        onTapActionCallback: () => onEmailActionTypeAction?.call(
          List.from(listEmail),
          EmailActionType.moveToMailbox,
        ),
      ),
      TMailButtonWidget.fromIcon(
        icon: !isMarkAsSpamEnabled ? imagePaths.icNotSpam : imagePaths.icSpam,
        backgroundColor: Colors.transparent,
        iconSize: TopBarThreadSelectionStyle.iconSize,
        iconColor: TopBarThreadSelectionStyle.iconColor,
        tooltipMessage: !isMarkAsSpamEnabled
            ? AppLocalizations.of(context).un_spam
            : AppLocalizations.of(context).mark_as_spam,
        onTapActionCallback: () {
          if (!isMarkAsSpamEnabled) {
            onEmailActionTypeAction?.call(
              List.from(listEmail),
              EmailActionType.unSpam,
            );
          } else {
            onEmailActionTypeAction?.call(
              List.from(listEmail.listEmailCanSpam(mapMailbox)),
              EmailActionType.moveToSpam,
            );
          }
        },
      ),
      TMailButtonWidget.fromIcon(
        icon: imagePaths.icDeleteComposer,
        backgroundColor: Colors.transparent,
        iconSize: TopBarThreadSelectionStyle.iconSize,
        iconColor: TopBarThreadSelectionStyle.iconColor,
        tooltipMessage: !isDeletePermanentlyDisabled
            ? AppLocalizations.of(context).delete_permanently
            : AppLocalizations.of(context).move_to_trash,
        onTapActionCallback: () {
          onEmailActionTypeAction?.call(
            List.from(listEmail),
            isDeletePermanentlyDisabled
                ? EmailActionType.moveToTrash
                : EmailActionType.deletePermanently,
          );
        },
      ),
    ]);
  }
}