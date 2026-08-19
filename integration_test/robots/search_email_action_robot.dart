import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
    if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_search_email_action_robot.dart';

class SearchEmailActionRobot extends CoreRobot
    implements AbstractSearchEmailActionRobot {
  SearchEmailActionRobot(super.$);

  @override
  Future<void> selectEmailWithSubject(String subject) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) => view.presentationEmail.subject == subject,
    );
    await $.waitUntilVisible(email);
    await email.longPress();
    await $.waitUntilVisible(
      selectedEmailActionButton(EmailSelectionActionType.moreAction),
    );
  }

  @override
  Future<void> markSelectedEmailsAsRead() async {
    await selectedEmailActionButton(EmailSelectionActionType.markAsRead)
        .tap(settlePolicy: SettlePolicy.noSettle);
  }

  @override
  Future<void> archiveSelectedEmails() async {
    await selectedEmailActionButton(EmailSelectionActionType.archiveMessage)
        .tap(settlePolicy: SettlePolicy.noSettle);
  }

  PatrolFinder selectedEmailActionButton(EmailSelectionActionType type) =>
      $(Key('${type.name}${UiKeys.selectedEmailActionButtonSuffix}'));
}
