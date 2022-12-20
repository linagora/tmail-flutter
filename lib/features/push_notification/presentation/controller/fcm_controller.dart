import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/fcm_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/fcm_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_token_handler.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/state_change_extension.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/mailbox_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/bindings/core/core_bindings.dart';
import 'package:tmail_ui_user/main/bindings/credential/credential_bindings.dart';
import 'package:tmail_ui_user/main/bindings/local/local_bindings.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/bindings/network/network_bindings.dart';
import 'package:tmail_ui_user/main/bindings/network_connection/network_connection_bindings.dart';
import 'package:tmail_ui_user/main/bindings/session/session_bindings.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class FcmController extends BaseController {

  AccountId? _currentAccountId;
  RemoteMessage? _remoteMessageBackground;

  GetAuthenticatedAccountInteractor? _getAuthenticatedAccountInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  AuthorizationInterceptors? _authorizationInterceptors;
  GetSessionInteractor? _getSessionInteractor;

  FcmController._internal() {
    _listenFcmMessageStream();
  }

  static final FcmController _instance = FcmController._internal();

  static FcmController get instance => _instance;

  void initialize({AccountId? accountId}) {
    _currentAccountId = accountId;
    FcmTokenHandler.instance.initialize();
  }

  void _listenFcmMessageStream() {
    log('FcmController::_listenFcmMessageStream():');
    FcmService.instance.foregroundMessageStream
        .throttleTime(
        const Duration(milliseconds: FcmService.durationMessageComing))
        .listen(_handleForegroundMessageAction);

    FcmService.instance.backgroundMessageStream
        .throttleTime(
        const Duration(milliseconds: FcmService.durationMessageComing))
        .listen(_handleBackgroundMessageAction);

    FcmService.instance.fcmTokenStream.listen(FcmTokenHandler.instance.handle);
  }

  void _handleForegroundMessageAction(RemoteMessage newRemoteMessage) {
    log(
        'FcmController::_handleForegroundMessageAction():remoteMessage: ${newRemoteMessage
            .data}');
    if (_currentAccountId != null) {
      final stateChange = _convertRemoteMessageToStateChange(newRemoteMessage);
      final mapTypeState = stateChange.getMapTypeState(_currentAccountId!);
      _mappingTypeStateToAction(mapTypeState, _currentAccountId!);
    }
  }

  void _handleBackgroundMessageAction(RemoteMessage newRemoteMessage) async {
    log(
        'FcmController::_handleBackgroundMessageAction():remoteMessage: ${newRemoteMessage
            .data}');
    _remoteMessageBackground = newRemoteMessage;
    await _initialAppConfig();
    _getAuthenticatedAccount();
  }

  StateChange? _convertRemoteMessageToStateChange(
      RemoteMessage newRemoteMessage) {
    return FcmUtils.instance.convertFirebaseDataMessageToStateChange(
        newRemoteMessage.data);
  }

  void _mappingTypeStateToAction(Map<String, dynamic> mapTypeState,
      AccountId accountId, {
        bool isForeground = true,
      }) {
    log(
        'FcmController::_mappingTypeStateToAction():mapTypeState: $mapTypeState');
    final listTypeName = mapTypeState.keys
        .map((value) => TypeName(value))
        .toList();

    final listEmailActions = listTypeName
        .where((typeName) =>
    typeName == TypeName.emailType || typeName == TypeName.emailDelivery)
        .map((typeName) =>
        toFcmAction(typeName, accountId, mapTypeState, isForeground))
        .whereNotNull()
        .toList();

    log(
        'FcmController::_mappingTypeStateToAction():listEmailActions: $listEmailActions');

    if (listEmailActions.isNotEmpty) {
      EmailChangeListener.instance.dispatchActions(listEmailActions);
    }

    final listMailboxActions = listTypeName
        .where((typeName) => typeName == TypeName.mailboxType)
        .map((typeName) =>
        toFcmAction(typeName, accountId, mapTypeState, isForeground))
        .whereNotNull()
        .toList();

    log(
        'FcmController::_mappingTypeStateToAction():listMailboxActions: $listEmailActions');

    if (listMailboxActions.isNotEmpty) {
      MailboxChangeListener.instance.dispatchActions(listMailboxActions);
    }
  }

  FcmAction? toFcmAction(TypeName typeName,
      AccountId accountId,
      Map<String, dynamic> mapTypeState,
      isForeground) {
    final newState = jmap.State(mapTypeState[typeName.value]);
    if (typeName == TypeName.emailType) {
      if (isForeground) {
        return SynchronizeEmailOnForegroundAction(
            typeName, newState, accountId);
      } else {
        return StoreEmailStateToRefreshAction(typeName, newState, accountId);
      }
    } else if (typeName == TypeName.emailDelivery) {
      if (!isForeground) {
        return PushNotificationAction(typeName, newState, accountId);
      }
    } else if (typeName == TypeName.mailboxType) {
      if (isForeground) {
        return SynchronizeMailboxOnForegroundAction(
            typeName, newState, accountId);
      } else {
        return StoreMailboxStateToRefreshAction(typeName, newState, accountId);
      }
    }
    return null;
  }

  Future<void> _initialAppConfig() async {
    await CoreBindings().dependencies();
    LocalBindings().dependencies();
    NetworkBindings().dependencies();
    CredentialBindings().dependencies();
    NetWorkConnectionBindings().dependencies();
    SessionBindings().dependencies();
    await HiveCacheConfig().setUp();

    await Future.sync(() {
      HomeBindings().dependencies();
      MailboxDashBoardBindings().dependencies();
      FcmInteractorBindings().dependencies();
    });

    return await _getInteractorBindings();
  }

  Future<void> _getInteractorBindings() {
    try {
      _getAuthenticatedAccountInteractor =
          getBinding<GetAuthenticatedAccountInteractor>();
      _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
      _authorizationInterceptors = getBinding<AuthorizationInterceptors>();
      _getSessionInteractor = getBinding<GetSessionInteractor>();
      FcmTokenHandler.instance.initialize();
    } catch (e) {
      logError('FcmController::_getBindings(): ${e.toString()}');
    }
    return Future.value(null);
  }

  void _getAuthenticatedAccount() {
    if (_getAuthenticatedAccountInteractor != null) {
      consumeState(_getAuthenticatedAccountInteractor!.execute());
    } else {
      _clearRemoteMessageBackground();
      logError(
          'FcmController::_getAuthenticatedAccount():_getAuthenticatedAccountInteractor is null');
    }
  }

  void _handleFailureViewState(Failure failure) {
    log('FcmController::_handleFailureViewState(): $failure');
    _clearRemoteMessageBackground();
  }

  void _handleSuccessViewState(Success success) {
    log('FcmController::_handleSuccessViewState(): $success');
    if (success is GetStoredTokenOidcSuccess) {
      _getSessionWithTokenOidc(success);
    } else if (success is GetCredentialViewState) {
      _getSessionWithBasicAuth(success);
    } else if (success is GetSessionSuccess) {
      _handleGetSessionSuccess(success);
    }
  }

  void _getSessionWithTokenOidc(
      GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    _dynamicUrlInterceptors?.changeBaseUrl(
        storedTokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors?.setTokenAndAuthorityOidc(
        newToken: storedTokenOidcSuccess.tokenOidc.toToken(),
        newConfig: storedTokenOidcSuccess.oidcConfiguration
    );
    _getSession();
  }

  void _getSessionWithBasicAuth(GetCredentialViewState credentialViewState) {
    log('FcmController::_getSessionWithBasicAuth(): _getSessionWithBasicAuth test');
    _dynamicUrlInterceptors?.changeBaseUrl(credentialViewState.baseUrl.origin);
    _authorizationInterceptors?.setBasicAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
    _getSession();
  }

  void _getSession() {
    log('FcmController::_getSession(): _getSession test');
    if (_getSessionInteractor != null) {
      consumeState(_getSessionInteractor!.execute().asStream());
    } else {
      _clearRemoteMessageBackground();
      logError('FcmController::_getSession(): _getSessionInteractor is null');
    }
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    final sessionCurrent = success.session;
    final apiUrl = sessionCurrent.apiUrl.toString();
    _currentAccountId = sessionCurrent.accounts.keys.first;

    _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);

    if (_remoteMessageBackground != null && _currentAccountId != null) {
      final stateChange = _convertRemoteMessageToStateChange(
          _remoteMessageBackground!);
      final mapTypeState = stateChange.getMapTypeState(_currentAccountId!);
      _mappingTypeStateToAction(
          mapTypeState, _currentAccountId!, isForeground: false);
    }
    _clearRemoteMessageBackground();
  }

  void _clearRemoteMessageBackground() {
    _remoteMessageBackground = null;
  }

  @override
  void dispose() {
    _clearRemoteMessageBackground();
    FcmService.instance.dispose();
    super.dispose();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.fold(_handleFailureViewState, _handleSuccessViewState);
  }

  @override
  void onDone() {}
}