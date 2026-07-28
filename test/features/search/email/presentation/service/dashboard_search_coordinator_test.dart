import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_executor_provider.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/dashboard_search_coordinator.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class _RecordingExecutor extends SearchExecutorService {
  _RecordingExecutor(this._ownContainer) : super(_ownContainer);

  final ProviderContainer _ownContainer;

  int resetSessionCount = 0;

  @override
  void resetSession() => resetSessionCount++;

  void disposeContainer() => _ownContainer.dispose();
}

void main() {
  late ProviderContainer container;
  late FilterMessageOption dashboardOption;
  late DashboardSearchCoordinator coordinator;

  // Mimics the GetX `ever(filterMessageOption, ...)` bridge the controller wires:
  // a button write both stores the option and notifies the coordinator (on change).
  void writeOption(FilterMessageOption option) {
    if (dashboardOption == option) return;
    dashboardOption = option;
    coordinator.onFilterMessageOptionChanged(option);
  }

  setUp(() {
    container = ProviderContainer();
    dashboardOption = FilterMessageOption.all;
    coordinator = DashboardSearchCoordinator(
      readFilterMessageOption: () => dashboardOption,
      writeFilterMessageOption: writeOption,
      container: container,
    )..start();
  });

  tearDown(() => container.dispose());

  SearchEmailFilter committed() => container.read(searchFilterProvider);
  void setCommitted(SearchEmailFilter filter) =>
      container.read(searchFilterProvider.notifier).set(filter);
  void enableSearch() =>
      container.read(searchViewStateProvider.notifier).enableSearch();
  void openAdvancedSearch() =>
      container.read(searchViewStateProvider.notifier).openAdvancedSearch();
  void closeAdvancedSearch() =>
      container.read(searchViewStateProvider.notifier).closeAdvancedSearch();
  void focusSearchInput() =>
      container.read(searchViewStateProvider.notifier).setSearchInputFocused(true);

  // Selects `unread` on the button, opens [openSurface] and verifies it reached
  // the committed filter, then unchecks `unread` there as a search surface would.
  Future<void> selectUnreadThenUncheckInSurface(
    void Function() openSurface,
  ) async {
    dashboardOption = FilterMessageOption.unread;
    openSurface();
    await pumpEventQueue();
    expect(committed().unread, isTrue);

    setCommitted(committed().copyWith(unreadOption: const Some(false)));
    await pumpEventQueue();
  }

  group('button → search: applies the option into the committed filter', () {
    test('unread → unread flag on search entry', () async {
      dashboardOption = FilterMessageOption.unread;

      enableSearch();
      await pumpEventQueue();

      expect(committed().unread, isTrue);
    });

    test('attachments → hasAttachment flag on search entry', () async {
      dashboardOption = FilterMessageOption.attachments;

      enableSearch();
      await pumpEventQueue();

      expect(committed().hasAttachment, isTrue);
    });

    test('starred → flagged keyword on search entry', () async {
      dashboardOption = FilterMessageOption.starred;

      enableSearch();
      await pumpEventQueue();

      expect(committed().isContainFlagged, isTrue);
    });

    test('all → committed filter stays at its initial value', () async {
      dashboardOption = FilterMessageOption.all;

      enableSearch();
      await pumpEventQueue();

      expect(committed(), SearchEmailFilter.initial());
    });

    test('a live button change mirrors into the committed filter', () async {
      writeOption(FilterMessageOption.unread);
      await pumpEventQueue();

      expect(committed().unread, isTrue);
    });

    test('switching option drops the previous criterion and applies the new one',
        () async {
      writeOption(FilterMessageOption.unread);
      await pumpEventQueue();
      expect(committed().unread, isTrue);

      writeOption(FilterMessageOption.attachments);
      await pumpEventQueue();

      expect(committed().unread, isFalse);
      expect(committed().hasAttachment, isTrue);
    });

    test('re-seeds when the advanced-search panel opens', () async {
      dashboardOption = FilterMessageOption.unread;

      openAdvancedSearch();
      await pumpEventQueue();

      expect(committed().unread, isTrue);
    });

    test('re-seeds when the suggestion dropdown (input focus) opens', () async {
      dashboardOption = FilterMessageOption.attachments;

      focusSearchInput();
      await pumpEventQueue();

      expect(committed().hasAttachment, isTrue);
    });
  });

  group('search → button: clear-only, while search is active', () {
    test('turning the button criterion OFF in an active session clears the button',
        () async {
      await selectUnreadThenUncheckInSurface(enableSearch);

      expect(dashboardOption, FilterMessageOption.all);
    });

    test('turning a criterion ON in search never sets the button', () async {
      dashboardOption = FilterMessageOption.all;
      enableSearch();
      await pumpEventQueue();

      setCommitted(committed().copyWith(hasAttachmentOption: const Some(true)));
      await pumpEventQueue();

      expect(dashboardOption, FilterMessageOption.all);
    });

    test('re-enabling a criterion after it cleared the button leaves it off',
        () async {
      await selectUnreadThenUncheckInSurface(enableSearch);
      expect(dashboardOption, FilterMessageOption.all);

      setCommitted(committed().copyWith(unreadOption: const Some(true)));
      await pumpEventQueue();

      expect(dashboardOption, FilterMessageOption.all);
    });

    test('a different criterion turned off does not clear the button', () async {
      dashboardOption = FilterMessageOption.unread;
      enableSearch();
      await pumpEventQueue();

      // Attachment (not the button's criterion) toggles off; button stays.
      setCommitted(committed().copyWith(hasAttachmentOption: const Some(false)));
      await pumpEventQueue();

      expect(dashboardOption, FilterMessageOption.unread);
    });

    test('a filter reset while search is inactive keeps the button', () async {
      dashboardOption = FilterMessageOption.unread;

      // Search never activated (e.g. teardown reset path).
      setCommitted(SearchEmailFilter.initial());
      await pumpEventQueue();

      expect(dashboardOption, FilterMessageOption.unread);
    });

    test('unchecking in the advanced panel (not an active session) keeps the button',
        () async {
      await selectUnreadThenUncheckInSurface(openAdvancedSearch);

      expect(dashboardOption, FilterMessageOption.unread);
    });
  });

  test(
    'reopening the advanced panel re-applies the still-selected button after it '
    'was unchecked in the panel',
    () async {
      // Select the button, open the panel, then uncheck there: the button stays,
      // the committed filter drops it.
      await selectUnreadThenUncheckInSurface(openAdvancedSearch);
      expect(dashboardOption, FilterMessageOption.unread);
      expect(committed().unread, isFalse);

      // Close then reopen: the still-selected button is re-applied.
      closeAdvancedSearch();
      await pumpEventQueue();
      openAdvancedSearch();
      await pumpEventQueue();

      expect(committed().unread, isTrue);
    },
  );

  test('dispose resets the committed filter and cached result state', () {
    setCommitted(SearchEmailFilter(subject: 'invoice'));
    container
        .read(searchEmailPresentationProvider.notifier)
        .setCurrentSearchText('invoice');

    coordinator.dispose();

    expect(container.read(searchFilterProvider), SearchEmailFilter.initial());
    expect(
      container.read(searchEmailPresentationProvider).currentSearchText,
      isEmpty,
    );
  });

  test('dispose ends the executor session so no stale search replays next session',
      () {
    final executor = _RecordingExecutor(ProviderContainer());
    final ownContainer = ProviderContainer(overrides: [
      searchExecutorServiceProvider.overrideWithValue(executor),
    ]);
    final ownCoordinator = DashboardSearchCoordinator(
      readFilterMessageOption: () => FilterMessageOption.all,
      writeFilterMessageOption: (_) {},
      container: ownContainer,
    )..start();
    addTearDown(() {
      ownContainer.dispose();
      executor.disposeContainer();
    });

    ownCoordinator.dispose();

    expect(executor.resetSessionCount, 1);
  });
}
