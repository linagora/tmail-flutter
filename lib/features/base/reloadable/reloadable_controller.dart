import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_capability.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/log_out_oidc_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_interactors_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_subscription_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_fcm_subscription_local.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/destroy_subscription_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_fcm_subscription_local_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

abstract class ReloadableController extends BaseController {
  final DynamicUrlInterceptors _dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();
  final AuthorizationInterceptors _authorizationInterceptors = Get.find<AuthorizationInterceptors>();
  final AuthorizationInterceptors _authorizationIsolateInterceptors = Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag);
  final GetSessionInteractor _getSessionInteractor = Get.find<GetSessionInteractor>();
  final DeleteCredentialInteractor _deleteCredentialInteractor = Get.find<DeleteCredentialInteractor>();
  final CachingManager _cachingManager = Get.find<CachingManager>();
  final _languageCacheManager = Get.find<LanguageCacheManager>();

  final LogoutOidcInteractor _logoutOidcInteractor;
  final DeleteAuthorityOidcInteractor _deleteAuthorityOidcInteractor;
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor;
  final UpdateAuthenticationAccountInteractor _updateAuthenticationAccountInteractor;
  final _fcmReceiver = FcmReceiver.instance;

  GetFCMSubscriptionLocalInteractor? _getSubscriptionLocalInteractor;
  DestroySubscriptionInteractor? _destroySubscriptionInteractor;
  bool _isFcmEnabled = false;

  ReloadableController(
    this._logoutOidcInteractor,
    this._deleteAuthorityOidcInteractor,
    this._getAuthenticatedAccountInteractor,
    this._updateAuthenticationAccountInteractor
  );

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.fold(
      (failure) {
        if (failure is GetCredentialFailure) {
          _goToLogin(arguments: LoginArguments(LoginFormType.credentialForm));
        } else if (failure is GetSessionFailure) {
          _handleGetSessionFailure();
        } else if (failure is LogoutOidcFailure) {
          log('ReloadableController::onData(): LogoutOidcFailure: $failure');
          _getSubscriptionLocalAction();
        } else if (failure is GetStoredTokenOidcFailure) {
          _goToLogin(arguments: LoginArguments(LoginFormType.ssoForm));
        } else if (failure is GetAuthenticatedAccountFailure || failure is NoAuthenticatedAccountFailure) {
          _goToLogin(arguments: LoginArguments(LoginFormType.credentialForm));
        } else if (failure is GetFCMSubscriptionLocalFailure) {
          _checkAuthenticationTypeWhenLogout();
        } else if (failure is DestroySubscriptionFailure) {
          _checkAuthenticationTypeWhenLogout();
        }
      },
      (success) {
        if (success is GetCredentialViewState) {
          _handleGetCredentialSuccess(success);
        } else if (success is GetSessionSuccess) {
          _handleGetSessionSuccess(success);
        } else if (success is LogoutOidcSuccess) {
          log('ReloadableController::handleLogoutOidcSuccess(): $success');
          _getSubscriptionLocalAction();
        } else if (success is GetStoredTokenOidcSuccess) {
          _handleGetStoredTokenOIDCSuccess(success);
        } else if (success is GetFCMSubscriptionLocalSuccess) {
          final subscriptionId = success.fcmSubscription.subscriptionId;
          _destroySubscriptionAction(subscriptionId);
        } else if (success is DestroySubscriptionSuccess) {
          _checkAuthenticationTypeWhenLogout();
        }
      }
    );
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

  void _goToLogin({LoginArguments? arguments}) {
    pushAndPopAll(AppRoutes.login, arguments: arguments);
  }

  void _setUpInterceptors(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    _authorizationInterceptors.setBasicAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
    _authorizationIsolateInterceptors.setBasicAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
  }

  void _handleGetCredentialSuccess(GetCredentialViewState credentialViewState) {
    _setUpInterceptors(credentialViewState);
    _getSessionAction();
  }

  void _getSessionAction() {
    consumeState(_getSessionInteractor.execute().asStream());
  }

  void _handleGetSessionFailure() async {
    await Future.wait([
      _deleteCredentialInteractor.execute(),
      _deleteAuthorityOidcInteractor.execute(),
      _cachingManager.clearAll(),
      _languageCacheManager.removeLanguage(),
    ]);
    final authenticationType = _authorizationInterceptors.authenticationType;
    if (authenticationType == AuthenticationType.oidc) {
      _goToLogin(arguments: LoginArguments(LoginFormType.ssoForm));
    } else {
      _goToLogin(arguments: LoginArguments(LoginFormType.credentialForm));
    }
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    final apiUrl = success.session.apiUrl.toString();
    if (apiUrl.isNotEmpty) {
      _dynamicUrlInterceptors.changeBaseUrl(apiUrl);
      updateAuthenticationAccount(success.session, success.session.accounts.keys.first);
      handleReloaded(success.session);
    } else {
      _handleGetSessionFailure();
    }
  }

  void handleReloaded(Session session) {}

  void logoutAction() async {
    await Future.wait([
      _deleteCredentialInteractor.execute(),
      _cachingManager.clearAll(),
      _languageCacheManager.removeLanguage(),
    ]);
    _authorizationInterceptors.clear();
    _authorizationIsolateInterceptors.clear();
    if (_isFcmEnabled) {
      _fcmReceiver.deleteFcmToken();
    }
    await _cachingManager.closeHive();
    _goToLogin(arguments: LoginArguments(LoginFormType.credentialForm));
  }

  void _logoutOIDCAction() async {
    log('ReloadableController::_logoutOIDCAction():');
    await Future.wait([
      _deleteAuthorityOidcInteractor.execute(),
      _cachingManager.clearAll(),
      _languageCacheManager.removeLanguage(),
    ]);
    _authorizationIsolateInterceptors.clear();
    _authorizationInterceptors.clear();
    if (_isFcmEnabled) {
      _fcmReceiver.deleteFcmToken();
    }
    await _cachingManager.closeHive();
    _goToLogin(arguments: LoginArguments(LoginFormType.ssoForm));
  }

  void _handleGetStoredTokenOIDCSuccess(GetStoredTokenOidcSuccess tokenOidcSuccess) {
    _setUpInterceptorsOidc(tokenOidcSuccess);
    _getSessionAction();
  }

  void _setUpInterceptorsOidc(GetStoredTokenOidcSuccess tokenOidcSuccess) {
    _dynamicUrlInterceptors.changeBaseUrl(tokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: tokenOidcSuccess.tokenOidc.toToken(),
        newConfig: tokenOidcSuccess.oidcConfiguration);
    _authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
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

  Future<void> _getSubscriptionLocalAction() {
    try {
      _getSubscriptionLocalInteractor = Get.find<GetFCMSubscriptionLocalInteractor>();
      consumeState(_getSubscriptionLocalInteractor!.execute());
    } catch (e) {
      logError(
          'ReloadableController::getSubscriptionLocalAction(): exception: $e');
      logoutAction();
    }
    return Future.value();
  }

  void _destroySubscriptionAction(String subscriptionId) {
    try {
      _destroySubscriptionInteractor = Get.find<DestroySubscriptionInteractor>();
      consumeState(_destroySubscriptionInteractor!.execute(subscriptionId));
    } catch(e) {
      logError('ReloadableController::destroySubscriptionAction(): exception: $e');
      logoutAction();
    }
  }

  bool fcmEnabled(Session? session, AccountId? accountId) {
    bool fcmEnabled = false;
    try {
      requireCapability(session!, accountId!, [FirebaseCapability.fcmIdentifier]);
      if (AppConfig.fcmAvailable) {
        fcmEnabled = true;
      } else {
        fcmEnabled = false;
      }
    } catch (e) {
      logError('BaseController::fcmEnabled(): exception: $e');
    }
    return fcmEnabled;
  }

  void logout(Session? session, AccountId? accountId) {
    _isFcmEnabled = fcmEnabled(session, accountId);
    if (_isFcmEnabled) {
      final authenticationType = _authorizationInterceptors.authenticationType;
      if (authenticationType == AuthenticationType.oidc) {
        consumeState(_logoutOidcInteractor.execute());
      } else {
        _getSubscriptionLocalAction();
      }
    } else {
      _checkAuthenticationTypeWhenLogout();
    }
  }

  void _checkAuthenticationTypeWhenLogout() {
    final authenticationType = _authorizationInterceptors.authenticationType;
    if (authenticationType == AuthenticationType.oidc) {
      _logoutOIDCAction();
    } else {
      logoutAction();
    }
  }

  void updateAuthenticationAccount(Session? session, AccountId? accountId) {
    final apiUrl = session?.apiUrl.toString() ?? '';
    log('ReloadableController::updateAuthenticationAccount():apiUrl: $apiUrl');
    if (accountId != null && apiUrl.isNotEmpty) {
      consumeState(_updateAuthenticationAccountInteractor.execute(accountId, apiUrl));
    }
  }
}