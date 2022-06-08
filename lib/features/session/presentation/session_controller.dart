import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SessionController extends GetxController {
  final GetSessionInteractor _getSessionInteractor;
  final DeleteCredentialInteractor _deleteCredentialInteractor;
  final CachingManager _cachingManager;
  final DeleteAuthorityOidcInteractor _deleteAuthorityOidcInteractor;
  final AuthorizationInterceptors _authorizationInterceptors;

  SessionController(
    this._getSessionInteractor,
    this._deleteCredentialInteractor,
    this._cachingManager,
    this._deleteAuthorityOidcInteractor,
    this._authorizationInterceptors,
  );

  @override
  void onReady() {
    super.onReady();
    _getSession();
  }

  void _getSession() async {
    await _getSessionInteractor.execute()
      .then((response) => response.fold(
        (failure) => _goToLogin(),
        (success) => success is GetSessionSuccess ? _goToMailboxDashBoard(success) : _goToLogin()));
  }

  void _goToLogin() async {
    await Future.wait([
      _deleteCredentialInteractor.execute(),
      _deleteAuthorityOidcInteractor.execute(),
      _cachingManager.clearAll()
    ]);
    _authorizationInterceptors.clear();
    pushAndPopAll(AppRoutes.LOGIN);
  }

  void _goToMailboxDashBoard(GetSessionSuccess getSessionSuccess) {
    pushAndPop(AppRoutes.MAILBOX_DASHBOARD, arguments: getSessionSuccess.session);
  }
}