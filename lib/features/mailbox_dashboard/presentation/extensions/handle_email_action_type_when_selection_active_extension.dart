
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_email_action_type_when_select_all_active_and_mailbox_opened_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_email_action_type_when_select_all_active_and_search_active_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_selection_email_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleEmailActionTypeWhenSelectionActiveExtension on MailboxDashBoardController {

  void handleEmailActionTypeWhenSelectionActive({
    required EmailActionType actionType,
    List<PresentationEmail>? listSelectedEmail,
  }) {
    if (isSelectAllActiveAndMailboxOpened) {
      if (currentContext == null) return;

      final appLocalizations = AppLocalizations.of(currentContext!);
      final selectedMailbox = this.selectedMailbox.value!;

      final message = appLocalizations
        .messageConfirmationDialogWhenMakeToActionForSelectionAllEmailsInMailbox(
          selectedMailbox.countTotalEmails,
          selectedMailbox.getDisplayNameByAppLocalizations(appLocalizations),
        );

      showConfirmBulkActionDialog(
        message: message,
        onConfirmAction: () => handleActionTypeWhenSelectAllActiveAndMailboxOpened(
          appLocalizations: appLocalizations,
          selectedMailbox: selectedMailbox,
          actionType: actionType,
        ),
      );
    } else if (isSelectAllActiveAndSearchActive) {
      if (currentContext == null) return;

      final appLocalizations = AppLocalizations.of(currentContext!);

      final message = appLocalizations.messageConfirmationDialogWhenMakeToActionForSelectionAllEmailsInSearch;

      showConfirmBulkActionDialog(
        message: message,
        onConfirmAction: () => handleActionTypeWhenSelectAllActiveAndSearchActive(
          appLocalizations: appLocalizations,
          actionType: actionType,
        ),
      );
    } else if (listSelectedEmail?.isNotEmpty == true) {
      handleEmailActionTypeForListSelectedEmail(
        actionType,
        listSelectedEmail!,
      );
    }
  }

  bool get isSelectAllActiveAndMailboxOpened =>
      isSelectAllEmailsEnabled.isTrue && selectedMailbox.value != null;

  bool get isSelectAllActiveAndSearchActive =>
      isSelectAllEmailsEnabled.isTrue && searchController.isSearchEmailRunning;

  Future<void> showConfirmBulkActionDialog({
    required String message,
    required VoidCallback onConfirmAction,
  }) async {
    if (currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);

    await showConfirmDialogAction(
      currentContext!,
      message,
      appLocalizations.ok,
      title: appLocalizations.confirmBulkAction,
      icon: SvgPicture.asset(
        imagePaths.icQuotasWarning,
        colorFilter: AppColor.colorBackgroundQuotasWarning.asFilter(),
      ),
      onConfirmAction: onConfirmAction,
    );
  }

  void handleEmailActionTypeForListSelectedEmail(
    EmailActionType actionType,
    List<PresentationEmail> listEmail,
  ) {
    switch(actionType) {
      case EmailActionType.markAsRead:
        cancelAllSelectionEmailMode();
        markAsReadSelectedMultipleEmail(listEmail, ReadActions.markAsRead);
        break;
      case EmailActionType.markAsUnread:
        cancelAllSelectionEmailMode();
        markAsReadSelectedMultipleEmail(listEmail, ReadActions.markAsUnread);
        break;
      case EmailActionType.markAsStarred:
        cancelAllSelectionEmailMode();
        markAsStarSelectedMultipleEmail(listEmail, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        cancelAllSelectionEmailMode();
        markAsStarSelectedMultipleEmail(listEmail, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        cancelAllSelectionEmailMode();

        final currentMailbox = searchController.isSearchEmailRunning
          ? listEmail.getCurrentMailboxContain(mapMailboxById)
          : selectedMailbox.value;

        if (currentMailbox != null) {
          moveSelectedMultipleEmailToMailbox(listEmail, currentMailbox);
        }
        break;
      case EmailActionType.moveToTrash:
        cancelAllSelectionEmailMode();

        final currentMailbox = searchController.isSearchEmailRunning
          ? listEmail.getCurrentMailboxContain(mapMailboxById)
          : selectedMailbox.value;

        if (currentMailbox != null) {
          moveSelectedMultipleEmailToTrash(listEmail, currentMailbox);
        }
        break;
      case EmailActionType.deletePermanently:
        final currentMailbox = searchController.isSearchEmailRunning
          ? listEmail.getCurrentMailboxContain(mapMailboxById)
          : selectedMailbox.value;

        if (currentMailbox != null && currentContext != null) {
          deleteSelectionEmailsPermanently(
            currentContext!,
            DeleteActionType.multiple,
            listEmails: listEmail,
            mailboxCurrent: currentMailbox,
            onCancelSelectionEmail: cancelAllSelectionEmailMode,
          );
        }
        break;
      case EmailActionType.moveToSpam:
        cancelAllSelectionEmailMode();

        final currentMailbox = searchController.isSearchEmailRunning
          ? listEmail.getCurrentMailboxContain(mapMailboxById)
          : selectedMailbox.value;

        if (currentMailbox != null) {
          moveSelectedMultipleEmailToSpam(listEmail, currentMailbox);
        }
        break;
      case EmailActionType.unSpam:
        cancelAllSelectionEmailMode();
        unSpamSelectedMultipleEmail(listEmail);
        break;
      default:
        break;
    }
  }

  void openEmailActionTypePopupMenu({
    required BuildContext context,
    required RelativeRect position,
  }) {
    final selectedMailbox = this.selectedMailbox.value;

    final listSelectionEmailActions = [
      EmailActionType.markAllAsRead,
      EmailActionType.markAllAsUnread,
      if (selectedMailbox == null || !selectedMailbox.isDrafts)
        EmailActionType.moveAll,
      if (selectedMailbox?.isTrash == true
          || selectedMailbox?.isSpam == true
          || selectedMailbox?.isDrafts == true
      )
        EmailActionType.deleteAllPermanently
      else
        EmailActionType.moveAllToTrash
    ];

    final listPopupItem = listSelectionEmailActions
      .map((actionType) => PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          actionType.getIcon(imagePaths),
          actionType.getTitle(context),
          colorIcon: actionType.getIconColor(),
          styleName: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          onCallbackAction: () {
            popBack();
            handleEmailActionTypeWhenSelectionActive(actionType: actionType);
          },
        ),
      ))
      .toList();

    openPopupMenuAction(
      context,
      position,
      listPopupItem,
    );
  }
}