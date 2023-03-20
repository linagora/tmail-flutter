import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class SessionController extends ReloadableController {
  final GetSessionInteractor _getSessionInteractor;
  final AppToast _appToast;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;

  SessionController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    UpdateAuthenticationAccountInteractor updateAuthenticationAccountInteractor,
    this._getSessionInteractor,
    this._appToast,
    this._dynamicUrlInterceptors,
  ) : super(
    getAuthenticatedAccountInteractor,
    updateAuthenticationAccountInteractor
  );

  @override
  void onReady() {
    super.onReady();
    final arguments = Get.arguments;
    if (arguments != null && arguments is String) {
      _getSession();
    } else {
      reload();
    }
  }

  @override
  void handleReloaded(Session session) {
    pushAndPop(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard, NavigationRouter()),
      arguments: session);
  }

  void _getSession() async {
    await _getSessionInteractor.execute()
      .then((response) => response.fold(
        (failure) {
          _handleSessionFailure(failure);
          _goToLogin();
        },
        (success) => success is GetSessionSuccess
            ? _goToMailboxDashBoard(success)
            : _goToLogin()));
  }

  void _handleSessionFailure(Failure failure) {
    log('SessionController::_handleSessionFailure(): $failure');
    if (failure is GetSessionFailure) {
      final sessionException = failure.exception;
      var errorMessage = '';
      if (_checkUrlError(sessionException) && currentContext != null) {
        errorMessage = AppLocalizations.of(currentContext!).wrongUrlMessage;
      } else if (sessionException is BadCredentialsException && currentContext != null) {
        errorMessage = AppLocalizations.of(currentContext!).badCredentials;
      } else if (sessionException is UnknownError && currentContext != null) {
        if (sessionException.message != null) {
          errorMessage = '[${sessionException.code}] ${sessionException.message}';
        } else {
          errorMessage = AppLocalizations.of(currentContext!).unknownError;
        }
      }

      logError('SessionController::_handleSessionFailure():errorMessage: $errorMessage');
      if (errorMessage.isNotEmpty && currentOverlayContext != null && currentContext != null) {
        _appToast.showToastErrorMessage(currentOverlayContext!, errorMessage);
      }
    }
  }

  bool _checkUrlError(dynamic sessionException) {
    return sessionException is ConnectError || sessionException is BadGateway;
  }

  void _goToLogin() async {
    await Future.wait([
      deleteCredentialInteractor.execute(),
      deleteAuthorityOidcInteractor.execute(),
      cachingManager.clearAll()
    ]);
    authorizationInterceptors.clear();
    pushAndPopAll(AppRoutes.login);
  }

  void _goToMailboxDashBoard(GetSessionSuccess success) {
    final jmapUrl = _dynamicUrlInterceptors.jmapUrl;
    final apiUrl = jmapUrl != null
      ? success.session.apiUrl.toQualifiedUrl(baseUrl: Uri.parse(jmapUrl)).toString()
      : success.session.apiUrl.toString();
    log('SessionController::_goToMailboxDashBoard():apiUrl: $apiUrl');
    if (apiUrl.isNotEmpty) {
      _dynamicUrlInterceptors.changeBaseUrl(apiUrl);
      pushAndPop(
        RouteUtils.generateNavigationRoute(AppRoutes.dashboard, NavigationRouter()),
        arguments: success.session);
    } else {
      _goToLogin();
    }
  }

  @override
  void onDone() {}
}