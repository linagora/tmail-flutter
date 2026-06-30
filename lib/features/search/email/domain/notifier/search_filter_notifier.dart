import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_mutation.dart';

part 'search_filter_notifier.g.dart';

/// Committed single source of truth for search filter state: the intent that builds
/// the JMAP query and that the result chips read. Mutations via [SearchFilterMutation];
/// cursors can't enter it. See ADR-0093.
@Riverpod(keepAlive: true)
class SearchFilterNotifier extends _$SearchFilterNotifier
    with SearchFilterMutation {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();
}
