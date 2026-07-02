import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

import '../../utils/test_timeouts.dart';
import '../search_suggestion_robot.dart';

class WebSearchSuggestionRobot extends SearchSuggestionRobot {
  WebSearchSuggestionRobot(super.$);

  @override
  Future<void> tapQuickSearchFilter(QuickSearchFilter filter) async {
    final chipKey = Key('${UiKeys.quickSearchFilterButtonPrefix}${filter.name}');
    // Overlay chip isn't hit-testable; fire the wrapping InkWell.onTap directly.
    await $(chipKey).waitUntilExists(timeout: TestTimeouts.medium);
    final inkWell = find
        .ancestor(of: find.byKey(chipKey), matching: find.byType(InkWell))
        .first;
    final onTap = $.tester.widget<InkWell>(inkWell).onTap;
    expect(
      onTap,
      isNotNull,
      reason: 'Chip for $filter dispatches via onTapDown, not onTap; '
          'this robot does not support position-based filters yet.',
    );
    onTap?.call();
    await $.pumpAndSettle();
  }
}
