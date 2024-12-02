import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'advanced_filter_controller_test.mocks.dart';

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
  MockSpec<ApplicationManager>(),
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
  late MockApplicationManager mockApplicationManager;
  late MockToastManager mockToastManager;
  late MockTwakeAppManager mockTwakeAppManager;

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
    mockApplicationManager = MockApplicationManager();
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
    Get.put<ApplicationManager>(mockApplicationManager);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    // Mock search controller
    mockQuickSearchEmailInteractor = MockQuickSearchEmailInteractor();
    mockSaveRecentSearchInteractor = MockSaveRecentSearchInteractor();
    mockGetAllRecentSearchLatestInteractor = MockGetAllRecentSearchLatestInteractor();

    searchController = SearchController(
      mockQuickSearchEmailInteractor,
      mockSaveRecentSearchInteractor,
      mockGetAllRecentSearchLatestInteractor);
    Get.put<SearchController>(searchController);

    // Mock advanced filter controller
    mockMailboxDashBoardController = MockMailboxDashBoardController();
    mockGetAutoCompleteInteractor = MockGetAutoCompleteInteractor();
    mockBuildContext = MockBuildContext();

    Get.put<MailboxDashBoardController>(mockMailboxDashBoardController);
    Get.put<GetAutoCompleteInteractor>(mockGetAutoCompleteInteractor);

    advancedFilterController = AdvancedFilterController();
  });

  group('AdvancedFilterController::test', () {
    group('applyAdvancedSearchFilter::test', () {
      test('SHOULD make sure memory search filter and search filter should be the same after applying', () async {
        // Arrange
        advancedFilterController.hasKeyWordFilterInputController.text = 'Hello';
        advancedFilterController.notKeyWordFilterInputController.text = 'dab';
        advancedFilterController.listFromEmailAddress = [EmailAddress(null, 'user1@example.com')];
        advancedFilterController.listToEmailAddress = [EmailAddress(null, 'user2@example.com')];
        advancedFilterController.sortOrderType.value = EmailSortOrderType.oldest;
        advancedFilterController.setDestinationMailboxSelected(PresentationMailbox.unifiedMailbox);
        advancedFilterController.subjectFilterInputController.text = 'Subject';
        advancedFilterController.receiveTimeType.value = EmailReceiveTimeType.last7Days;
        advancedFilterController.hasAttachment.value = true;

        // Act
        advancedFilterController.applyAdvancedSearchFilter();

        await untilCalled(mockMailboxDashBoardController.handleAdvancedSearchEmail());

        final memorySearchFilter = advancedFilterController.memorySearchFilter;
        final searchFilter = searchController.searchEmailFilter.value;

        // Assert
        verify(mockMailboxDashBoardController.handleAdvancedSearchEmail()).called(1);
        expect(memorySearchFilter, equals(searchFilter));
      });
    });

    group('initSearchFilterField::test', () {
      test(
        'SHOULD make sure the values of the variables in the controller are the same as the values of the MemorySearchFilter\n'
        'WHEN initSearchFilterField is called',
      () async {
        // Arrange
        final memorySearchFilter = SearchEmailFilter(
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
        advancedFilterController.setMemorySearchFilter(memorySearchFilter);

        // Act
        advancedFilterController.initSearchFilterField(mockBuildContext);

        // Assert
        expect(advancedFilterController.subjectFilterInputController.text, equals('subject'));
        expect(advancedFilterController.hasKeyWordFilterInputController.text, equals('hello'));
        expect(advancedFilterController.notKeyWordFilterInputController.text, equals('hello,nice'));
        expect(advancedFilterController.receiveTimeType.value, equals(EmailReceiveTimeType.last7Days));
        expect(advancedFilterController.sortOrderType.value, equals(EmailSortOrderType.oldest));
        expect(advancedFilterController.mailBoxFilterInputController.text, equals('mailbox1'));
        expect(advancedFilterController.hasAttachment.value, equals(true));
        expect(advancedFilterController.listFromEmailAddress, equals([EmailAddress(null, 'user1@example.com')]));
        expect(advancedFilterController.listToEmailAddress, equals([EmailAddress(null, 'user2@example.com')]));
      });
    });

    group('onTextChanged::test', () {
      test(
        'SHOULD update memory search filter for subject\n'
        'WHEN onTextChanged called with AdvancedSearchFilterField is Subject',
      () {
        // Arrange
        const filterField = AdvancedSearchFilterField.subject;
        const value = 'Subject';

        // Act
        advancedFilterController.onTextChanged(filterField, value);

        // Assert
        expect(
          advancedFilterController.memorySearchFilter.subject,
          'Subject');
      });

      test(
        'SHOULD update memory search filter for text\n'
        'WHEN onTextChanged called with AdvancedSearchFilterField is hasKeyword',
      () {
        // Arrange
        const filterField = AdvancedSearchFilterField.hasKeyword;
        const value = 'keyword';

        // Act
        advancedFilterController.onTextChanged(filterField, value);

        // Assert
        expect(
          advancedFilterController.memorySearchFilter.text,
          SearchQuery('keyword'));
      });

      test(
        'SHOULD update memory search filter for notKeyword\n'
        'WHEN onTextChanged called with AdvancedSearchFilterField is notKeyword',
      () {
        // Arrange
        const filterField = AdvancedSearchFilterField.notKeyword;
        const value = 'keyword1,keyword2';

        // Act
        advancedFilterController.onTextChanged(filterField, value);

        // Assert
        expect(
          advancedFilterController.memorySearchFilter.notKeyword,
          {'keyword1','keyword2'});
      });

      test(
        'SHOULD update memory search filter for subject is null\n'
        'WHEN onTextChanged called with AdvancedSearchFilterField is subject',
      () {
        // Arrange
        const filterField = AdvancedSearchFilterField.subject;
        const value = '   ';

        // Act
        advancedFilterController.onTextChanged(filterField, value);

        // Assert
        expect(
          advancedFilterController.memorySearchFilter.subject,
          isNull);
      });

      test(
        'SHOULD update memory search filter for notKeyword is empty values\n'
        'WHEN onTextChanged called with AdvancedSearchFilterField is notKeyword',
      () {
        // Arrange
        const filterField = AdvancedSearchFilterField.notKeyword;
        const value = '    ';

        // Act
        advancedFilterController.onTextChanged(filterField, value);

        // Assert
        expect(
          advancedFilterController.memorySearchFilter.notKeyword,
          <String>{});
      });

      test(
        'SHOULD update memory search filter for subject and notKeyword is empty values\n'
        'WHEN onTextChanged called with AdvancedSearchFilterField are subject and notKeyword',
      () {
        // Arrange
        const filterFieldSubject = AdvancedSearchFilterField.subject;
        const filterFieldNotKeyword = AdvancedSearchFilterField.notKeyword;
        const validSubject = 'Subject';
        const emptyNotKeyword = '    ';

        // Act
        advancedFilterController.onTextChanged(filterFieldSubject, validSubject);
        advancedFilterController.onTextChanged(filterFieldNotKeyword, emptyNotKeyword);

        // Assert
        expect(
          advancedFilterController.memorySearchFilter.subject,
          'Subject');
        expect(
          advancedFilterController.memorySearchFilter.notKeyword,
          <String>{});
      });
    });
  });
}