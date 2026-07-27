import 'package:model/mailbox/expand_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_filter_view_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

part 'advanced_filter_view_state_notifier.g.dart';

/// View-state SSOT for the advanced-search form's address expand modes.
///
/// Autodisposes with the form: the initial expand mode is derived from the
/// committed filter each time the form (re)mounts, and every mutation happens
/// while the form is on screen, so there is no state to preserve across closes.
@riverpod
class AdvancedFilterViewStateNotifier
    extends _$AdvancedFilterViewStateNotifier {
  @override
  AdvancedFilterViewState build() => _deriveFromCommittedFilter();

  void setFromAddressExpandMode(ExpandMode mode) {
    state = state.copyWith(fromAddressExpandMode: mode);
  }

  void setToAddressExpandMode(ExpandMode mode) {
    state = state.copyWith(toAddressExpandMode: mode);
  }

  void reset() {
    state = _deriveFromCommittedFilter();
  }

  /// A field with committed addresses opens collapsed to a summary; an empty
  /// field opens expanded for input. Reads once (no [ref.watch]) so later filter
  /// edits do not override focus-driven expand state.
  AdvancedFilterViewState _deriveFromCommittedFilter() {
    final filter = ref.read(searchFilterProvider);
    return AdvancedFilterViewState(
      fromAddressExpandMode: _expandModeFor(filter.from.isEmpty),
      toAddressExpandMode: _expandModeFor(filter.to.isEmpty),
    );
  }

  ExpandMode _expandModeFor(bool isEmpty) =>
      isEmpty ? ExpandMode.EXPAND : ExpandMode.COLLAPSE;
}
