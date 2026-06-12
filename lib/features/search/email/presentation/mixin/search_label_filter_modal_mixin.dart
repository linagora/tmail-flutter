import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/label_drop_down_button.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/context_item_all_labels_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/context_item_label_type_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_all_labels_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_label_type_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin SearchLabelFilterModalMixin on PopupContextMenuActionMixin {
  void openLabelsFilterModal({
    required BuildContext context,
    required List<Label> labels,
    required Label? selectedLabel,
    required ImagePaths imagePaths,
    required OnSelectLabelsActions onSelectLabelsActions,
    RelativeRect? position,
  }) {
    if (position != null) {
      openPopupMenuLabelsFilter(
        context: context,
        position: position,
        labels: labels,
        selectedLabel: selectedLabel,
        imagePaths: imagePaths,
        onSelectLabelsActions: onSelectLabelsActions,
      );
    } else {
      openContextMenuLabelsFilter(
        context: context,
        labels: labels,
        selectedLabel: selectedLabel,
        imagePaths: imagePaths,
        onSelectLabelsActions: onSelectLabelsActions,
      );
    }
  }

  void openPopupMenuLabelsFilter({
    required BuildContext context,
    required RelativeRect position,
    required List<Label> labels,
    required Label? selectedLabel,
    required ImagePaths imagePaths,
    required OnSelectLabelsActions onSelectLabelsActions,
  }) {
    void onMenuItemClick(menuAction) {
      popBack();
      onSelectLabelsActions(menuAction.action as Label?);
    }

    final allLabelsItem = PopupMenuItem(
      padding: EdgeInsets.zero,
      child: PopupMenuItemActionWidget(
        menuAction: PopupMenuItemAllLabelsAction(
          selectedLabel,
          imagePaths,
          AppLocalizations.of(context).allLabels,
        ),
        menuActionClick: onMenuItemClick,
      ),
    );

    final labelItems = labels.map((label) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          menuAction: PopupMenuItemLabelTypeAction(
            label,
            selectedLabel,
            imagePaths,
          ),
          menuActionClick: onMenuItemClick,
        ),
      );
    }).toList();

    openPopupMenuAction(
      context,
      position,
      [allLabelsItem, ...labelItems],
      maxHeight: 400,
    );
  }

  void openContextMenuLabelsFilter({
    required BuildContext context,
    required List<Label> labels,
    required Label? selectedLabel,
    required ImagePaths imagePaths,
    required OnSelectLabelsActions onSelectLabelsActions,
  }) {
    final allLabelsAction = ContextItemAllLabelsAction(
      selectedLabel,
      imagePaths,
      AppLocalizations.of(context).allLabels,
    );

    final contextMenuActions = <ContextMenuItemAction>[
      allLabelsAction,
      ...labels.map((label) => ContextItemLabelTypeAction(
            label,
            selectedLabel,
            imagePaths,
          )),
    ];

    openBottomSheetContextMenuAction(
      key: const Key('label_list_bottom_sheet_context_menu'),
      context: context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (menuAction) {
        popBack();
        onSelectLabelsActions(menuAction.action);
      },
      maxHeight: 400,
    );
  }
}
