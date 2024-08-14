import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/data/network/download/download_client.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/create_public_asset_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/delete_public_assets_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
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
  // Identity creator controller mockspecs
  MockSpec<VerifyNameInteractor>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<IdentityUtils>(),
  MockSpec<DioClient>(),
  MockSpec<Executor>(),
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
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late IdentityCreatorController identityCreatorController;
  late MockVerifyNameInteractor mockVerifyNameInteractor;
  late MockGetAllIdentitiesInteractor mockGetAllIdentitiesInteractor;
  late MockIdentityUtils mockIdentityUtils;
  late MockDeletePublicAssetsInteractor deletePublicAssetsInteractor;

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

    //mock identity creator controller
    mockVerifyNameInteractor = MockVerifyNameInteractor();
    mockGetAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
    mockIdentityUtils = MockIdentityUtils();
    deletePublicAssetsInteractor = MockDeletePublicAssetsInteractor();

    Get.put<DioClient>(MockDioClient(), tag: BindingTag.isolateTag);
    Get.put<Executor>(MockExecutor());
    Get.put<RemoteExceptionThrower>(MockRemoteExceptionThrower());
    Get.put<DownloadClient>(MockDownloadClient());
    Get.put<HtmlAnalyzer>(MockHtmlAnalyzer());
    Get.put<HttpClient>(MockHttpClient());
    Get.put<DeletePublicAssetsInteractor>(deletePublicAssetsInteractor, tag: BindingTag.publicAssetBindingsTag);
    Get.put<UploadAttachmentInteractor>(MockUploadAttachmentInteractor());
    Get.put<CreatePublicAssetInteractor>(MockCreatePublicAssetInteractor());
    Get.put<HtmlDataSourceImpl>(MockHtmlDataSourceImpl(), tag: BindingTag.publicAssetBindingsTag);

    Get.testMode = true;

    identityCreatorController = IdentityCreatorController(
      mockVerifyNameInteractor,
      mockGetAllIdentitiesInteractor,
      mockIdentityUtils);
  });

  group("IdentityCreatorController test:", () {
    test(
      'should call deletePublicAssetsInteractor.execute() '
      'when closeView() is called',
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
  });
}