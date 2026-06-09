import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'search_controller_test.mocks.dart';

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
    final mockAuth = MockAuthorizationInterceptors();
    Get.put<AuthorizationInterceptors>(mockAuth);
    Get.put<AuthorizationInterceptors>(mockAuth, tag: BindingTag.isolateTag);
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

  setUp(() {
    searchController.searchEmailFilter.value = SearchEmailFilter.initial();
    searchController.listFilterOnSuggestionForm.clear();
    searchController.removedSuggestionFilters.clear();
  });

  group('SearchController::mergeWithSuggestionFilters', () {
    group('last7Days filter', () {
      test(
        'SHOULD set emailReceiveTimeType to last7Days\n'
        'WHEN last7Days is in listFilterOnSuggestionForm',
        () {
          // Arrange
          searchController.listFilterOnSuggestionForm.add(QuickSearchFilter.last7Days);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.emailReceiveTimeType, equals(EmailReceiveTimeType.last7Days));
        },
      );

      test(
        'SHOULD clear emailReceiveTimeType to allTime\n'
        'WHEN last7Days is in removedSuggestionFilters',
        () {
          // Arrange
          searchController.searchEmailFilter.value = SearchEmailFilter(
            emailReceiveTimeType: EmailReceiveTimeType.last7Days,
          );
          searchController.removedSuggestionFilters.add(QuickSearchFilter.last7Days);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.emailReceiveTimeType, equals(EmailReceiveTimeType.allTime));
        },
      );

      test(
        'SHOULD keep base emailReceiveTimeType unchanged\n'
        'WHEN last7Days is neither in suggestion nor removed lists',
        () {
          // Arrange
          searchController.searchEmailFilter.value = SearchEmailFilter(
            emailReceiveTimeType: EmailReceiveTimeType.last7Days,
          );

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.emailReceiveTimeType, equals(EmailReceiveTimeType.last7Days));
        },
      );
    });

    group('hasAttachment filter', () {
      test(
        'SHOULD set hasAttachment to true\n'
        'WHEN hasAttachment is in listFilterOnSuggestionForm',
        () {
          // Arrange
          searchController.listFilterOnSuggestionForm.add(QuickSearchFilter.hasAttachment);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.hasAttachment, isTrue);
        },
      );

      test(
        'SHOULD clear hasAttachment to false\n'
        'WHEN hasAttachment is in removedSuggestionFilters',
        () {
          // Arrange
          searchController.searchEmailFilter.value = SearchEmailFilter(hasAttachment: true);
          searchController.removedSuggestionFilters.add(QuickSearchFilter.hasAttachment);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.hasAttachment, isFalse);
        },
      );

      test(
        'SHOULD keep base hasAttachment unchanged\n'
        'WHEN hasAttachment is neither in suggestion nor removed lists',
        () {
          // Arrange
          searchController.searchEmailFilter.value = SearchEmailFilter(hasAttachment: true);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.hasAttachment, isTrue);
        },
      );
    });

    group('starred filter', () {
      test(
        'SHOULD add flagged keyword to hasKeyword\n'
        'WHEN starred is in listFilterOnSuggestionForm',
        () {
          // Arrange
          searchController.listFilterOnSuggestionForm.add(QuickSearchFilter.starred);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.hasKeyword, contains(KeyWordIdentifier.emailFlagged.value));
        },
      );

      test(
        'SHOULD clear hasKeyword\n'
        'WHEN starred is in removedSuggestionFilters',
        () {
          // Arrange
          searchController.searchEmailFilter.value = SearchEmailFilter(
            hasKeyword: {KeyWordIdentifier.emailFlagged.value},
          );
          searchController.removedSuggestionFilters.add(QuickSearchFilter.starred);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.hasKeyword, isEmpty);
        },
      );

      test(
        'SHOULD keep base hasKeyword unchanged\n'
        'WHEN starred is neither in suggestion nor removed lists',
        () {
          // Arrange
          searchController.searchEmailFilter.value = SearchEmailFilter(
            hasKeyword: {KeyWordIdentifier.emailFlagged.value},
          );

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.hasKeyword, contains(KeyWordIdentifier.emailFlagged.value));
        },
      );
    });

    group('fromMe filter', () {
      const userEmail = 'me@example.com';

      test(
        'SHOULD add currentUserEmail to from set\n'
        'WHEN fromMe is in listFilterOnSuggestionForm and email is non-empty',
        () {
          // Arrange
          searchController.listFilterOnSuggestionForm.add(QuickSearchFilter.fromMe);

          // Act
          final result = searchController.mergeWithSuggestionFilters(userEmail);

          // Assert
          expect(result.from, contains(userEmail));
        },
      );

      test(
        'SHOULD preserve existing from addresses and add currentUserEmail\n'
        'WHEN fromMe added and base filter already has from addresses',
        () {
          // Arrange
          const existingEmail = 'other@example.com';
          searchController.searchEmailFilter.value = SearchEmailFilter(
            from: {existingEmail},
          );
          searchController.listFilterOnSuggestionForm.add(QuickSearchFilter.fromMe);

          // Act
          final result = searchController.mergeWithSuggestionFilters(userEmail);

          // Assert
          expect(result.from, containsAll([existingEmail, userEmail]));
        },
      );

      test(
        'SHOULD remove currentUserEmail from from set\n'
        'WHEN fromMe is in removedSuggestionFilters',
        () {
          // Arrange
          searchController.searchEmailFilter.value = SearchEmailFilter(
            from: {userEmail},
          );
          searchController.removedSuggestionFilters.add(QuickSearchFilter.fromMe);

          // Act
          final result = searchController.mergeWithSuggestionFilters(userEmail);

          // Assert
          expect(result.from, isNot(contains(userEmail)));
        },
      );

      test(
        'SHOULD NOT modify from set\n'
        'WHEN fromMe is in listFilterOnSuggestionForm but currentUserEmail is empty',
        () {
          // Arrange
          searchController.listFilterOnSuggestionForm.add(QuickSearchFilter.fromMe);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.from, isEmpty);
        },
      );
    });

    group('multiple filters combined', () {
      test(
        'SHOULD apply all active suggestion filters simultaneously\n'
        'WHEN multiple filters are in listFilterOnSuggestionForm',
        () {
          // Arrange
          searchController.listFilterOnSuggestionForm.addAll([
            QuickSearchFilter.last7Days,
            QuickSearchFilter.hasAttachment,
            QuickSearchFilter.starred,
          ]);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.emailReceiveTimeType, equals(EmailReceiveTimeType.last7Days));
          expect(result.hasAttachment, isTrue);
          expect(result.hasKeyword, contains(KeyWordIdentifier.emailFlagged.value));
        },
      );

      test(
        'SHOULD clear all removed filters simultaneously\n'
        'WHEN multiple filters are in removedSuggestionFilters',
        () {
          // Arrange
          searchController.searchEmailFilter.value = SearchEmailFilter(
            emailReceiveTimeType: EmailReceiveTimeType.last7Days,
            hasAttachment: true,
            hasKeyword: {KeyWordIdentifier.emailFlagged.value},
          );
          searchController.removedSuggestionFilters.addAll([
            QuickSearchFilter.last7Days,
            QuickSearchFilter.hasAttachment,
            QuickSearchFilter.starred,
          ]);

          // Act
          final result = searchController.mergeWithSuggestionFilters('');

          // Assert
          expect(result.emailReceiveTimeType, equals(EmailReceiveTimeType.allTime));
          expect(result.hasAttachment, isFalse);
          expect(result.hasKeyword, isEmpty);
        },
      );
    });

    group('does not mutate searchEmailFilter', () {
      test(
        'SHOULD NOT modify searchEmailFilter.value\n'
        'WHEN mergeWithSuggestionFilters is called',
        () {
          // Arrange
          final original = SearchEmailFilter.initial();
          searchController.searchEmailFilter.value = original;
          searchController.listFilterOnSuggestionForm.addAll([
            QuickSearchFilter.last7Days,
            QuickSearchFilter.hasAttachment,
            QuickSearchFilter.starred,
          ]);

          // Act
          searchController.mergeWithSuggestionFilters('user@example.com');

          // Assert: searchEmailFilter must remain unchanged
          expect(searchController.searchEmailFilter.value, equals(original));
        },
      );
    });
  });
}
