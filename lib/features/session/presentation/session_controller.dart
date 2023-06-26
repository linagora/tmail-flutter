import 'package:core/core.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
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
import 'package:tmail_ui_user/features/session/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_stored_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_stored_session_interactor.dart';
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
  final GetStoredSessionInteractor _getStoredSessionInteractor;

  SessionController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    UpdateAuthenticationAccountInteractor updateAuthenticationAccountInteractor,
    this._getSessionInteractor,
    this._appToast,
    this._dynamicUrlInterceptors,
    this._getStoredSessionInteractor,
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
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetSessionFailure) {
      _handleSessionFailure(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetSessionSuccess) {
      _goToMailboxDashBoard(success.session);
    } else if (success is GetStoredSessionSuccess) {
      _goToMailboxDashBoard(success.session);
    }
  }

  @override
  void handleExceptionAction({Failure? failure, Exception? exception}) {
    super.handleExceptionAction(failure: failure, exception: exception);
    if (PlatformInfo.isMobile && failure is GetSessionFailure && exception is NoNetworkError) {
      _handleGetStoredSession();
    }
  }

  @override
  void handleReloaded(Session session) {
    pushAndPop(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard, NavigationRouter()),
      arguments: session);
  }

  void _getSession() async {
    consumeState(_getSessionInteractor.execute());
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
        if (sessionException.message != null && sessionException.code != null) {
          errorMessage = '[${sessionException.code}] ${sessionException.message}';
        } else if (sessionException.message != null) {
          errorMessage = sessionException.message!;
        } else {
          errorMessage = AppLocalizations.of(currentContext!).unknownError;
        }
      }

      logError('SessionController::_handleSessionFailure():errorMessage: $errorMessage');
      if (errorMessage.isNotEmpty && currentOverlayContext != null) {
        _appToast.showToastErrorMessage(currentOverlayContext!, errorMessage);
      }
    }
  }

  bool _checkUrlError(dynamic sessionException) {
    return sessionException is ConnectError || sessionException is BadGateway || sessionException is SocketError;
  }

  void _goToMailboxDashBoard(Session session) {
    final apiUrl = session.getQualifiedApiUrl(baseUrl: _dynamicUrlInterceptors.jmapUrl);
    log('SessionController::_goToMailboxDashBoard():apiUrl: $apiUrl');
    if (apiUrl.isNotEmpty) {
      _dynamicUrlInterceptors.changeBaseUrl(apiUrl);
      pushAndPop(
        RouteUtils.generateNavigationRoute(AppRoutes.dashboard, NavigationRouter()),
        arguments: session);
    } else {
      logError('SessionController::_goToMailboxDashBoard(): apiUrl is NULL');
      performInvokeLogoutAction();
    }
  }

  void _handleGetStoredSession() {
    log('SessionController::_handleGetStoredSession():');
    consumeState(_getStoredSessionInteractor.execute());
  }
}