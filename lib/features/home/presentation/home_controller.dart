import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class HomeController extends GetxController {
  final GetCredentialInteractor _getCredentialInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final AuthorizationInterceptors _authorizationInterceptors;

  HomeController(this._getCredentialInteractor, this._dynamicUrlInterceptors, this._authorizationInterceptors);

  @override
  void onReady() {
    super.onReady();
    _initFlutterDownloader();
    _getCredentialAction();
  }

  void _initFlutterDownloader() {
    FlutterDownloader
      .initialize(debug: kDebugMode)
      .then((_) => FlutterDownloader.registerCallback(downloadCallback));
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {}

  void _getCredentialAction() async {
    await _getCredentialInteractor.execute()
      .then((response) => response.fold(
        (failure) => _goToLogin(),
        (success) => success is GetCredentialViewState ? _goToMailbox(success) : _goToLogin()));
  }

  void _goToLogin() {
    Get.offNamed(AppRoutes.LOGIN);
  }

  void _goToMailbox(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    _authorizationInterceptors.changeAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
    Get.offNamed(AppRoutes.SESSION);
  }
}