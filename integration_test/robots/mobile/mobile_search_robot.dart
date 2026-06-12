import 'package:core/presentation/views/search/search_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../abstract/abstract_search_robot.dart';
import '../search_robot.dart';
import 'mobile_common_robot.dart';

class MobileSearchRobot extends SearchRobot implements AbstractSearchRobot {
  MobileSearchRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> openSearch() async {
    if ($(SearchEmailView).exists) return;
    await $(SearchBarView).$(InkWell).tap();
    await $(SearchEmailView).waitUntilVisible();
  }

  @override
  Future<void> searchByLabel(String labelName) async {
    await $.scrollUntilVisible(
      finder: $(#mobile_labels_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 300,
    );
    await $(#mobile_labels_search_filter_button).tap();
    await $(#label_list_bottom_sheet_context_menu).waitUntilVisible();
    await MobileCommonRobot($).selectContextMenuItemByName(labelName);
  }

  @override
  Future<void> expectEmailWithSubjectVisible(String subject) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) => view.presentationEmail.subject?.contains(subject) == true,
    );
    await $.waitUntilVisible(email);
  }

  @override
  Future<void> expectEmptyResults() async {
    await $(const Key(UiKeys.emptySearchEmailView)).waitUntilVisible();
  }
}
