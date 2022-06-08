import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/log_out_oidc_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

abstract class ReloadableController extends BaseController {
  final GetCredentialInteractor _getCredentialInteractor = Get.find<GetCredentialInteractor>();
  final DynamicUrlInterceptors _dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();
  final AuthorizationInterceptors _authorizationInterceptors = Get.find<AuthorizationInterceptors>();
  final GetSessionInteractor _getSessionInteractor = Get.find<GetSessionInteractor>();
  final DeleteCredentialInteractor _deleteCredentialInteractor = Get.find<DeleteCredentialInteractor>();
  final CachingManager _cachingManager = Get.find<CachingManager>();

  final LogoutOidcInteractor _logoutOidcInteractor;
  final DeleteAuthorityOidcInteractor _deleteAuthorityOidcInteractor;

  ReloadableController(
      this._logoutOidcInteractor,
      this._deleteAuthorityOidcInteractor);

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.fold(
      (failure) {
        if (failure is GetCredentialFailure) {
          _goToLogin();
        } else if (failure is GetSessionFailure) {
          _handleGetSessionFailure();
        } else if (failure is LogoutOidcFailure) {
          log('ReloadableController::onData(): LogoutOidcFailure: $failure');
        }
      },
      (success) {
        if (success is GetCredentialViewState) {
          _handleGetCredentialSuccess(success);
        } else if (success is GetSessionSuccess) {
          _handleGetSessionSuccess(success);
        } else if (success is LogoutOidcSuccess) {
          handleLogoutOidcSuccess(success);
        }
      }
    );
  }

  /*
  * trigger reload by getting Credential again then setting up Interceptor and retrieving session
  * */
  void reload() {
    _getCredentialAction();
  }

  void _getCredentialAction() {
    consumeState(_getCredentialInteractor.execute().asStream());
  }

  void _goToLogin({LoginArguments? arguments}) {
    pushAndPopAll(AppRoutes.LOGIN, arguments: arguments);
  }

  void _setUpInterceptors(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    _authorizationInterceptors.setBasicAuthorization(
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
      _cachingManager.clearAll(),
    ]);
    _goToLogin();
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    handleReloaded(success.session);
  }

  void handleReloaded(Session session) {}

  void logoutAction() async {
    final authenticationType = _authorizationInterceptors.authenticationType;
    if (authenticationType == AuthenticationType.oidc) {
      consumeState(_logoutOidcInteractor.execute());
    } else {
      await Future.wait([
        _deleteCredentialInteractor.execute(),
        _cachingManager.clearAll(),
      ]);
      _authorizationInterceptors.clear();
      await HiveCacheConfig().closeHive();
      _goToLogin();
    }
  }

  void handleLogoutOidcSuccess(LogoutOidcSuccess success) async {
    log('ReloadableController::handleLogoutOidcSuccess(): $success');
    await Future.wait([
      _deleteCredentialInteractor.execute(),
      _deleteAuthorityOidcInteractor.execute(),
      _cachingManager.clearAll(),
    ]);
    _authorizationInterceptors.clear();
    await HiveCacheConfig().closeHive();
    _goToLogin(arguments: LoginArguments(LoginFormType.ssoForm));
  }
}