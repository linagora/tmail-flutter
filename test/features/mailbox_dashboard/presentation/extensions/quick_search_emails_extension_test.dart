import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/state_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/quick_search_emails_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'quick_search_emails_extension_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SearchController>(),
  MockSpec<QuickSearchEmailInteractor>(),
])
void main() {
  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;
  const ownEmailAddress = 'alice@linagora.com';
  const query = 'test';

  EmailSortOrderType? sortOrderType;

  late MockSearchController searchController;
  late MockQuickSearchEmailInteractor quickSearchEmailInteractor;

  setUp(() {
    quickSearchEmailInteractor = MockQuickSearchEmailInteractor();
    searchController = MockSearchController();
    when(searchController.quickSearchEmailInteractor)
        .thenReturn(quickSearchEmailInteractor);
    when(searchController.listFilterOnSuggestionForm)
        .thenReturn(<QuickSearchFilter>[].obs);
    when(
      quickSearchEmailInteractor.execute(
        any,
        any,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        filter: anyNamed('filter'),
        properties: anyNamed('properties'),
      ),
    ).thenAnswer((_) => Future.value(Right(QuickSearchEmailSuccess([]))));
  });

  group('quickSearchEmails', () {
    test(
      'should invoke quickSearchEmailInteractor.execute() with SearchController\'s sort '
      'when sortOrderType is null',
      () async {
        sortOrderType = null;
        when(searchController.searchEmailFilter)
            .thenReturn(SearchEmailFilter(sortOrderType: sortOrderType).obs);
        await searchController.quickSearchEmails(
          session: session,
          accountId: accountId,
          ownEmailAddress: ownEmailAddress,
          query: query,
        );
        verify(quickSearchEmailInteractor.execute(
          session,
          accountId,
          limit: anyNamed('limit'),
          sort: sortOrderType?.getSortOrder().toNullable(),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
        )).called(1);
      },
    );

    test(
      'should invoke quickSearchEmailInteractor.execute() with SearchController\'s sort '
      'when sortOrderType is not null',
      () async {
        sortOrderType = EmailSortOrderType.oldest;
        when(searchController.searchEmailFilter)
            .thenReturn(SearchEmailFilter(sortOrderType: sortOrderType).obs);
        await searchController.quickSearchEmails(
          session: session,
          accountId: accountId,
          ownEmailAddress: ownEmailAddress,
          query: query,
        );
        verify(quickSearchEmailInteractor.execute(
          session,
          accountId,
          limit: anyNamed('limit'),
          sort: sortOrderType?.getSortOrder().toNullable(),
          filter: anyNamed('filter'),
          properties: anyNamed('properties'),
        )).called(1);
      },
    );
  });
}
