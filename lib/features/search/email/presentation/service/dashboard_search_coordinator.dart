import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

/// Reads the dashboard's current filter-message option.
typedef FilterMessageOptionGetter = FilterMessageOption Function();

/// Writes the dashboard's filter-message option (used to restore it on search exit).
typedef FilterMessageOptionSetter = void Function(FilterMessageOption option);

/// Owns the dashboard's search-session side-effects on the search-filter SSOT, so
/// [MailboxDashBoardController] stays focused (SRP). While a search session is active
/// it mirrors the dashboard [FilterMessageOption] into the committed filter — applied
/// when search opens (so chips and the JMAP query honour it, #4490/#4590) and restored
/// when it closes. On [dispose] it resets every search provider so no committed filter
/// or cached result leaks into the next session (ADR-0093). GetX→Riverpod bridge: it
/// reads/writes the dashboard option through injected callbacks, never GetX directly.
class DashboardSearchCoordinator {
  DashboardSearchCoordinator({
    required FilterMessageOptionGetter readFilterMessageOption,
    required FilterMessageOptionSetter writeFilterMessageOption,
    ProviderContainer? container,
  })  : _readFilterMessageOption = readFilterMessageOption,
        _writeFilterMessageOption = writeFilterMessageOption,
        _container = container ?? appProviderContainer;

  final FilterMessageOptionGetter _readFilterMessageOption;
  final FilterMessageOptionSetter _writeFilterMessageOption;
  final ProviderContainer _container;

  ProviderSubscription<SearchViewState>? _subscription;
  FilterMessageOption? _optionBeforeSearch;

  /// Starts mirroring the filter-message option across search-session transitions.
  void start() {
    _subscription = _container.listen<SearchViewState>(
      searchViewStateProvider,
      _onSearchViewStateChanged,
    );
  }

  void _onSearchViewStateChanged(
    SearchViewState? previous,
    SearchViewState next,
  ) {
    final wasSearchActive = previous?.isSearchActive ?? false;
    if (!wasSearchActive && next.isSearchActive) {
      _applyFilterMessageOptionToSearch();
    } else if (wasSearchActive && !next.isSearchActive) {
      _restoreFilterMessageOption();
    }
  }

  /// Writes the current filter-message option into the committed filter, keeping the
  /// prior value so [_restoreFilterMessageOption] can put it back on search exit.
  void _applyFilterMessageOptionToSearch() {
    _optionBeforeSearch = _readFilterMessageOption();
    final resolved =
        _optionBeforeSearch!.applyTo(_container.read(searchFilterProvider));
    _container.read(searchFilterProvider.notifier).set(resolved);
  }

  void _restoreFilterMessageOption() {
    _writeFilterMessageOption(_optionBeforeSearch ?? FilterMessageOption.all);
    _optionBeforeSearch = null;
  }

  /// Stops mirroring and resets the search providers. Invalidate before any post-logout
  /// rebuild reads them (ADR-0093 §Decision, #4490/#4590).
  void dispose() {
    _subscription?.close();
    _subscription = null;
    _container.invalidate(searchFilterProvider);
    _container.invalidate(searchEmailProvider);
    _container.invalidate(searchEmailPresentationProvider);
  }
}
