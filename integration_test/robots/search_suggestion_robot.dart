import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_search_suggestion_robot.dart';

/// Web-only feature; base throws, the web variant implements it.
class SearchSuggestionRobot extends CoreRobot
    implements AbstractSearchSuggestionRobot {
  SearchSuggestionRobot(super.$);

  @override
  Future<void> tapQuickSearchFilter(QuickSearchFilter filter) {
    throw UnimplementedError(
      'Quick-search suggestion filters are web-only',
    );
  }
}
