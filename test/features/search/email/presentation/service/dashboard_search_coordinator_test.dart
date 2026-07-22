import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/dashboard_search_coordinator.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

void main() {
  late ProviderContainer container;
  late FilterMessageOption dashboardOption;
  late DashboardSearchCoordinator coordinator;

  setUp(() {
    container = ProviderContainer();
    dashboardOption = FilterMessageOption.all;
    coordinator = DashboardSearchCoordinator(
      readFilterMessageOption: () => dashboardOption,
      writeFilterMessageOption: (option) => dashboardOption = option,
      container: container,
    )..start();
  });

  tearDown(() => container.dispose());

  SearchEmailFilter committed() => container.read(searchFilterProvider);
  void enableSearch() =>
      container.read(searchViewStateProvider.notifier).enableSearch();
  void disableSearch() =>
      container.read(searchViewStateProvider.notifier).disableSearch();

  group('applies filter-message option into the committed SSOT on search entry', () {
    test('unread → unread flag', () async {
      dashboardOption = FilterMessageOption.unread;

      enableSearch();
      await pumpEventQueue();

      expect(committed().unread, isTrue);
    });

    test('attachments → hasAttachment flag', () async {
      dashboardOption = FilterMessageOption.attachments;

      enableSearch();
      await pumpEventQueue();

      expect(committed().hasAttachment, isTrue);
    });

    test('starred → flagged keyword', () async {
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
  });

  test('restores the option that was active before search on search exit', () async {
    dashboardOption = FilterMessageOption.starred;
    enableSearch();
    await pumpEventQueue();

    // Search cleared the dashboard option while active…
    dashboardOption = FilterMessageOption.all;
    disableSearch();
    await pumpEventQueue();

    expect(dashboardOption, FilterMessageOption.starred);
  });

  test('dispose resets the committed filter and cached result state', () {
    container
        .read(searchFilterProvider.notifier)
        .set(SearchEmailFilter(subject: 'invoice'));
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
}
