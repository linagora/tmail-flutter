import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class SessionController extends GetxController {
  final GetSessionInteractor _getSessionInteractor;
  final DeleteCredentialInteractor _deleteCredentialInteractor;

  SessionController(this._getSessionInteractor, this._deleteCredentialInteractor);

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

  void _goToLogin() {
    _deleteCredential();
    Get.offNamed(AppRoutes.LOGIN);
  }

  void _goToMailboxDashBoard(GetSessionSuccess getSessionSuccess) {
    Get.offNamed(AppRoutes.MAILBOX_DASHBOARD, arguments: getSessionSuccess.session);
  }
}