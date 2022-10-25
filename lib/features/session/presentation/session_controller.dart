import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/domain/exceptions/remote_exception.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SessionController extends ReloadableController {
  final GetSessionInteractor _getSessionInteractor;
  final DeleteCredentialInteractor _deleteCredentialInteractor;
  final CachingManager _cachingManager;
  final DeleteAuthorityOidcInteractor _deleteAuthorityOidcInteractor;
  final AuthorizationInterceptors _authorizationInterceptors;
  final AppToast _appToast;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;

  SessionController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    this._getSessionInteractor,
    this._deleteCredentialInteractor,
    this._cachingManager,
    this._deleteAuthorityOidcInteractor,
    this._authorizationInterceptors,
    this._appToast,
    this._dynamicUrlInterceptors,
  ) : super(logoutOidcInteractor,
      deleteAuthorityOidcInteractor,
      getAuthenticatedAccountInteractor);

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
    pushAndPop(AppRoutes.dashboard, arguments: session);
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
    if (failure is GetSessionFailure) {
      final sessionException = failure.exception;
      if (_checkUrlError(sessionException) && currentContext != null) {
        _appToast.showErrorToast(AppLocalizations.of(currentContext!).wrongUrlMessage);
      } else if (sessionException is UnknownError && currentContext != null) {
        if (sessionException.message != null) {
          _appToast.showErrorToast('[${sessionException.code}] ${sessionException.message}');
        } else {
          _appToast.showErrorToast(AppLocalizations.of(currentContext!).unknown_error_login_message);
        }
      }
    }
  }

  bool _checkUrlError(dynamic sessionException) {
    return sessionException is ConnectError || sessionException is BadGateway;
  }

  void _goToLogin() async {
    await Future.wait([
      _deleteCredentialInteractor.execute(),
      _deleteAuthorityOidcInteractor.execute(),
      _cachingManager.clearAll()
    ]);
    _authorizationInterceptors.clear();
    pushAndPopAll(AppRoutes.login);
  }

  void _goToMailboxDashBoard(GetSessionSuccess success) {
    final apiUrl = success.session.apiUrl.toString();
    if (apiUrl.isNotEmpty) {
      _dynamicUrlInterceptors.changeBaseUrl(apiUrl);
      pushAndPop(AppRoutes.dashboard, arguments: success.session);
    } else {
      _goToLogin();
    }
  }

  @override
  void onDone() {}

  @override
  void onError(error) {}
}