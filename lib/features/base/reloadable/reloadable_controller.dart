import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/update_authentication_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_interactors_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';

abstract class ReloadableController extends BaseController {
  final GetSessionInteractor getSessionInteractor = Get.find<GetSessionInteractor>();
  final GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor = Get.find<GetAuthenticatedAccountInteractor>();
  final UpdateAccountCacheInteractor _updateAccountCacheInteractor = Get.find<UpdateAccountCacheInteractor>();

  @override
  void handleFailureViewState(Failure failure) {
    if (isNotSignedIn(failure)) {
      logError('$runtimeType::handleFailureViewState():Failure = $failure');
      goToLogin();
    } else if (failure is GetSessionFailure) {
      logError('$runtimeType::handleFailureViewState():Failure = $failure');
      handleGetSessionFailure(failure);
    } else if (failure is UpdateAccountCacheFailure) {
      logError('$runtimeType::handleFailureViewState():Failure = $failure');
      _handleUpdateAccountCacheCompleted(
        session: failure.session,
        apiUrl: failure.apiUrl);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetCredentialViewState) {
      log('$runtimeType::handleSuccessViewState:Success = ${success.runtimeType}');
      _handleGetCredentialSuccess(success);
    } else if (success is GetStoredTokenOidcSuccess) {
      log('$runtimeType::handleSuccessViewState:Success = ${success.runtimeType}');
      _handleGetStoredTokenOidcSuccess(success);
    } else if (success is GetSessionSuccess) {
      log('$runtimeType::handleSuccessViewState:Success = ${success.runtimeType}');
      updateAccountCache(
        session: success.session,
        baseUrl: dynamicUrlInterceptors.baseUrl);
    } else if (success is UpdateAccountCacheSuccess) {
      log('$runtimeType::handleSuccessViewState:Success = ${success.runtimeType}');
      _handleUpdateAccountCacheCompleted(
        session: success.session,
        apiUrl: success.apiUrl);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  /*
  * trigger reload by getting Credential again then setting up Interceptor and retrieving session
  * */
  void reload() {
    getAuthenticatedAccountAction();
  }

  void getAuthenticatedAccountAction() {
    consumeState(getAuthenticatedAccountInteractor.execute());
  }

  void _handleGetCredentialSuccess(GetCredentialViewState success) {
    setDataToInterceptors(
      baseUrl: success.baseUrl.toString(),
      userName: success.userName,
      password: success.password);
    getSessionAction();
  }

  void _handleGetStoredTokenOidcSuccess(GetStoredTokenOidcSuccess success) {
    setDataToInterceptors(
      baseUrl: success.baseUrl.toString(),
      tokenOIDC: success.tokenOidc,
      oidcConfiguration: success.oidcConfiguration);
    getSessionAction();
  }

  void _handleUpdateAccountCacheCompleted({required Session session, String? apiUrl}) {
    dynamicUrlInterceptors.changeBaseUrl(apiUrl);
    handleReloaded(session);
  }

  void setDataToInterceptors({
    required String baseUrl,
    UserName? userName,
    Password? password,
    TokenOIDC? tokenOIDC,
    OIDCConfiguration? oidcConfiguration
 }) {
    dynamicUrlInterceptors.setJmapUrl(baseUrl);
    dynamicUrlInterceptors.changeBaseUrl(baseUrl);

    if (userName != null && password != null) {
      authorizationInterceptors.setBasicAuthorization(userName, password);
      authorizationIsolateInterceptors.setBasicAuthorization(userName, password);
    }

    if (tokenOIDC != null && oidcConfiguration != null) {
      authorizationInterceptors.setTokenAndAuthorityOidc(newToken: tokenOIDC, newConfig: oidcConfiguration);
      authorizationIsolateInterceptors.setTokenAndAuthorityOidc(newToken: tokenOIDC, newConfig: oidcConfiguration);
    }
  }

  void getSessionAction() {
    consumeState(getSessionInteractor.execute());
  }

  void handleGetSessionFailure(GetSessionFailure failure) {
    if (failure.exception is! BadCredentialsException) {
      toastManager.showMessageFailure(failure);
    }
    clearDataAndGoToLoginPage();
  }

  void handleReloaded(Session session) {}

  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapVacationResponse]);
      VacationInteractorsBindings().dependencies();
    } catch(e) {
      logError('$runtimeType::injectVacationBindings(): exception: $e');
    }
  }

  void updateAccountCache({
    required Session session,
    String? baseUrl
  }) {
    consumeState(_updateAccountCacheInteractor.execute(
      session: session,
      baseUrl: baseUrl
    ));
  }

  bool isNotSignedIn(Failure failure) {
    return failure is GetCredentialFailure ||
      failure is GetStoredTokenOidcFailure ||
      failure is GetAuthenticatedAccountFailure;
  }
}