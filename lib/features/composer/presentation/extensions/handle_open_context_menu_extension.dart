import 'package:core/presentation/utils/selection_handles_controller.dart';
import 'package:core/presentation/utils/selection_handles_overlay_guard.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/mark_as_important_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/composer_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/popup_menu_item_composer_type_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleOpenContextMenuExtension on ComposerController {
  Future<void> handleOpenContextMenu(
    BuildContext context,
    RelativeRect position,
  ) async {
    // The selection-handle overlap is Android-only; elsewhere the menu shows
    // without the suspend/restore workaround.
    final ComposerActionType? selectedActionType;
    if (PlatformInfo.isAndroid) {
      selectedActionType = await _showGuardedComposerContextMenu(
        context,
        position,
      );
    } else {
      selectedActionType = await _showComposerContextMenu(
        context,
        position,
        suppressMenuFocus: false,
      );
    }

    if (selectedActionType != null && context.mounted) {
      _handleComposerActionTypeClick(context, selectedActionType);
    }
  }

  /// Shows the menu with the Android selection handles suspended, restoring them
  /// before the selected action is dispatched.
  Future<ComposerActionType?> _showGuardedComposerContextMenu(
    BuildContext context,
    RelativeRect position,
  ) async {
    ComposerActionType? selectedActionType;

    await SelectionHandlesOverlayGuard.protect<bool>(
      context: context,
      evaluateJavascript: _editorEvaluateJavascript,
      focusSelectionOwner: richTextMobileTabletController?.focus,
      restoreSelectionOwnerFocus: (keepsComposerOpen) => keepsComposerOpen,
      action: (suspended) async {
        if (!context.mounted) {
          return false;
        }
        selectedActionType = await _showComposerContextMenu(
          context,
          position,
          suppressMenuFocus: suspended,
        );
        return selectedActionType?.keepsComposerOpen ?? true;
      },
    );

    return selectedActionType;
  }

  Future<ComposerActionType?> _showComposerContextMenu(
    BuildContext context,
    RelativeRect position, {
    required bool suppressMenuFocus,
  }) async {
    final listSelectedComposerActionType = [
      if (isMarkAsImportant.isTrue)
        ComposerActionType.markAsImportant,
      if (hasRequestReadReceipt.isTrue)
        ComposerActionType.requestReadReceipt,
    ];

    ComposerActionType? selectedActionType;
    final popupMenuItems = ComposerActionType.values.map((actionType) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          key: actionType.getContextMenuItemKey(),
          menuAction: PopupMenuItemComposerTypeAction(
            actionType,
            listSelectedComposerActionType,
            AppLocalizations.of(context),
            imagePaths,
          ),
          // Record only; dispatched after the menu closes.
          menuActionClick: (menuAction) {
            selectedActionType = menuAction.action;
            popBack();
          },
        ),
      );
    }).toList();

    await openPopupMenuAction(
      context,
      position,
      popupMenuItems,
      options: PopupMenuActionOptions(
        requestFocus: suppressMenuFocus ? false : null,
      ),
    );

    return selectedActionType;
  }

  EvaluateSelectionJavascript? get _editorEvaluateJavascript =>
      richTextMobileTabletController
          ?.htmlEditorApi
          ?.webViewController
          .evaluateJavascript;

  void _handleComposerActionTypeClick(
    BuildContext context,
    ComposerActionType actionType,
  ) {
    switch (actionType) {
      case ComposerActionType.markAsImportant:
        toggleMarkAsImportant(context);
        break;
      case ComposerActionType.requestReadReceipt:
        toggleRequestReadReceipt(context);
        break;
      case ComposerActionType.saveAsDraft:
        handleClickSaveAsDraftsButton(context);
        break;
      case ComposerActionType.saveAsTemplate:
        handleClickSaveAsTemplateButton(context);
        break;
      case ComposerActionType.delete:
        handleClickDeleteComposer();
        break;
    }
  }
}
