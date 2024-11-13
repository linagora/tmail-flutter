import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../base/core_robot.dart';

class SearchRobot extends CoreRobot {
  SearchRobot(super.$);

  Future<void> enterQueryString(String queryString) async {
    await $(#search_email_text_field).enterText(queryString);
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
}