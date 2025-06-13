
import 'dart:async';
import 'dart:isolate';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/fcm_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_token_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/push_base_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/state_change_extension.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/mailbox_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class FcmMessageController extends PushBaseController {
  GetAuthenticatedAccountInteractor? _getAuthenticatedAccountInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  AuthorizationInterceptors? _authorizationInterceptors;
  GetSessionInteractor? _getSessionInteractor;

  FcmMessageController._internal();

  static final FcmMessageController _instance = FcmMessageController._internal();

  static FcmMessageController get instance => _instance;

  @override
  void initialize({AccountId? accountId, Session? session}) {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::initialize:');
    super.initialize(accountId: accountId, session: session);

    _listenTokenStream();
    _listenBackgroundMessageStream();
  }

  void _listenBackgroundMessageStream() {
    FcmService.instance.backgroundMessageStreamController
      ?.stream
      .debounceTime(const Duration(milliseconds: FcmUtils.durationBackgroundMessageComing))
      .listen(_handleBackgroundMessageAction);
  }

  void _listenTokenStream() {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::_listenTokenStream:');
    FcmService.instance.fcmTokenStreamController
      ?.stream
      .debounceTime(const Duration(milliseconds: FcmUtils.durationRefreshToken))
      .listen(FcmTokenController.instance.onFcmTokenChanged);
  }

  Future<void> _handleBackgroundMessageAction(Map<String, dynamic> payloadData) async {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::_handleBackgroundMessageAction():payloadData: $payloadData');
    final stateChange = FcmUtils.instance.convertFirebaseDataMessageToStateChange(payloadData);
    await _initialAppConfig();
    _getAuthenticatedAccount(stateChange: stateChange);
  }

  Future<void> _initialAppConfig() async {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::_initialAppConfig:');
    await HiveCacheConfig.instance.setUp();
    await Future.sync(MainBindings().dependencies);
    await HiveCacheConfig.instance.initializeEncryptionKey();
    await Future.sync(FcmInteractorBindings().dependencies);
    _getInteractorBindings();
  }

  void _getInteractorBindings() {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::_getInteractorBindings:');
    _getAuthenticatedAccountInteractor = getBinding<GetAuthenticatedAccountInteractor>();
    _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
    _authorizationInterceptors = getBinding<AuthorizationInterceptors>();
    _getSessionInteractor = getBinding<GetSessionInteractor>();

    FcmTokenController.instance.initialBindingInteractor();
  }

  void _getAuthenticatedAccount({StateChange? stateChange}) {
    if (_getAuthenticatedAccountInteractor != null) {
      consumeState(_getAuthenticatedAccountInteractor!.execute(stateChange: stateChange));
    }
  }

  void _handleGetAccountByOidcSuccess(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    _dynamicUrlInterceptors?.setJmapUrl(storedTokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors?.setTokenAndAuthorityOidc(
      newToken: storedTokenOidcSuccess.tokenOidc,
      newConfig: storedTokenOidcSuccess.oidcConfiguration
    );

    final baseUrl = PlatformInfo.isAndroid
        ? storedTokenOidcSuccess.baseUrl.toString()
        : storedTokenOidcSuccess.personalAccount.apiUrl;
    _updateBaseUrlToInterceptor(baseUrl);

    _handleFcmPushAction(
      personalAccount: storedTokenOidcSuccess.personalAccount,
      stateChange: storedTokenOidcSuccess.stateChange,
    );
  }

  void _handleGetAccountByBasicAuthSuccess(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors?.setJmapUrl(credentialViewState.baseUrl.toString());
    _authorizationInterceptors?.setBasicAuthorization(
      credentialViewState.userName,
      credentialViewState.password,
    );

    final baseUrl = PlatformInfo.isAndroid
        ? credentialViewState.baseUrl.toString()
        : credentialViewState.personalAccount.apiUrl;
    _updateBaseUrlToInterceptor(baseUrl);

    _handleFcmPushAction(
      personalAccount: credentialViewState.personalAccount,
      stateChange: credentialViewState.stateChange,
    );
  }

  void _updateBaseUrlToInterceptor(String? baseUrl) {
    _dynamicUrlInterceptors?.changeBaseUrl(baseUrl);
  }

  void _handleFcmPushAction({
    required PersonalAccount personalAccount,
    StateChange? stateChange,
  }) {
    if (PlatformInfo.isAndroid) {
      _getSessionAction(stateChange: stateChange);
    } else {
      final accountId = personalAccount.accountId;
      final username = personalAccount.userName;

      if (accountId == null || username == null || stateChange == null) return;

      _pushActionFromRemoteMessageBackground(
        accountId: accountId,
        userName: username,
        stateChange: stateChange,
      );
    }
  }

  void _getSessionAction({StateChange? stateChange}) {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::_getSessionAction:');
    if (_getSessionInteractor != null) {
      consumeState(_getSessionInteractor!.execute(stateChange: stateChange));
    }
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    try {
      final apiUrl = success.session.getQualifiedApiUrl(baseUrl: _dynamicUrlInterceptors?.jmapUrl);
      final stateChange = success.stateChange;

      if (apiUrl.isNotEmpty && stateChange != null) {
        _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);

        _pushActionFromRemoteMessageBackground(
          accountId: success.session.accountId,
          userName: success.session.username,
          stateChange: stateChange,
          session: success.session);
      }
    } catch (e) {
      logError('FcmMessageController::_handleGetSessionSuccess: Exception $e');
    }
  }

  void _pushActionFromRemoteMessageBackground({
    required AccountId accountId,
    required UserName userName,
    required StateChange stateChange,
    Session? session
  }) {
    final mapTypeState = stateChange.getMapTypeState(accountId);
    log('FcmMessageController::_pushActionFromRemoteMessageBackground:mapTypeState = $mapTypeState');

    mappingTypeStateToAction(
      mapTypeState,
      accountId,
      userName,
      emailChangeListener: EmailChangeListener.instance,
      mailboxChangeListener: MailboxChangeListener.instance,
      isForeground: false,
      session: session);
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('FcmMessageController::_handleFailureViewState(): $failure');
  }

  @override
  void handleSuccessViewState(Success success) {
    log('FcmMessageController::_handleSuccessViewState(): ${success.runtimeType}');
    if (success is GetSessionSuccess) {
      _handleGetSessionSuccess(success);
    } else if (success is GetStoredTokenOidcSuccess) {
      _handleGetAccountByOidcSuccess(success);
    } else if (success is GetCredentialViewState) {
      _handleGetAccountByBasicAuthSuccess(success);
    }
  }
}