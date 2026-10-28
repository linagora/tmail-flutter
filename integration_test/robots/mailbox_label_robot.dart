import 'dart:async';

import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_item.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import '../utils/test_timeouts.dart';
import '../utils/wait_for_condition.dart';
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
    if (PlatformInfo.isMobile) {
      try {
        await waitForCondition(
          () async {
            await $.pump();
            return $(ContextMenuDialogItem).visible;
          },
          timeout: TestTimeouts.short,
        );
      } on TimeoutException {
        fail('Label context menu was not shown within 15 seconds');
      }
    } else {
      await $.pumpAndSettle();
    }
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
    final input = $(#label_name_input_field).$(TextFieldBuilder);
    // The real Android IME restores its own text over patrol's mock input
    if (PlatformInfo.isMobile) await hideKeyboard();
    await input.enterText(name);
    if (!PlatformInfo.isMobile) return;
    try {
      await waitForCondition(
        () async {
          await $.pump();
          return $.tester
                  .widget<EditableText>(input.$(EditableText))
                  .controller
                  .text ==
              name;
        },
        timeout: TestTimeouts.short,
      );
    } on TimeoutException {
      fail('Label name input did not keep "$name" within 15 seconds');
    }
  }

  @override
  Future<void> tapSaveLabel() async {
    final button = $(CreateNewLabelModal).$(#save_label_button_action);
    await button.scrollTo();
    await button.tap();
    if (PlatformInfo.isMobile) {
      try {
        await waitForCondition(
          () async {
            await $.pump();
            return !$(CreateNewLabelModal).exists;
          },
          timeout: TestTimeouts.medium,
        );
      } on TimeoutException {
        fail('Label modal did not close after saving within 30 seconds');
      }
    }
  }
}
