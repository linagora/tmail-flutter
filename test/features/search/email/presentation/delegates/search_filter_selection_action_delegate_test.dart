import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/presentation/delegates/search_filter_selection_action_delegate.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';

class _MockSearchEmailController extends Mock implements SearchEmailController {}

void main() {
  group('SearchFilterSelectionActionDelegate', () {
    late _MockSearchEmailController controller;
    late SearchFilterSelectionActionDelegate delegate;

    setUp(() {
      controller = _MockSearchEmailController();
      delegate = SearchFilterSelectionActionDelegate(controller: controller);
    });

    /// Pumps a [Consumer] to obtain a real [WidgetRef]/[BuildContext], then
    /// dispatches [filter] through the delegate and returns the [WidgetRef] the
    /// delegate handed to the controller. [WidgetRef] is sealed in Riverpod 3,
    /// so it cannot be mocked and must come from a widget tree.
    Future<WidgetRef> dispatch(
      WidgetTester tester,
      QuickSearchFilter filter, {
      SearchEmailFilter? searchEmailFilter,
    }) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              capturedRef = ref;
              delegate.onSelectSearchFilterAction(
                SearchFilterSelectionActionRequest(
                  ref: ref,
                  context: context,
                  searchFilter: filter,
                  searchEmailFilter:
                      searchEmailFilter ?? SearchEmailFilter.initial(),
                ),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return capturedRef;
    }

    testWidgets('routes hasAttachment to selectHasAttachmentSearchFilter',
        (tester) async {
      final ref = await dispatch(tester, QuickSearchFilter.hasAttachment);

      verify(controller.selectHasAttachmentSearchFilter(ref)).called(1);
      verifyNoMoreInteractions(controller);
    });

    testWidgets('routes unread to selectUnreadSearchFilter', (tester) async {
      final ref = await dispatch(tester, QuickSearchFilter.unread);

      verify(controller.selectUnreadSearchFilter(ref)).called(1);
      verifyNoMoreInteractions(controller);
    });

    testWidgets('routes events to selectNotIncludeEventsSearchFilter',
        (tester) async {
      final ref = await dispatch(tester, QuickSearchFilter.events);

      verify(controller.selectNotIncludeEventsSearchFilter(ref)).called(1);
      verifyNoMoreInteractions(controller);
    });

    testWidgets('routes starred to selectKeywordsSearchFilter with flagged '
        'keyword', (tester) async {
      final ref = await dispatch(tester, QuickSearchFilter.starred);

      verify(
        controller.selectKeywordsSearchFilter(
          ref,
          KeyWordIdentifier.emailFlagged,
        ),
      ).called(1);
      verifyNoMoreInteractions(controller);
    });

    testWidgets('routes folder to selectMailboxForSearchFilter with the mailbox',
        (tester) async {
      final filter = SearchEmailFilter.initial();

      final ref = await dispatch(
        tester,
        QuickSearchFilter.folder,
        searchEmailFilter: filter,
      );

      verify(
        controller.selectMailboxForSearchFilter(ref, filter.mailbox),
      ).called(1);
      verifyNoMoreInteractions(controller);
    });

    testWidgets('last7Days is a no-op on the controller', (tester) async {
      await dispatch(tester, QuickSearchFilter.last7Days);

      verifyZeroInteractions(controller);
    });

    testWidgets('fromMe is a no-op on the controller', (tester) async {
      await dispatch(tester, QuickSearchFilter.fromMe);

      verifyZeroInteractions(controller);
    });
  });
}
