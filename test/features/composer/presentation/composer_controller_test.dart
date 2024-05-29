import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_save_email_to_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/download_image_as_base64_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/transform_html_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_composed_email_to_local_storage_browser_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_always_read_receipt_setting_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_image_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:uuid/uuid.dart';

import '../../../fixtures/account_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';
import 'composer_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<LocalFilePickerInteractor>(),
  MockSpec<LocalImagePickerInteractor>(),
  MockSpec<GetEmailContentInteractor>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<UploadController>(),
  MockSpec<RemoveComposerCacheOnWebInteractor>(),
  MockSpec<SaveComposerCacheOnWebInteractor>(),
  MockSpec<DownloadImageAsBase64Interactor>(),
  MockSpec<TransformHtmlEmailContentInteractor>(),
  MockSpec<GetAlwaysReadReceiptSettingInteractor>(),
  MockSpec<CreateNewAndSendEmailInteractor>(),
  MockSpec<CreateNewAndSaveEmailToDraftsInteractor>(),
  MockSpec<StoreComposedEmailToLocalStorageBrowserInteractor>(),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<NetworkConnectionController>(fallbackGenerators: fallbackGenerators),
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
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ComposerController composerController;
  late MockLocalFilePickerInteractor mockLocalFilePickerInteractor;
  late MockLocalImagePickerInteractor mockLocalImagePickerInteractor;
  late MockGetEmailContentInteractor mockGetEmailContentInteractor;
  late MockGetAllIdentitiesInteractor mockGetAllIdentitiesInteractor;
  late MockUploadController mockUploadController;
  late MockRemoveComposerCacheOnWebInteractor mockRemoveComposerCacheOnWebInteractor;
  late MockSaveComposerCacheOnWebInteractor mockSaveComposerCacheOnWebInteractor;
  late MockDownloadImageAsBase64Interactor mockDownloadImageAsBase64Interactor;
  late MockTransformHtmlEmailContentInteractor mockTransformHtmlEmailContentInteractor;
  late MockGetAlwaysReadReceiptSettingInteractor mockGetAlwaysReadReceiptSettingInteractor;
  late MockCreateNewAndSendEmailInteractor mockCreateNewAndSendEmailInteractor;
  late MockCreateNewAndSaveEmailToDraftsInteractor mockCreateNewAndSaveEmailToDraftsInteractor;
  late MockStoreComposedEmailToLocalStorageBrowserInteractor mockStoreComposedEmailToLocalStorageBrowserInteractor;

  late MockNetworkConnectionController mockNetworkConnectionController;
  late MockMailboxDashBoardController mockMailboxDashBoardController;

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

  setUpAll(() {
    mockLocalFilePickerInteractor = MockLocalFilePickerInteractor();
    mockLocalImagePickerInteractor = MockLocalImagePickerInteractor();
    mockGetEmailContentInteractor = MockGetEmailContentInteractor();
    mockGetAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
    mockUploadController = MockUploadController();
    mockRemoveComposerCacheOnWebInteractor = MockRemoveComposerCacheOnWebInteractor();
    mockSaveComposerCacheOnWebInteractor = MockSaveComposerCacheOnWebInteractor();
    mockDownloadImageAsBase64Interactor = MockDownloadImageAsBase64Interactor();
    mockTransformHtmlEmailContentInteractor = MockTransformHtmlEmailContentInteractor();
    mockGetAlwaysReadReceiptSettingInteractor = MockGetAlwaysReadReceiptSettingInteractor();
    mockCreateNewAndSendEmailInteractor = MockCreateNewAndSendEmailInteractor();
    mockCreateNewAndSaveEmailToDraftsInteractor = MockCreateNewAndSaveEmailToDraftsInteractor();
    mockStoreComposedEmailToLocalStorageBrowserInteractor = MockStoreComposedEmailToLocalStorageBrowserInteractor();

    mockNetworkConnectionController = MockNetworkConnectionController();
    mockMailboxDashBoardController = MockMailboxDashBoardController();

    // mock base controller
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

    Get.put<NetworkConnectionController>(mockNetworkConnectionController);
    Get.put<MailboxDashBoardController>(mockMailboxDashBoardController);

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
    
    Get.testMode = true;

    composerController = ComposerController(
      mockLocalFilePickerInteractor,
      mockLocalImagePickerInteractor,
      mockGetEmailContentInteractor,
      mockGetAllIdentitiesInteractor,
      mockUploadController,
      mockRemoveComposerCacheOnWebInteractor,
      mockSaveComposerCacheOnWebInteractor,
      mockDownloadImageAsBase64Interactor,
      mockTransformHtmlEmailContentInteractor,
      mockGetAlwaysReadReceiptSettingInteractor,
      mockCreateNewAndSendEmailInteractor,
      mockCreateNewAndSaveEmailToDraftsInteractor,
      mockStoreComposedEmailToLocalStorageBrowserInteractor,
    );
  });

  group("ComposerController::onOpenNewTabAction test", () {
    test(
      'WHEN onOpenNewTabAction invoked\n'
      'THEN _storeComposedEmailToLocalStorageBrowserInteractor should be executed',
    () async {
      // Arrange
      when(mockMailboxDashBoardController.accountId).thenReturn(Rxn(AccountFixtures.aliceAccountId));
      when(mockMailboxDashBoardController.sessionCurrent).thenReturn(SessionFixtures.aliceSession);

      composerController.composerArguments.value = ComposerArguments();
      composerController.openNewTabButtonState = ButtonState.enabled;

      // Act
      composerController.onOpenNewTabAction();

      await untilCalled(mockStoreComposedEmailToLocalStorageBrowserInteractor.execute(any));

      // Assert
      verify(mockStoreComposedEmailToLocalStorageBrowserInteractor.execute(any)).called(1);
    });
  });

  tearDown(() {
    Get.deleteAll();
  });
}