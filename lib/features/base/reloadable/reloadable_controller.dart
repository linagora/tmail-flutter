import 'package:core/data/network/config/authorization_interceptors.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
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

  ReloadableController();

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.fold(
      (failure) {
        if (failure is GetCredentialFailure) {
          goToLogin();
        } else if (failure is GetSessionFailure) {
          _handleGetSessionFailure();
        }
      },
      (success) {
        if (success is GetCredentialViewState) {
          _handleGetCredentialSuccess(success);
        } else if (success is GetSessionSuccess) {
          _handleGetSessionSuccess(success);
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

  void goToLogin() {
    pushAndPopAll(AppRoutes.LOGIN);
  }

  void _setUpInterceptors(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    _authorizationInterceptors.changeAuthorization(
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

  void _handleGetSessionFailure() {
    _deleteCredentialAction();
    goToLogin();
  }

  void _deleteCredentialAction() async {
    await _deleteCredentialInteractor.execute();
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    handleReloaded(success.session);
  }

  void handleReloaded(Session session) {}

  void _clearAllCacheAction() async {
    await _cachingManager.clearAll();
  }

  void logoutAction() {
    _deleteCredentialAction();
    _clearAllCacheAction();
    goToLogin();
  }
}