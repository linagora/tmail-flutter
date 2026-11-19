import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';

import '../mailbox_label_robot.dart';
import 'web_hover_tap.dart';

/// Web-specific label robot: the label menu opens from the more button shown
/// on hover, as a popup menu instead of a bottom sheet.
class WebMailboxLabelRobot extends MailboxLabelRobot {
  WebMailboxLabelRobot(super.$);

  @override
  Future<void> openLabelContextMenu(PatrolFinder label) async {
    await ensureLabelReady(label);
    await webHoverThenTap(
      $,
      label,
      label.$(const ValueKey(UiKeys.labelMoreActionButton)),
    );
  }

  @override
  Future<void> enterLabelName(String name) async {
    await $(#label_name_input_field).$(TextFieldBuilder).enterText(name);
  }

  @override
  Future<void> tapSaveLabel() async {
    final button = $(CreateNewLabelModal).$(#save_label_button_action);
    await button.scrollTo();
    await button.tap();
  }

  @override
  Future<void> tapLabelAction(String actionName) async {
    await $(PopupMenuItemActionWidget).$(actionName).tap();
    await $.pumpAndTrySettle();
  }
}
