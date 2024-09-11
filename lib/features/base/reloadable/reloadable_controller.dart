import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_interactors_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/message_toast_utils.dart';

abstract class ReloadableController extends BaseController {
  final GetSessionInteractor _getSessionInteractor = Get.find<GetSessionInteractor>();
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor = Get.find<GetAuthenticatedAccountInteractor>();
  final UpdateAuthenticationAccountInteractor _updateAuthenticationAccountInteractor = Get.find<UpdateAuthenticationAccountInteractor>();

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetCredentialFailure ||
        failure is GetStoredTokenOidcFailure ||
        failure is GetAuthenticatedAccountFailure) {
      log('ReloadableController::handleFailureViewState(): failure: $failure');
      goToLogin();
    } else if (failure is GetSessionFailure) {
      _handleGetSessionFailure(failure.exception);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetCredentialViewState) {
      _handleGetCredentialSuccess(success);
    } else if (success is GetSessionSuccess) {
      _handleGetSessionSuccess(success);
    } else if (success is GetStoredTokenOidcSuccess) {
      _handleGetStoredTokenOIDCSuccess(success);
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
    consumeState(_getAuthenticatedAccountInteractor.execute());
  }

  void _setUpInterceptors(GetCredentialViewState credentialViewState) {
    dynamicUrlInterceptors.setJmapUrl(credentialViewState.baseUrl.origin);
    dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    authorizationInterceptors.setBasicAuthorization(
      credentialViewState.userName,
      credentialViewState.password,
    );
    authorizationIsolateInterceptors.setBasicAuthorization(
      credentialViewState.userName,
      credentialViewState.password,
    );
  }

  void _handleGetCredentialSuccess(GetCredentialViewState credentialViewState) {
    _setUpInterceptors(credentialViewState);
    getSessionAction();
  }

  void getSessionAction() {
    consumeState(_getSessionInteractor.execute());
  }

  void _handleGetSessionFailure(dynamic exception) {
    if (currentContext != null && currentOverlayContext != null && exception is! BadCredentialsException) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        MessageToastUtils.getMessageByException(currentContext!, exception) ?? AppLocalizations.of(currentContext!).unknownError
      );
    }
    clearDataAndGoToLoginPage();
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    final session = success.session;
    final personalAccount = session.personalAccount;
    final apiUrl = session.getQualifiedApiUrl(baseUrl: dynamicUrlInterceptors.jmapUrl);
    if (apiUrl.isNotEmpty) {
      dynamicUrlInterceptors.changeBaseUrl(apiUrl);
      updateAuthenticationAccount(session, personalAccount.accountId, session.username);
      handleReloaded(session);
    } else {
      clearDataAndGoToLoginPage();
    }
  }

  void handleReloaded(Session session) {}

  void _handleGetStoredTokenOIDCSuccess(GetStoredTokenOidcSuccess tokenOidcSuccess) {
    _setUpInterceptorsOidc(tokenOidcSuccess);
    getSessionAction();
  }

  void _setUpInterceptorsOidc(GetStoredTokenOidcSuccess tokenOidcSuccess) {
    dynamicUrlInterceptors.setJmapUrl(tokenOidcSuccess.baseUrl.toString());
    dynamicUrlInterceptors.changeBaseUrl(tokenOidcSuccess.baseUrl.toString());
    authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: tokenOidcSuccess.tokenOidc,
        newConfig: tokenOidcSuccess.oidcConfiguration);
    authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
        newToken: tokenOidcSuccess.tokenOidc,
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
    final apiUrl = session.getQualifiedApiUrl(baseUrl: dynamicUrlInterceptors.jmapUrl);
    if (apiUrl.isNotEmpty) {
      consumeState(_updateAuthenticationAccountInteractor.execute(accountId, apiUrl, userName));
    }
  }
}
