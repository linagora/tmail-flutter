import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/data/network/download/download_client.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:core/utils/file_utils.dart';
import 'package:flutter/widgets.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/save_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/create_public_asset_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/delete_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:worker_manager/worker_manager.dart';

import 'identity_creator_controller_test.mocks.dart';

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
  // Identity creator controller mockspecs
  MockSpec<VerifyNameInteractor>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<IdentityUtils>(),
  MockSpec<DioClient>(),
  MockSpec<Executor>(),
  MockSpec<FileUtils>(),
  MockSpec<FileUploader>(),
  MockSpec<RemoteExceptionThrower>(),
  MockSpec<DownloadClient>(),
  MockSpec<HtmlAnalyzer>(),
  MockSpec<HttpClient>(),
  MockSpec<BuildContext>(),
  MockSpec<BuildOwner>(),
  MockSpec<FocusManager>(),
  MockSpec<DeletePublicAssetsInteractor>(),
  MockSpec<UploadAttachmentInteractor>(),
  MockSpec<CreatePublicAssetInteractor>(),
  MockSpec<HtmlDataSourceImpl>(),
  MockSpec<SaveIdentityCacheOnWebInteractor>(),
  MockSpec<BeforeReconnectManager>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late IdentityCreatorController identityCreatorController;
  late MockVerifyNameInteractor mockVerifyNameInteractor;
  late MockGetAllIdentitiesInteractor mockGetAllIdentitiesInteractor;
  late MockIdentityUtils mockIdentityUtils;
  late MockDeletePublicAssetsInteractor deletePublicAssetsInteractor;
  late MockSaveIdentityCacheOnWebInteractor mockSaveIdentityCacheOnWebInteractor;

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

    //mock identity creator controller
    mockVerifyNameInteractor = MockVerifyNameInteractor();
    mockGetAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
    mockIdentityUtils = MockIdentityUtils();
    deletePublicAssetsInteractor = MockDeletePublicAssetsInteractor();
    mockSaveIdentityCacheOnWebInteractor = MockSaveIdentityCacheOnWebInteractor();

    Get.put<DioClient>(MockDioClient(), tag: BindingTag.isolateTag);
    Get.put<Executor>(MockExecutor());
    Get.put<FileUtils>(MockFileUtils());
    Get.put<FileUploader>(MockFileUploader());
    Get.put<RemoteExceptionThrower>(MockRemoteExceptionThrower());
    Get.put<DownloadClient>(MockDownloadClient());
    Get.put<HtmlAnalyzer>(MockHtmlAnalyzer());
    Get.put<HttpClient>(MockHttpClient());
    Get.put<DeletePublicAssetsInteractor>(deletePublicAssetsInteractor, tag: BindingTag.publicAssetBindingsTag);
    Get.put<UploadAttachmentInteractor>(MockUploadAttachmentInteractor());
    Get.put<CreatePublicAssetInteractor>(MockCreatePublicAssetInteractor());
    Get.put<HtmlDataSourceImpl>(MockHtmlDataSourceImpl(), tag: BindingTag.publicAssetBindingsTag);
    Get.put<BeforeReconnectManager>(MockBeforeReconnectManager());

    Get.testMode = true;

    identityCreatorController = IdentityCreatorController(
      mockVerifyNameInteractor,
      mockGetAllIdentitiesInteractor,
      mockSaveIdentityCacheOnWebInteractor,
      mockIdentityUtils);
  });

  group("IdentityCreatorController test:", () {
    final accountId = AccountId(Id('value'));
    final account = Account(
      AccountName('value'),
      true,
      true,
      {CapabilityIdentifier.jmapPublicAsset: DefaultCapability({})});
    final session = Session(
      {},
      {accountId: account},
      {}, UserName('value'), Uri(), Uri(), Uri(), Uri(), State('value'));

    test(
      'should call deletePublicAssetsInteractor.execute() '
      'when closeView() is called '
      'and user has picked at lease one image',
    () {
      // arrange
      final accountId = AccountId(Id('value'));
      final account = Account(
        AccountName('value'),
        true,
        true,
        {CapabilityIdentifier.jmapPublicAsset: DefaultCapability({})});
      final session = Session(
        {}, 
        {accountId: account},
        {}, UserName('value'), Uri(), Uri(), Uri(), Uri(), State('value'));
      identityCreatorController.arguments = IdentityCreatorArguments(accountId, session);

      // act
      identityCreatorController.onReady();
      expect(identityCreatorController.publicAssetController, isNotNull);
      identityCreatorController.publicAssetController?.newlyPickedPublicAssetIds.add(Id('value'));
      
      final context = MockBuildContext();
      final buildOwner = MockBuildOwner();
      final focusManager = MockFocusManager();
      when(context.owner).thenReturn(buildOwner);
      when(buildOwner.focusManager).thenReturn(focusManager);
      when(focusManager.rootScope).thenReturn(FocusScopeNode());
      identityCreatorController.closeView(context);
      
      // assert
      verify(deletePublicAssetsInteractor.execute(
        session,
        accountId,
        publicAssetIds: anyNamed('publicAssetIds'),
      )).called(1);
    });

    test(
      'should not call deletePublicAssetsInteractor.execute() '
      'when closeView() is called '
      'and user has not picked any image',
    () {
      // arrange
      identityCreatorController.arguments = IdentityCreatorArguments(accountId, session);

      // act
      identityCreatorController.onReady();
      expect(identityCreatorController.publicAssetController, isNotNull);
      
      final context = MockBuildContext();
      final buildOwner = MockBuildOwner();
      final focusManager = MockFocusManager();
      when(context.owner).thenReturn(buildOwner);
      when(buildOwner.focusManager).thenReturn(focusManager);
      when(focusManager.rootScope).thenReturn(FocusScopeNode());
      identityCreatorController.closeView(context);
      
      // assert
      verifyNever(deletePublicAssetsInteractor.execute(
        session,
        accountId,
        publicAssetIds: anyNamed('publicAssetIds'),
      ));
    });

    test(
      'should call saveIdentityCacheOnWebInteractor.execute() '
      'when screen is reloaded',
    () async {
      // arrange
      PlatformInfo.isTestingForWeb = true;
      const htmlContent = '<p>test</p>';
      const identityName = 'test';
      identityCreatorController.arguments = IdentityCreatorArguments(accountId, session);
      when(mockVerifyNameInteractor.execute(any, any)).thenAnswer((_) => Right(VerifyNameViewState()));

      // act
      identityCreatorController.onReady();
      expect(identityCreatorController.publicAssetController, isNotNull);

      final context = MockBuildContext();
      identityCreatorController.updateNameIdentity(context, identityName);
      identityCreatorController.updateContentHtmlEditor(htmlContent);

      identityCreatorController.onUnloadBrowserListener(Event(''));
      await untilCalled(mockSaveIdentityCacheOnWebInteractor.execute(
        any,
        any,
        identityCache: anyNamed('identityCache'),
      ));

      // assert
      verify(mockSaveIdentityCacheOnWebInteractor.execute(
        accountId,
        session.username,
        identityCache: IdentityCache(
          identity: Identity(
            name: identityName,
            bcc: {},
            replyTo: {},
            htmlSignature: Signature(htmlContent)
          ),
          identityActionType: IdentityActionType.create,
          isDefault: false,
          publicAssetsInIdentityArguments: PublicAssetsInIdentityArguments(
            htmlSignature: htmlContent,
            preExistingPublicAssetIds: [],
            newlyPickedPublicAssetIds: []
          )
        ),
      )).called(1);

      PlatformInfo.isTestingForWeb = false;
    });

    test(
      'should call saveIdentityCacheOnWebInteractor.execute() '
      'when session expires',
    () async {
      // arrange
      PlatformInfo.isTestingForWeb = true;
      const htmlContent = '<p>test</p>';
      const identityName = 'test';
      identityCreatorController.arguments = IdentityCreatorArguments(accountId, session);
      when(mockVerifyNameInteractor.execute(any, any)).thenAnswer((_) => Right(VerifyNameViewState()));

      // act
      identityCreatorController.onReady();
      expect(identityCreatorController.publicAssetController, isNotNull);

      final context = MockBuildContext();
      identityCreatorController.updateNameIdentity(context, identityName);
      identityCreatorController.updateContentHtmlEditor(htmlContent);

      identityCreatorController.onBeforeReconnect();
      await untilCalled(mockSaveIdentityCacheOnWebInteractor.execute(
        any,
        any,
        identityCache: anyNamed('identityCache'),
      ));

      // assert
      verify(mockSaveIdentityCacheOnWebInteractor.execute(
        accountId,
        session.username,
        identityCache: IdentityCache(
          identity: Identity(
            name: identityName,
            bcc: {},
            replyTo: {},
            htmlSignature: Signature(htmlContent)
          ),
          identityActionType: IdentityActionType.create,
          isDefault: false,
          publicAssetsInIdentityArguments: PublicAssetsInIdentityArguments(
            htmlSignature: htmlContent,
            preExistingPublicAssetIds: [],
            newlyPickedPublicAssetIds: []
          )
        ),
      )).called(1);

      PlatformInfo.isTestingForWeb = false;
    });
  });
}