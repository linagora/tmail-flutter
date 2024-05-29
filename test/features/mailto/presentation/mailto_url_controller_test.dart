import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/mailto/presentation/mailto_url_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:uuid/uuid.dart';

import '../../email/presentation/controller/single_email_controller_test.mocks.dart';
import '../../mailbox_dashboard/presentation/controller/mailbox_dashboard_controller_test.mocks.dart';

class TestMailtoUrlController extends MailtoUrlController {
  bool goToLoginCalled = false;

  @override
  void goToLogin() {
    goToLoginCalled = true;
    super.goToLogin();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // mock base controller Get dependencies
  final cachingManager = MockCachingManager();
  final languageCacheManager = MockLanguageCacheManager();
  final authorizationInterceptors = MockAuthorizationInterceptors();
  final dynamicUrlInterceptors = MockDynamicUrlInterceptors();
  final deleteCredentialInteractor = MockDeleteCredentialInteractor();
  final logoutOidcInteractor = MockLogoutOidcInteractor();
  final deleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
  final appToast = MockAppToast();
  final imagePaths = MockImagePaths();
  final responsiveUtils = MockResponsiveUtils();
  final uuid = MockUuid();

  // mock reloadable controller Get dependencies
  final getSessionInteractor = MockGetSessionInteractor();
  final getAuthenticatedAccountInteractor = MockGetAuthenticatedAccountInteractor();
  final updateAuthenticationAccountInteractor = MockUpdateAuthenticationAccountInteractor();

  setUp(() {
    Get.put<CachingManager>(cachingManager);
    Get.put<LanguageCacheManager>(languageCacheManager);
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(dynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(deleteCredentialInteractor);
    Get.put<LogoutOidcInteractor>(logoutOidcInteractor);
    Get.put<DeleteAuthorityOidcInteractor>(deleteAuthorityOidcInteractor);
    Get.put<AppToast>(appToast);
    Get.put<ImagePaths>(imagePaths);
    Get.put<ResponsiveUtils>(responsiveUtils);
    Get.put<Uuid>(uuid);
    Get.put<GetSessionInteractor>(getSessionInteractor);
    Get.put<GetAuthenticatedAccountInteractor>(getAuthenticatedAccountInteractor);
    Get.put<UpdateAuthenticationAccountInteractor>(updateAuthenticationAccountInteractor);

    Get.testMode = true;
  });
  
  group('mailto url controller test:', () {
    test(
      'SHOULD log user out '
      'WHEN user logged in with OIDC '
      'AND user change url to send mail '
      'AND the app fails to get user session',
    () async {
      // arrange
      when(getAuthenticatedAccountInteractor.execute(stateChange: anyNamed('stateChange')))
        .thenAnswer((_) => Stream.value(Right(GetStoredTokenOidcSuccess(
          Uri.parse('https://test.com'),
          TokenOIDC('token', TokenId('uuid'), 'refreshToken'),
          OIDCConfiguration(authority: '', clientId: '', scopes: []),
          PersonalAccount(
            'abc123',
            AuthenticationType.basic,
            isSelected: true)))));
      when(getSessionInteractor.execute(stateChange: anyNamed('stateChange')))
        .thenAnswer((_) => Stream.value(Left(GetSessionFailure(Exception()))));
      final mailtoUrlController = TestMailtoUrlController();
      Get.parameters = {'uri': 'https://test.com'};
      
      // act
      mailtoUrlController.onReady();
      await Future.delayed(const Duration(microseconds: 500));
      
      // assert
      expect(mailtoUrlController.goToLoginCalled, true);
    });
  });
}