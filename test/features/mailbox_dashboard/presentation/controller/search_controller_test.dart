import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
    test('user intent writes the committed SSOT and the mirror syncs the obs', () {
      searchController.updateFilterEmail(unreadOption: const Some(true));

      expect(committed().unread, isTrue);
      expect(searchController.searchEmailFilter.value.unread, isTrue);
    });

    test('cursor options stay on the obs, never in the committed SSOT', () {
      searchController.updateFilterEmail(positionOption: const Some(40));

      expect(committed().position, isNull);
      expect(searchController.searchEmailFilter.value.position, 40);
    });

    test('a later user-intent update must not clobber an existing cursor', () {
      searchController.updateFilterEmail(positionOption: const Some(40));
      searchController.updateFilterEmail(unreadOption: const Some(true));

      expect(searchController.searchEmailFilter.value.position, 40);
      expect(searchController.searchEmailFilter.value.unread, isTrue);
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

    test('fromMe adds then removes the current user in from', () {
      toggle(QuickSearchFilter.fromMe);
      expect(committed().from, contains(_me));

      toggle(QuickSearchFilter.fromMe);
      expect(committed().from, isNot(contains(_me)));
    });

    test('fromMe is a no-op when the current user email is empty', () {
      searchController.toggleQuickSearchFilter(
        QuickSearchFilter.fromMe,
        currentUserEmail: '',
      );

      expect(committed().from, isEmpty);
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
}
