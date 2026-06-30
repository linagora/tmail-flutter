import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_mutation.dart';

part 'search_filter_draft_notifier.g.dart';

/// Staging buffer for the suggestion dropdown + advanced filter form. Seeded from
/// committed on open (`seedFrom`), edited via [SearchFilterMutation], committed back
/// through `SearchFilterNotifier.set`. Never read by the executor. See ADR-0093.
@Riverpod(keepAlive: true)
class SearchFilterDraftNotifier extends _$SearchFilterDraftNotifier
    with SearchFilterMutation {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();

  /// Seed the draft from committed on surface open (keeps `search ⊆ draft`); strips
  /// cursors so the buffer holds only user intent.
  void seedFrom(SearchEmailFilter committed) =>
      state = committed.clearPaginationCursors();
}
