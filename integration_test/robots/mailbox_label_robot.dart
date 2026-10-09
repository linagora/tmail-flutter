import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_item.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_mailbox_label_robot.dart';

class MailboxLabelRobot extends CoreRobot implements AbstractMailboxLabelRobot {
  MailboxLabelRobot(super.$);

  final _l10n = AppLocalizations();

  // Label items are built lazily, so scroll the sidebar until one appears
  Future<void> ensureLabelReady(PatrolFinder label) async {
    await $.scrollUntilVisible(
      finder: label,
      view: $(find.byWidgetPredicate((w) => w is BaseMailboxView))
          .$(Scrollable)
          .first,
    );
  }

  @override
  Future<void> openLabel(PatrolFinder label) async {
    await ensureLabelReady(label);
    await label.tap();
  }

  @override
  Future<void> openLabelContextMenu(PatrolFinder label) async {
    await ensureLabelReady(label);
    await label.longPress();
    await $.pumpAndSettle();
  }

  @override
  Future<void> tapLabelAction(String actionName) async {
    await $(ContextMenuDialogItem).$(actionName).tap();
  }

  @override
  Future<void> confirmDeleteLabel() async {
    await $(ConfirmDialogButton).$(_l10n.delete).tap();
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
}
