import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/checkbox/custom_icon_labeled_checkbox.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_email_sort_order_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form_bottom_view.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'advanced_filter_controller_test.mocks.dart';

typedef _CommittedFlagReader = bool Function(SearchEmailFilter filter);
typedef _CheckboxFinder = Finder Function();
typedef _CommittedCheckboxCase = ({
  String label,
  _CheckboxFinder findCheckbox,
  _CommittedFlagReader readFlag,
});

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  // Base controller mock specs
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  // Advanced filter controller mock specs
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<GetAutoCompleteInteractor>(),
  MockSpec<BuildContext>(),
  // Search controller mock specs
  MockSpec<QuickSearchEmailInteractor>(),
  MockSpec<SaveRecentSearchInteractor>(),
  MockSpec<GetAllRecentSearchLatestInteractor>(),
  MockSpec<StoreEmailSortOrderInteractor>(),
])
void main() {
  // Declaration advanced filter controller
  late AdvancedFilterController advancedFilterController;
  late MockMailboxDashBoardController mockMailboxDashBoardController;
  late MockGetAutoCompleteInteractor mockGetAutoCompleteInteractor;
  late MockBuildContext mockBuildContext;

  // Declaration search controller
  late SearchController searchController;
  late MockQuickSearchEmailInteractor mockQuickSearchEmailInteractor;
  late MockSaveRecentSearchInteractor mockSaveRecentSearchInteractor;
  late MockGetAllRecentSearchLatestInteractor mockGetAllRecentSearchLatestInteractor;
  late MockStoreEmailSortOrderInteractor mockStoreEmailSortOrderInteractor;

  // Declaration base controller
  late MockCachingManager mockCachingManager;
  late MockLanguageCacheManager mockLanguageCacheManager;
  late MockAuthorizationInterceptors mockAuthorizationInterceptors;
  late MockDynamicUrlInterceptors mockDynamicUrlInterceptors;
  late MockDeleteCredentialInteractor mockDeleteCredentialInteractor;
  late MockLogoutOidcInteractor mockLogoutOidcInteractor;
  late MockDeleteAuthorityOidcInteractor mockDeleteAuthorityOidcInteractor;
  late MockAppToast mockAppToast;
  late MockImagePaths mockImagePaths;
  late MockResponsiveUtils mockResponsiveUtils;
  late MockUuid mockUuid;
  late MockToastManager mockToastManager;
  late MockTwakeAppManager mockTwakeAppManager;

  SearchFilterNotifier filterNotifier() =>
      appProviderContainer.read(searchFilterProvider.notifier);

  SearchEmailFilter committedFilter() =>
      appProviderContainer.read(searchFilterProvider);

  setUpAll(() {
    Get.testMode = true;
    // Mock base controller
    mockCachingManager = MockCachingManager();
    mockLanguageCacheManager = MockLanguageCacheManager();
    mockAuthorizationInterceptors = MockAuthorizationInterceptors();
    mockDynamicUrlInterceptors = MockDynamicUrlInterceptors();
    mockDeleteCredentialInteractor = MockDeleteCredentialInteractor();
    mockLogoutOidcInteractor = MockLogoutOidcInteractor();
    mockDeleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
    mockAppToast = MockAppToast();
    mockImagePaths = MockImagePaths();
    mockResponsiveUtils = MockResponsiveUtils();
    mockUuid = MockUuid();
    mockToastManager = MockToastManager();
    mockTwakeAppManager = MockTwakeAppManager();

    Get.put<CachingManager>(mockCachingManager);
    Get.put<LanguageCacheManager>(mockLanguageCacheManager);
    Get.put<AuthorizationInterceptors>(mockAuthorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      mockAuthorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(mockDynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(mockDeleteCredentialInteractor);
    Get.put<LogoutOidcInteractor>(mockLogoutOidcInteractor);
    Get.put<DeleteAuthorityOidcInteractor>(mockDeleteAuthorityOidcInteractor);
    Get.put<AppToast>(mockAppToast);
    Get.put<ImagePaths>(mockImagePaths);
    Get.put<ResponsiveUtils>(mockResponsiveUtils);
    Get.put<Uuid>(mockUuid);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    // Mock search controller
    mockQuickSearchEmailInteractor = MockQuickSearchEmailInteractor();
    mockSaveRecentSearchInteractor = MockSaveRecentSearchInteractor();
    mockGetAllRecentSearchLatestInteractor = MockGetAllRecentSearchLatestInteractor();
    mockStoreEmailSortOrderInteractor = MockStoreEmailSortOrderInteractor();

    searchController = SearchController(
      mockQuickSearchEmailInteractor,
      mockSaveRecentSearchInteractor,
      mockGetAllRecentSearchLatestInteractor);
    Get.put<SearchController>(searchController);

    // Mock advanced filter controller
    mockMailboxDashBoardController = MockMailboxDashBoardController();
    mockGetAutoCompleteInteractor = MockGetAutoCompleteInteractor();
    mockBuildContext = MockBuildContext();

    // Stubs so Get.put below can run the controller's onInit/onReady lifecycle
    // (needed to resolve AdvancedFilterController via GetWidget in widget tests).
    when(mockMailboxDashBoardController.dashBoardAction).thenReturn(Rxn<UIAction>());
    when(mockMailboxDashBoardController.accountId).thenReturn(Rxn<AccountId>());
    when(mockMailboxDashBoardController.currentSortOrder)
        .thenReturn(SearchEmailFilter.defaultSortOrder);

    Get.put<MailboxDashBoardController>(mockMailboxDashBoardController);
    Get.put<GetAutoCompleteInteractor>(mockGetAutoCompleteInteractor);
    Get.put<StoreEmailSortOrderInteractor>(mockStoreEmailSortOrderInteractor);

    advancedFilterController = AdvancedFilterController();
    Get.put<AdvancedFilterController>(advancedFilterController);
  });

  setUp(() {
    // Reset synchronously (not invalidate) so no deferred rebuild flushes mid-test.
    appProviderContainer
        .read(searchFilterProvider.notifier)
        .set(SearchEmailFilter.initial());
    searchController.deactivateAdvancedSearch();
    searchController.deactivateSimpleSearch();
    searchController.isAdvancedSearchViewOpen.value = false;
    clearInteractions(mockMailboxDashBoardController);
  });

  group('AdvancedFilterController::test', () {
    group('applyAdvancedSearchFilter::test', () {
      test(
        'SHOULD keep the committed filter and search controller mirror in sync\n'
        'WHEN the committed advanced filter is applied',
      () async {
        // Arrange
        filterNotifier().set(SearchEmailFilter.initial());
        advancedFilterController.onTextChanged(FilterField.hasKeyword, 'Hello', filterNotifier());
        advancedFilterController.onTextChanged(FilterField.notKeyword, 'dab', filterNotifier());
        advancedFilterController.updateListEmailAddress(
          FilterField.from,
          [EmailAddress(null, 'user1@example.com')],
          filterNotifier());
        advancedFilterController.updateListEmailAddress(
          FilterField.to,
          [EmailAddress(null, 'user2@example.com')],
          filterNotifier());
        advancedFilterController.onTextChanged(FilterField.subject, 'Subject', filterNotifier());
        filterNotifier().update(SearchFilterPatch()
          ..hasAttachmentOption = const Some(true)
          ..sortOrderTypeOption = const Some(EmailSortOrderType.oldest)
          ..emailReceiveTimeTypeOption = const Some(EmailReceiveTimeType.last7Days)
          ..mailboxOption = Some(PresentationMailbox.unifiedMailbox));

        // Act
        advancedFilterController.applyAdvancedSearchFilter(
          committedFilter: committedFilter(),
          filterNotifier: filterNotifier());

        await untilCalled(mockMailboxDashBoardController.handleAdvancedSearchEmail());

        final committedSearchFilter = appProviderContainer.read(searchFilterProvider);
        final searchFilter = searchController.searchEmailFilter.value;

        // Assert
        verify(mockMailboxDashBoardController.handleAdvancedSearchEmail()).called(1);
        expect(committedSearchFilter, equals(searchFilter));
      });

      test(
        'SHOULD activate advanced search\n'
        'WHEN the applied committed filter has active criteria',
      () async {
        // Arrange
        filterNotifier().set(SearchEmailFilter(subject: 'Subject'));

        // Act
        advancedFilterController.applyAdvancedSearchFilter(
          committedFilter: committedFilter(),
          filterNotifier: filterNotifier());
        await untilCalled(mockMailboxDashBoardController.handleAdvancedSearchEmail());

        // Assert
        expect(searchController.advancedSearchIsActivated.value, isTrue);
      });

      test(
        'SHOULD deactivate advanced search\n'
        'WHEN the applied committed filter has no active criteria',
      () async {
        // Arrange
        searchController.activateAdvancedSearch();
        filterNotifier().set(SearchEmailFilter.initial());

        // Act
        advancedFilterController.applyAdvancedSearchFilter(
          committedFilter: committedFilter(),
          filterNotifier: filterNotifier());
        await untilCalled(mockMailboxDashBoardController.handleAdvancedSearchEmail());

        // Assert
        expect(searchController.advancedSearchIsActivated.value, isFalse);
      });
    });

    group('initSearchFilterField::test', () {
      test(
        'SHOULD seed controller text fields and address lists from the committed filter\n'
        'WHEN initSearchFilterField is called',
      () async {
        // Arrange
        final committedSearchFilter = SearchEmailFilter(
          text: SearchQuery('hello'),
          subject: 'subject',
          notKeyword: {'hello', 'nice'},
          emailReceiveTimeType: EmailReceiveTimeType.last7Days,
          sortOrderType: EmailSortOrderType.oldest,
          mailbox: PresentationMailbox(
            MailboxId(Id('mailbox1')),
            name: MailboxName('mailbox1')
          ),
          hasAttachment: true,
          from: {'user1@example.com'},
          to: {'user2@example.com'},
        );
        appProviderContainer.read(searchFilterProvider.notifier).set(committedSearchFilter);

        // Act
        advancedFilterController.initSearchFilterField();

        // Assert
        expect(advancedFilterController.subjectFilterInputController.text, equals('subject'));
        expect(advancedFilterController.hasKeyWordFilterInputController.text, equals('hello'));
        expect(advancedFilterController.notKeyWordFilterInputController.text, equals('hello,nice'));
        expect(advancedFilterController.listFromEmailAddress, equals([EmailAddress(null, 'user1@example.com')]));
        expect(advancedFilterController.listToEmailAddress, equals([EmailAddress(null, 'user2@example.com')]));
      });

      test(
        'SHOULD preserve the committed custom range through a reopen-and-apply round trip\n'
        'WHEN initSearchFilterField then applyAdvancedSearchFilter is called',
      () async {
        // Arrange
        final start = UTCDate(DateTime.utc(2026, 1, 1));
        final end = UTCDate(DateTime.utc(2026, 1, 31));
        appProviderContainer.read(searchFilterProvider.notifier).set(SearchEmailFilter(
          emailReceiveTimeType: EmailReceiveTimeType.customRange,
          startDate: start,
          endDate: end,
        ));

        // Act: reopen the form, then apply without touching the date range.
        advancedFilterController.initSearchFilterField();
        advancedFilterController.applyAdvancedSearchFilter(
          committedFilter: committedFilter(),
          filterNotifier: filterNotifier());
        await untilCalled(mockMailboxDashBoardController.handleAdvancedSearchEmail());

        // Assert: committed dates are not cleared.
        final committed = appProviderContainer.read(searchFilterProvider);
        expect(committed.emailReceiveTimeType, equals(EmailReceiveTimeType.customRange));
        expect(committed.startDate, equals(start));
        expect(committed.endDate, equals(end));
      });
    });

    group('removeDraggableEmailAddress::test', () {
      test(
        'SHOULD drop only the removed address from the committed from set\n'
        'WHEN a from chip is removed while others remain',
      () {
        // Arrange
        appProviderContainer.read(searchFilterProvider.notifier).set(
          SearchEmailFilter(from: {'a@example.com', 'b@example.com'}));

        // Act
        advancedFilterController.removeDraggableEmailAddress(
          DraggableEmailAddress(
            emailAddress: EmailAddress(null, 'a@example.com'),
            filterField: FilterField.from),
          filterNotifier());

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).from,
          {'b@example.com'});
      });

      test(
        'SHOULD leave the committed to set empty\n'
        'WHEN the last to chip is removed',
      () {
        // Arrange
        appProviderContainer.read(searchFilterProvider.notifier).set(
          SearchEmailFilter(to: {'a@example.com'}));

        // Act
        advancedFilterController.removeDraggableEmailAddress(
          DraggableEmailAddress(
            emailAddress: EmailAddress(null, 'a@example.com'),
            filterField: FilterField.to),
          filterNotifier());

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).to,
          isEmpty);
      });
    });

    group('onTextChanged::test', () {
      test(
        'SHOULD update the committed filter subject\n'
        'WHEN onTextChanged called with FilterField is Subject',
      () {
        // Arrange
        const filterField = FilterField.subject;
        const value = 'Subject';

        // Act
        advancedFilterController.onTextChanged(filterField, value, filterNotifier());

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).subject,
          'Subject');
      });

      test(
        'SHOULD update the committed filter text\n'
        'WHEN onTextChanged called with FilterField is hasKeyword',
      () {
        // Arrange
        const filterField = FilterField.hasKeyword;
        const value = 'keyword';

        // Act
        advancedFilterController.onTextChanged(filterField, value, filterNotifier());

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).text,
          SearchQuery('keyword'));
      });

      test(
        'SHOULD update the committed filter notKeyword\n'
        'WHEN onTextChanged called with FilterField is notKeyword',
      () {
        // Arrange
        const filterField = FilterField.notKeyword;
        const value = 'keyword1,keyword2';

        // Act
        advancedFilterController.onTextChanged(filterField, value, filterNotifier());

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).notKeyword,
          {'keyword1','keyword2'});
      });

      test(
        'SHOULD clear the committed filter subject\n'
        'WHEN onTextChanged called with FilterField is subject',
      () {
        // Arrange
        const filterField = FilterField.subject;
        const value = '   ';

        // Act
        advancedFilterController.onTextChanged(filterField, value, filterNotifier());

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).subject,
          isNull);
      });

      test(
        'SHOULD clear the committed filter notKeyword\n'
        'WHEN onTextChanged called with FilterField is notKeyword',
      () {
        // Arrange
        const filterField = FilterField.notKeyword;
        const value = '    ';

        // Act
        advancedFilterController.onTextChanged(filterField, value, filterNotifier());

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).notKeyword,
          <String>{});
      });

      test(
        'SHOULD keep subject and clear notKeyword in the committed filter\n'
        'WHEN onTextChanged called with FilterField are subject and notKeyword',
      () {
        // Arrange
        const filterFieldSubject = FilterField.subject;
        const filterFieldNotKeyword = FilterField.notKeyword;
        const validSubject = 'Subject';
        const emptyNotKeyword = '    ';

        // Act
        advancedFilterController.onTextChanged(filterFieldSubject, validSubject, filterNotifier());
        advancedFilterController.onTextChanged(filterFieldNotKeyword, emptyNotKeyword, filterNotifier());

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).subject,
          'Subject');
        expect(
          appProviderContainer.read(searchFilterProvider).notKeyword,
          <String>{});
      });
    });

    group('updateReceiveDateSearchFilter::test', () {
      test(
        'SHOULD write the receive time type and its date range to the committed filter\n'
        'WHEN a non-customRange type is selected',
      () {
        // Act
        advancedFilterController.updateReceiveDateSearchFilter(
          mockBuildContext,
          EmailReceiveTimeType.last7Days,
          committedFilter: committedFilter(),
          filterNotifier: filterNotifier(),
        );

        // Assert
        final committed = appProviderContainer.read(searchFilterProvider);
        final expectedRange = EmailReceiveTimeType.last7Days.toDateRange();
        expect(committed.emailReceiveTimeType, equals(EmailReceiveTimeType.last7Days));
        // `toDateRange()` anchors on `DateTime.now()`, so allow a small clock
        // drift between the call under test and this expectation instead of
        // asserting exact microsecond equality.
        expect(
          committed.startDate!.value
              .difference(expectedRange.start!.value)
              .abs(),
          lessThan(const Duration(seconds: 5)));
        expect(
          committed.endDate!.value
              .difference(expectedRange.end!.value)
              .abs(),
          lessThan(const Duration(seconds: 5)));
      });
    });

    group('SynchronizeEmailSortOrderAction::test', () {
      test(
        'SHOULD write sortOrderType to the committed filter\n'
        'WHEN the dashBoardAction worker dispatches SynchronizeEmailSortOrderAction',
      () {
        // Act
        mockMailboxDashBoardController.dashBoardAction.value =
          SynchronizeEmailSortOrderAction(EmailSortOrderType.oldest);

        // Assert
        expect(
          appProviderContainer.read(searchFilterProvider).sortOrderType,
          equals(EmailSortOrderType.oldest));
      });
    });
  });

  group('AdvancedSearchFilterFormBottomView checkboxes::test', () {
    Widget makeTestableWidget() {
      return UncontrolledProviderScope(
        container: appProviderContainer,
        child: GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.defaultLocale,
          home: Scaffold(
            body: AdvancedSearchFilterFormBottomView(
              focusManager: advancedFilterController.focusManager,
            ),
          ),
        ),
      );
    }

    final checkboxCases = <_CommittedCheckboxCase>[
      (
        label: 'hasAttachment',
        findCheckbox: () => find.byKey(
          const ValueKey(UiKeys.advancedSearchHasAttachmentCheckbox)),
        readFlag: (filter) => filter.hasAttachment,
      ),
      (
        label: 'unread',
        findCheckbox: () => find.byType(CustomIconLabeledCheckbox).at(1),
        readFlag: (filter) => filter.unread,
      ),
      (
        label: 'starred',
        findCheckbox: () => find.byType(CustomIconLabeledCheckbox).at(2),
        readFlag: (filter) => filter.isContainFlagged,
      ),
      (
        label: 'notIncludeEvents',
        findCheckbox: () => find.byType(CustomIconLabeledCheckbox).at(3),
        readFlag: (filter) => filter.notIncludeEvents,
      ),
    ];

    Finder searchButton() => find.descendant(
      of: find.byKey(const ValueKey(UiKeys.advancedSearchSearchButton)),
      matching: find.byType(TextButton),
    );

    group('single committed filter live updates before Search::test', () {
      for (final checkboxCase in checkboxCases) {
        testWidgets(
          'SHOULD update ${checkboxCase.label} in the committed filter without executing search\n'
          'WHEN the checkbox changes before Search is tapped',
        (tester) async {
          await tester.pumpWidget(makeTestableWidget());
          await tester.pumpAndSettle();

          await tester.tap(checkboxCase.findCheckbox());
          await tester.pumpAndSettle();

          expect(
            checkboxCase.readFlag(
              appProviderContainer.read(searchFilterProvider)),
            isTrue);
          expect(searchController.advancedSearchIsActivated.value, isFalse);
          verifyNever(
            mockMailboxDashBoardController.handleAdvancedSearchEmail());
        });
      }
    });

    group('single committed filter live clearing before Search::test', () {
      for (final checkboxCase in checkboxCases) {
        testWidgets(
          'SHOULD clear ${checkboxCase.label} in the committed filter without executing search\n'
          'WHEN the checkbox is toggled off before Search is tapped',
        (tester) async {
          await tester.pumpWidget(makeTestableWidget());
          await tester.pumpAndSettle();

          await tester.tap(checkboxCase.findCheckbox());
          await tester.pumpAndSettle();
          await tester.tap(checkboxCase.findCheckbox());
          await tester.pumpAndSettle();

          expect(
            checkboxCase.readFlag(
              appProviderContainer.read(searchFilterProvider)),
            isFalse);
          expect(searchController.advancedSearchIsActivated.value, isFalse);
          verifyNever(
            mockMailboxDashBoardController.handleAdvancedSearchEmail());
        });
      }
    });

    group('single committed filter execution on Search::test', () {
      testWidgets(
        'SHOULD activate advanced search and execute once\n'
        'WHEN Search is tapped after a live checkbox update',
      (tester) async {
        await tester.pumpWidget(makeTestableWidget());
        await tester.pumpAndSettle();

        await tester.tap(checkboxCases.first.findCheckbox());
        await tester.pumpAndSettle();
        verifyNever(mockMailboxDashBoardController.handleAdvancedSearchEmail());

        await tester.tap(searchButton());
        await tester.pumpAndSettle();
        await untilCalled(
          mockMailboxDashBoardController.handleAdvancedSearchEmail());

        verify(
          mockMailboxDashBoardController.handleAdvancedSearchEmail()).called(1);
        expect(searchController.advancedSearchIsActivated.value, isTrue);
        expect(
          appProviderContainer.read(searchFilterProvider).hasAttachment,
          isTrue);
      });

      testWidgets(
        'SHOULD deactivate advanced search and execute once\n'
        'WHEN Search is tapped after the only live checkbox is cleared',
      (tester) async {
        searchController.activateAdvancedSearch();
        await tester.pumpWidget(makeTestableWidget());
        await tester.pumpAndSettle();

        await tester.tap(checkboxCases.first.findCheckbox());
        await tester.pumpAndSettle();
        await tester.tap(checkboxCases.first.findCheckbox());
        await tester.pumpAndSettle();
        verifyNever(mockMailboxDashBoardController.handleAdvancedSearchEmail());

        await tester.tap(searchButton());
        await tester.pumpAndSettle();
        await untilCalled(
          mockMailboxDashBoardController.handleAdvancedSearchEmail());

        verify(
          mockMailboxDashBoardController.handleAdvancedSearchEmail()).called(1);
        expect(searchController.advancedSearchIsActivated.value, isFalse);
        expect(
          appProviderContainer.read(searchFilterProvider).hasAttachment,
          isFalse);
      });
    });
  });
}
