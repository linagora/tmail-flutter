import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SessionController extends GetxController {
  final GetSessionInteractor _getSessionInteractor;
  final DeleteCredentialInteractor _deleteCredentialInteractor;
  final CachingManager _cachingManager;

  SessionController(
    this._getSessionInteractor,
    this._deleteCredentialInteractor,
    this._cachingManager,
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

  void _deleteCredential() async {
    await _deleteCredentialInteractor.execute();
  }

  void _clearAllCache() async {
    await _cachingManager.clearAll();
  }

  void _goToLogin() {
    _deleteCredential();
    if (!kIsWeb) _clearAllCache();
    pushAndPop(AppRoutes.LOGIN);
  }

  void _goToMailboxDashBoard(GetSessionSuccess getSessionSuccess) {
    pushAndPop(AppRoutes.MAILBOX_DASHBOARD, arguments: getSessionSuccess.session);
  }
}