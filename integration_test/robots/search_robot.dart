import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import '../extensions/patrol_finder_extension.dart';

class SearchRobot extends CoreRobot {
  SearchRobot(super.$);

  Future<void> enterQueryString(String queryString) async {
    final finder = $(#search_email_text_field).$(TextField);
    final isTextFieldFocused = finder
      .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(queryString);
  }

  Future<void> scrollToEndListSearchFilter() async {
    await $.scrollUntilVisible(
      finder: $(#mobile_sortBy_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 300,
    );
  }

  Future<void> openSortOrderBottomDialog() async {
    await $(#mobile_sortBy_search_filter_button).tap();
  }

  Future<void> selectSortOrder(String sortOrderName) async {
    await $(find.text(sortOrderName)).tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> enterKeyword(String keyword) async {
    final finder = $(SearchEmailView).$(TextFieldBuilder);
    final isTextFieldFocused = finder
      .which<TextFieldBuilder>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(keyword);
  }
  
  Future<void> tapOnShowAllResultsText() async {
    await $.waitUntilVisible($(AppLocalizations().showingResultsFor));
    await $(AppLocalizations().showingResultsFor).tap();
  }

  Future<void> scrollToDateTimeButtonFilter() async {
    await $.scrollUntilVisible(
      finder: $(#mobile_dateTime_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 100,
    );
  }

  Future<void> openDateTimeBottomDialog() async {
    await $(#mobile_dateTime_search_filter_button).tap();
  }

  Future<void> selectDateTime(String dateTimeType) async {
    await $(find.text(dateTimeType)).tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> openEmailWithSubject(String subject) async {
    await $(find.byType(EmailTileBuilder)).first.tap();
    await $.pump(const Duration(seconds: 2));
  }
}