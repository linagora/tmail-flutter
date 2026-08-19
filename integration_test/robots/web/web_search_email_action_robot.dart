import 'package:flutter/material.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/web_tablet_body_email_item_widget.dart';

import '../../utils/wait_for_condition.dart';
import '../search_email_action_robot.dart';

class WebSearchEmailActionRobot extends SearchEmailActionRobot {
  WebSearchEmailActionRobot(super.$);

  @override
  Future<void> markSelectedEmailsAsRead() =>
      _triggerSelectedEmailAction(EmailSelectionActionType.markAsRead);

  @override
  Future<void> archiveSelectedEmails() =>
      _triggerSelectedEmailAction(EmailSelectionActionType.archiveMessage);

  @override
  Future<void> selectEmailWithSubject(String subject) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) => view.presentationEmail.subject == subject,
    );
    await waitForCondition(() async => email.evaluate().isNotEmpty);

    final tabletEmail = $(WebTabletBodyEmailItemWidget)
        .which<WebTabletBodyEmailItemWidget>(
      (view) => view.presentationEmail.subject == subject,
    );
    if (tabletEmail.evaluate().isNotEmpty) {
      // Tablet web selects through the avatar; its tile has no long-press handler.
      await tabletEmail
          .$(const Key(UiKeys.tabletEmailSelectionAvatar))
          .tap();
    } else {
      // Mobile web keeps the native-style long-press selection affordance.
      await email.longPress();
    }

    await waitForCondition(
      () async =>
          $(Key(
            '${EmailSelectionActionType.moreAction.name}'
            '${UiKeys.selectedEmailActionButtonSuffix}',
          )).evaluate().isNotEmpty,
    );
  }

  Future<void> _triggerSelectedEmailAction(
    EmailSelectionActionType type,
  ) async {
    final actionButton = selectedEmailActionButton(type);
    await waitForCondition(() async => actionButton.evaluate().isNotEmpty);

    // In headless Chrome the responsive toolbar is rendered but not
    // hit-testable to Patrol, although its button callback is available.
    final onTap = $.tester
        .widget<TMailButtonWidget>(actionButton)
        .onTapActionCallback;
    if (onTap == null) {
      throw StateError('Selected email action ${type.name} is unavailable');
    }
    onTap();
    await $.pump();
  }
}
