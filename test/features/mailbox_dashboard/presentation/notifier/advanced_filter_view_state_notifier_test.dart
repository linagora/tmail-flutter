import 'package:flutter_test/flutter_test.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_filter_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/advanced_filter_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  AdvancedFilterViewState state() =>
      container.read(advancedFilterViewStateProvider);

  void seedCommittedFilter(SearchEmailFilter filter) =>
      container.read(searchFilterProvider.notifier).set(filter);

  test('starts expanded when the committed filter has no addresses', () {
    expect(state().fromAddressExpandMode, ExpandMode.EXPAND);
    expect(state().toAddressExpandMode, ExpandMode.EXPAND);
  });

  test('opens collapsed for address fields already committed', () {
    seedCommittedFilter(SearchEmailFilter(from: {'a@example.com'}));

    expect(state().fromAddressExpandMode, ExpandMode.COLLAPSE);
    expect(state().toAddressExpandMode, ExpandMode.EXPAND);
  });

  test('updates each address mode independently', () {
    final notifier = container.read(advancedFilterViewStateProvider.notifier);

    notifier.setFromAddressExpandMode(ExpandMode.COLLAPSE);
    notifier.setToAddressExpandMode(ExpandMode.EXPAND);

    expect(state().fromAddressExpandMode, ExpandMode.COLLAPSE);
    expect(state().toAddressExpandMode, ExpandMode.EXPAND);
  });

  test('reset restores both address modes', () {
    final notifier = container.read(advancedFilterViewStateProvider.notifier);
    notifier.setFromAddressExpandMode(ExpandMode.COLLAPSE);
    notifier.setToAddressExpandMode(ExpandMode.COLLAPSE);

    notifier.reset();

    expect(state(), AdvancedFilterViewState.initial());
  });
}
