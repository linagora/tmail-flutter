import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'search_controller_test.mocks.dart';

const _me = 'me@example.com';

@GenerateNiceMocks([
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
  MockSpec<QuickSearchEmailInteractor>(),
  MockSpec<SaveRecentSearchInteractor>(),
  MockSpec<GetAllRecentSearchLatestInteractor>(),
])
void main() {
  late SearchController searchController;

  setUpAll(() {
    Get.testMode = true;
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    final authInterceptors = MockAuthorizationInterceptors();
    Get.put<AuthorizationInterceptors>(authInterceptors);
    Get.put<AuthorizationInterceptors>(authInterceptors, tag: BindingTag.isolateTag);
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(MockImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(MockUuid());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());

    searchController = SearchController(
      MockQuickSearchEmailInteractor(),
      MockSaveRecentSearchInteractor(),
      MockGetAllRecentSearchLatestInteractor(),
    );
    Get.put<SearchController>(searchController);
  });

  // Reset synchronously (not invalidate) so no deferred rebuild flushes mid-test.
  setUp(() => appProviderContainer
      .read(searchFilterProvider.notifier)
      .set(SearchEmailFilter.initial()));

  SearchEmailFilter committed() => appProviderContainer.read(searchFilterProvider);

  void toggle(QuickSearchFilter filter) =>
      searchController.toggleQuickSearchFilter(filter, currentUserEmail: _me);

  group('updateFilterEmail', () {
    test('user intent writes the committed SSOT', () {
      searchController.updateFilterEmail(unreadOption: const Some(true));

      expect(committed().unread, isTrue);
      expect(searchController.committedSearchFilter.unread, isTrue);
    });

    test('cursor options never enter the committed SSOT', () {
      searchController.updateFilterEmail(
        beforeOption: Some(UTCDate(DateTime.parse('2026-06-16T08:00:00.000Z'))),
        afterOption: Some(UTCDate(DateTime.parse('2026-06-15T08:00:00.000Z'))));

      expect(committed().before, isNull);
      expect(committed().after, isNull);
    });

    test('a later user-intent update keeps pagination out of the SSOT', () {
      searchController.updateFilterEmail(
        beforeOption: Some(UTCDate(DateTime.parse('2026-06-16T08:00:00.000Z'))),
        afterOption: Some(UTCDate(DateTime.parse('2026-06-15T08:00:00.000Z'))));
      searchController.updateFilterEmail(unreadOption: const Some(true));

      expect(committed().before, isNull);
      expect(committed().after, isNull);
      expect(searchController.committedSearchFilter.unread, isTrue);
    });
  });

  // Regression for #4421: chips must reach the committed filter immediately.
  group('toggleQuickSearchFilter', () {
    test('hasAttachment toggles committed on and off, no staging', () {
      toggle(QuickSearchFilter.hasAttachment);
      expect(committed().hasAttachment, isTrue);

      toggle(QuickSearchFilter.hasAttachment);
      expect(committed().hasAttachment, isFalse);
    });

    test('starred toggles the flagged keyword on committed', () {
      toggle(QuickSearchFilter.starred);
      expect(committed().hasKeyword, contains(KeyWordIdentifier.emailFlagged.value));

      toggle(QuickSearchFilter.starred);
      expect(committed().hasKeyword, isNot(contains(KeyWordIdentifier.emailFlagged.value)));
    });

    test('listHasKeywordFiltered is unmodifiable — no in-place mutation', () {
      searchController.updateFilterEmail(
        hasKeywordOption: Some({KeyWordIdentifier.emailFlagged.value}),
      );

      expect(
        () => searchController.listHasKeywordFiltered
            .remove(KeyWordIdentifier.emailFlagged.value),
        throwsUnsupportedError,
      );
    });

    test('removing flagged via a fresh set clears it on committed and the mirror',
        () {
      searchController.updateFilterEmail(
        hasKeywordOption: Some({KeyWordIdentifier.emailFlagged.value}),
      );
      expect(
        committed().hasKeyword,
        contains(KeyWordIdentifier.emailFlagged.value),
      );

      final keywords = {...searchController.listHasKeywordFiltered}
        ..remove(KeyWordIdentifier.emailFlagged.value);
      searchController.updateFilterEmail(hasKeywordOption: Some(keywords));

      expect(
        committed().hasKeyword,
        isNot(contains(KeyWordIdentifier.emailFlagged.value)),
      );
      expect(
        searchController.listHasKeywordFiltered,
        isNot(contains(KeyWordIdentifier.emailFlagged.value)),
      );
    });

    test('fromMe selects the current user then clears from on deselect', () {
      toggle(QuickSearchFilter.fromMe);
      expect(committed().from, {_me});

      toggle(QuickSearchFilter.fromMe);
      expect(committed().from, isEmpty);
    });

    test('fromMe collapses from to only the current user, dropping others', () {
      searchController.updateFilterEmail(
        fromOption: const Some({'other@example.com', 'friend@example.com'}),
      );

      toggle(QuickSearchFilter.fromMe);
      expect(committed().from, {_me});
    });

    test('fromMe replaces the current user when it is already the sole sender',
        () {
      searchController.updateFilterEmail(fromOption: const Some({_me}));

      toggle(QuickSearchFilter.fromMe);
      expect(committed().from, isEmpty);
    });

    test('fromMe is a no-op when the current user email is empty', () {
      searchController.updateFilterEmail(
        fromOption: const Some({'other@example.com'}),
      );

      searchController.toggleQuickSearchFilter(
        QuickSearchFilter.fromMe,
        currentUserEmail: '',
      );

      expect(committed().from, {'other@example.com'});
    });

    test('last7Days toggles the receive-time and its date range on committed', () {
      toggle(QuickSearchFilter.last7Days);
      expect(committed().emailReceiveTimeType, EmailReceiveTimeType.last7Days);
      expect(committed().startDate, isNotNull);
      expect(committed().endDate, isNotNull);

      toggle(QuickSearchFilter.last7Days);
      expect(committed().emailReceiveTimeType, EmailReceiveTimeType.allTime);
      expect(committed().startDate, isNull);
      expect(committed().endDate, isNull);
    });
  });

  group('clearSearchFilter', () {
    test('resets committed but keeps the current sort order', () {
      searchController.updateFilterEmail(
        unreadOption: const Some(true),
        sortOrderTypeOption: const Some(EmailSortOrderType.oldest),
      );

      searchController.clearSearchFilter();

      expect(committed().unread, isFalse);
      expect(committed().sortOrderType, EmailSortOrderType.oldest);
    });

  });

  // The search bar and the advanced "has the words" field are one full-text
  // term (SSOT.text). Editing either surface must reflect in the other.
  group('search bar <-> SSOT.text sync', () {
    test('typing in the search bar commits the term to the SSOT', () {
      searchController.searchInputController.text = 'hello';

      expect(committed().text?.value, 'hello');
    });

    test('a blank search bar clears the committed term', () {
      searchController.searchInputController.text = 'hello';
      searchController.searchInputController.text = '   ';

      expect(committed().text, isNull);
    });

    test('committing the term on the SSOT mirrors into the search bar', () {
      searchController.updateFilterEmail(
        textOption: Some(SearchQuery('world')),
      );

      expect(searchController.searchInputController.text, 'world');
      expect(
        searchController.searchInputController.selection.baseOffset,
        'world'.length,
      );
    });

    test('clearing the term on the SSOT clears the search bar', () {
      searchController.updateFilterEmail(
        textOption: Some(SearchQuery('world')),
      );

      searchController.updateFilterEmail(textOption: const None());

      expect(searchController.searchInputController.text, isEmpty);
    });

    test('mirroring a committed term back does not wipe the in-progress edit', () {
      searchController.searchInputController.text = 'abc';

      // The mirror sees the bar already holds the committed term and skips the
      // write-back, so the listener feedback loop never clobbers the edit.
      expect(committed().text?.value, 'abc');
      expect(searchController.searchInputController.text, 'abc');
    });
  });
}
