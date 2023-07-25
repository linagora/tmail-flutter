import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_interactors_bindings.dart';
import 'package:tmail_ui_user/features/session/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

abstract class ReloadableController extends BaseController {
  final DynamicUrlInterceptors _dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();
  final GetSessionInteractor _getSessionInteractor = Get.find<GetSessionInteractor>();
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor;
  final UpdateAuthenticationAccountInteractor _updateAuthenticationAccountInteractor;

  ReloadableController(
    this._getAuthenticatedAccountInteractor,
    this._updateAuthenticationAccountInteractor
  );

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetCredentialFailure) {
      goToLogin(arguments: LoginArguments(LoginFormType.credentialForm));
    } else if (failure is GetSessionFailure) {
      _handleGetSessionFailure();
    } else if (failure is GetStoredTokenOidcFailure) {
      goToLogin(arguments: LoginArguments(LoginFormType.ssoForm));
    } else if (failure is GetAuthenticatedAccountFailure || failure is NoAuthenticatedAccountFailure) {
      goToLogin(arguments: LoginArguments(LoginFormType.credentialForm));
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetCredentialViewState) {
      _handleGetCredentialSuccess(success);
    } else if (success is GetSessionSuccess) {
      _handleGetSessionSuccess(success);
    } else if (success is GetStoredTokenOidcSuccess) {
      _handleGetStoredTokenOIDCSuccess(success);
    }
  }

  /*
  * trigger reload by getting Credential again then setting up Interceptor and retrieving session
  * */
  void reload() {
    getAuthenticatedAccountAction();
  }

  void getAuthenticatedAccountAction() {
    consumeState(_getAuthenticatedAccountInteractor.execute());
  }

  void _setUpInterceptors(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.setJmapUrl(credentialViewState.baseUrl.origin);
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    authorizationInterceptors.setBasicAuthorization(
      credentialViewState.userName.value,
      credentialViewState.password.value,
    );
    authorizationIsolateInterceptors.setBasicAuthorization(
      credentialViewState.userName.value,
      credentialViewState.password.value,
    );
  }

  void _handleGetCredentialSuccess(GetCredentialViewState credentialViewState) {
    _setUpInterceptors(credentialViewState);
    _getSessionAction();
  }

  void _getSessionAction() {
    consumeState(_getSessionInteractor.execute());
  }

  void _handleGetSessionFailure() {
    performInvokeLogoutAction();
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    final session = success.session;
    final personalAccount = session.personalAccount;
    final apiUrl = session.getQualifiedApiUrl(baseUrl: _dynamicUrlInterceptors.jmapUrl);
    log('ReloadableController::_handleGetSessionSuccess():apiUrl: $apiUrl');
    if (apiUrl.isNotEmpty) {
      _dynamicUrlInterceptors.changeBaseUrl(apiUrl);
      updateAuthenticationAccount(session, personalAccount.accountId, session.username);
      handleReloaded(session);
    } else {
      logError('ReloadableController::_handleGetSessionSuccess(): apiUrl is NULL');
      performInvokeLogoutAction();
    }
  }

  void handleReloaded(Session session) {}

  void _handleGetStoredTokenOIDCSuccess(GetStoredTokenOidcSuccess tokenOidcSuccess) {
    _setUpInterceptorsOidc(tokenOidcSuccess);
    _getSessionAction();
  }

  void _setUpInterceptorsOidc(GetStoredTokenOidcSuccess tokenOidcSuccess) {
    _dynamicUrlInterceptors.setJmapUrl(tokenOidcSuccess.baseUrl.toString());
    _dynamicUrlInterceptors.changeBaseUrl(tokenOidcSuccess.baseUrl.toString());
    authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: tokenOidcSuccess.tokenOidc.toToken(),
        newConfig: tokenOidcSuccess.oidcConfiguration);
    authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
        newToken: tokenOidcSuccess.tokenOidc.toToken(),
        newConfig: tokenOidcSuccess.oidcConfiguration);
  }

  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapVacationResponse]);
      VacationInteractorsBindings().dependencies();
    } catch(e) {
      logError('ReloadableController::injectVacationBindings(): exception: $e');
    }
  }

  void updateAuthenticationAccount(Session session, AccountId accountId, UserName userName) {
    final apiUrl = session.getQualifiedApiUrl(baseUrl: _dynamicUrlInterceptors.jmapUrl);
    log('ReloadableController::updateAuthenticationAccount():apiUrl: $apiUrl');
    if (apiUrl.isNotEmpty) {
      consumeState(_updateAuthenticationAccountInteractor.execute(accountId, apiUrl, userName));
    }
  }
}