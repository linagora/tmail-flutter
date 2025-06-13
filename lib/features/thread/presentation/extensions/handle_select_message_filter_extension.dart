import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/context_item_filter_message_option_action.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension HandleSelectMessageFilterExtension on ThreadController {
  void handleSelectMessageFilter(
    BuildContext context,
    FilterMessageOption selectedOption,
  ) {
    final contextMenuActions = [
      FilterMessageOption.attachments,
      FilterMessageOption.unread,
      FilterMessageOption.starred,
    ].map((filter) {
      return ContextItemFilterMessageOptionAction(
        filter,
        selectedOption,
        AppLocalizations.of(context),
        imagePaths,
      );
    }).toList();

    openBottomSheetContextMenuAction(
      context: context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (action) => filterMessagesAction(action.action),
    );
  }
}
