import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/save_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/transform_html_signature_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/add_identity_to_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/clean_up_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/delete_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/remove_identity_from_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/clean_up_public_assets_interactor_bindings.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../../fixtures/session_fixtures.dart';
import 'identities_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  // Base controller mockspecs
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

  // Reloadable controller mockspecs
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetAuthenticatedAccountInteractor>(),
  MockSpec<UpdateAccountCacheInteractor>(),

  // Identities controller mockspecs
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<DeleteIdentityInteractor>(),
  MockSpec<CreateNewIdentityInteractor>(),
  MockSpec<EditIdentityInteractor>(),
  MockSpec<CreateNewDefaultIdentityInteractor>(),
  MockSpec<EditDefaultIdentityInteractor>(),
  MockSpec<TransformHtmlSignatureInteractor>(),
  MockSpec<ManageAccountDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<SaveIdentityCacheOnWebInteractor>(),
  MockSpec<BeforeReconnectManager>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late IdentitiesController identitiesController;
  late MockGetAllIdentitiesInteractor mockGetAllIdentitiesInteractor;
  late MockDeleteIdentityInteractor mockDeleteIdentityInteractor;
  late MockCreateNewIdentityInteractor mockCreateNewIdentityInteractor;
  late MockEditIdentityInteractor mockEditIdentityInteractor;
  late MockCreateNewDefaultIdentityInteractor mockCreateNewDefaultIdentityInteractor;
  late MockEditDefaultIdentityInteractor mockEditDefaultIdentityInteractor;
  late MockTransformHtmlSignatureInteractor mockTransformHtmlSignatureInteractor;
  late MockManageAccountDashBoardController mockManageAccountDashBoardController;

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

  late MockSaveIdentityCacheOnWebInteractor mockSaveIdentityCacheOnWebInteractor;

  setUpAll(() {
    //mock base controller
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

    mockSaveIdentityCacheOnWebInteractor = MockSaveIdentityCacheOnWebInteractor();

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

    // mock reloadable controller
    Get.put<GetSessionInteractor>(MockGetSessionInteractor());
    Get.put<GetAuthenticatedAccountInteractor>(MockGetAuthenticatedAccountInteractor());
    Get.put<UpdateAccountCacheInteractor>(MockUpdateAccountCacheInteractor());

    // mock identities controller
    mockGetAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
    mockDeleteIdentityInteractor = MockDeleteIdentityInteractor();
    mockCreateNewIdentityInteractor = MockCreateNewIdentityInteractor();
    mockEditIdentityInteractor = MockEditIdentityInteractor();
    mockCreateNewDefaultIdentityInteractor = MockCreateNewDefaultIdentityInteractor();
    mockEditDefaultIdentityInteractor = MockEditDefaultIdentityInteractor();
    mockTransformHtmlSignatureInteractor = MockTransformHtmlSignatureInteractor();

    mockManageAccountDashBoardController = MockManageAccountDashBoardController();
    Get.put<BeforeReconnectManager>(MockBeforeReconnectManager());

    Get.put<ManageAccountDashBoardController>(mockManageAccountDashBoardController);

    Get.testMode = true;

    identitiesController = IdentitiesController(
      mockGetAllIdentitiesInteractor,
      mockDeleteIdentityInteractor,
      mockCreateNewIdentityInteractor,
      mockEditIdentityInteractor,
      mockCreateNewDefaultIdentityInteractor,
      mockEditDefaultIdentityInteractor,
      mockTransformHtmlSignatureInteractor,
      mockSaveIdentityCacheOnWebInteractor);
  });

  group('identities controller test:', () {
    test(
      'should deregister all interactor of clean up public assets interactor binding '
      'when identity screen is closed',
    () {
      // arrange
      CleanUpPublicAssetsInteractorBindings().dependencies();
      expect(
        Get.isRegistered<CleanUpPublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        true);
      expect(
        Get.isRegistered<RemoveIdentityFromPublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        true);
      expect(
        Get.isRegistered<DeletePublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        true);
      expect(
        Get.isRegistered<AddIdentityToPublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        true);

      // act
      identitiesController.onClose();
      
      // assert
      expect(
        Get.isRegistered<CleanUpPublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        false);
      expect(
        Get.isRegistered<RemoveIdentityFromPublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        false);
      expect(
        Get.isRegistered<DeletePublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        false);
      expect(
        Get.isRegistered<AddIdentityToPublicAssetsInteractor>(
          tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag),
        false);
    });

    test(
      'should only show identities with name not empty',
    () async {
      // arrange
      final identity1 = Identity(name: '', mayDelete: true);
      final identity2 = Identity(mayDelete: true);
      final identity3 = Identity(name: 'valid name', mayDelete: true);
      final identity4 = Identity(name: '    ', mayDelete: true);
      when(mockGetAllIdentitiesInteractor.execute(any, any, properties: anyNamed('properties')))
        .thenAnswer((_) => Stream.value(Right(GetAllIdentitiesSuccess(
          [identity1, identity2, identity3, identity4],
          null))));
      when(mockManageAccountDashBoardController.ownEmailAddress).thenReturn(Rx(''));
      when(mockManageAccountDashBoardController.accountId).thenReturn(Rxn());
      when(mockManageAccountDashBoardController.sessionCurrent).thenReturn(SessionFixtures.aliceSession);
        
      // act
      identitiesController.onInit();
      mockManageAccountDashBoardController.accountId.value = AccountId(Id('value'));
      await untilCalled(mockGetAllIdentitiesInteractor.execute(any, any, properties: anyNamed('properties')));
      
      // assert
      await expectLater(identitiesController.listAllIdentities, [identity3]);
    });
  });
}