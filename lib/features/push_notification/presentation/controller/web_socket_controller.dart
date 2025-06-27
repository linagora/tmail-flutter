import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/web_socket_echo_request.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/web_socket_push_enable_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/web_socket_push_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/connect_web_socket_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/push_base_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/state_change_extension.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/mailbox_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController extends PushBaseController {
  WebSocketController._internal();

  static final WebSocketController _instance = WebSocketController._internal();

  static WebSocketController get instance => _instance;

  ConnectWebSocketInteractor? _connectWebSocketInteractor;
  NetworkConnectionController? _networkConnectionController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  int _retryRemained = 3;
  bool _isConnecting = false;
  WebSocketChannel? _webSocketChannel;
  Timer? _webSocketPingTimer;
  StreamSubscription? _webSocketSubscription;
  AppLifecycleListener? _appLifecycleListener;
  Debouncer<StateChange?>? _stateChangeDebouncer;

  @override
  void handleFailureViewState(Failure failure) {
    logError('WebSocketController::handleFailureViewState():Failure $failure');
    if (failure is WebSocketConnectionFailed) {
      _handleWebSocketConnectionRetry();
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    log('WebSocketController::handleSuccessViewState():Success $success');
    if (success is WebSocketConnectionSuccess) {
      _handleWebSocketConnectionSuccess(success);
    }
  }

  @override
  void handleErrorViewState(Object error, StackTrace stackTrace) {
    super.handleErrorViewState(error, stackTrace);
    handleFailureViewState(WebSocketConnectionFailed());
  }

  @override
  void initialize({AccountId? accountId, Session? session}) {
    log('WebSocketController::initialize:AccountId = ${accountId?.asString}');
    super.initialize(accountId: accountId, session: session);

    _connectWebSocket();
    _listenToAppLifeCycle();
    if (PlatformInfo.isWeb) {
      _monitorNetwork();
    }
  }

  @override
  void onClose() {
    _cleanUpWebSocketResources();
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _appLifecycleListener?.dispose();
    _appLifecycleListener = null;
    super.onClose();
  }

  void _listenToAppLifeCycle() {
    _appLifecycleListener ??= AppLifecycleListener(
      onStateChange: _handleAppLifecycleStateChange,
    );
  }

  void _handleAppLifecycleStateChange(AppLifecycleState appLifecycleState) async {
    log('WebSocketController::_handleAppLifecycleStateChange:appLifecycleState = $appLifecycleState');
    switch (appLifecycleState) {
      case AppLifecycleState.resumed:
        if (PlatformInfo.isMobile) {
          _connectWebSocket();
        } else if (PlatformInfo.isWeb) {
          final isConnected = await _isWebSocketConnected();
          log('WebSocketController::_handleAppLifecycleStateChange:isWebSocketConnected = $isConnected');
          if (!isConnected) {
            _connectWebSocket();
          }
        }
        break;
      default:
        if (PlatformInfo.isMobile) {
          _cleanUpWebSocketResources();
        }
        break;
    }
  }

  Future<bool> _isWebSocketConnected() async {
    try {
      if (_webSocketChannel == null) return false;

      await _webSocketChannel!.ready;
      log('WebSocketController::_isWebSocketConnected:webSocketChannel ready');
      return true;
    } on SocketException catch (e) {
      logError('WebSocketController::_isWebSocketConnected:SocketException = $e');
    } on WebSocketChannelException catch (e) {
      logError('WebSocketController::_isWebSocketConnected:WebSocketChannelException = $e');
    } catch (e) {
      logError('WebSocketController::_isWebSocketConnected:Exception = $e');
    }
    return false;
  }

  void _connectWebSocket() {
    _connectWebSocketInteractor = getBinding<ConnectWebSocketInteractor>();
    if (_connectWebSocketInteractor == null || accountId == null || session == null) {
      logError('WebSocketController::_connectWebSocket: Skipping');
      return;
    }
    if (_isConnecting) return;

    _isConnecting = true;
    log('WebSocketController::_connectWebSocket: Connecting');
    consumeState(_connectWebSocketInteractor!.execute(session!, accountId!));
  }

  void _cleanUpWebSocketResources() {
    log('WebSocketController::_cleanUpWebSocketResources:');
    _isConnecting = false;
    _webSocketSubscription?.cancel();
    _webSocketChannel?.sink.close();
    _webSocketChannel = null;
    _webSocketPingTimer?.cancel();
    _stateChangeDebouncer?.cancel();
  }

  void _handleWebSocketConnectionSuccess(WebSocketConnectionSuccess success) {
    log('WebSocketController::_handleWebSocketConnectionSuccess(): $success');
    _cleanUpWebSocketResources();
    _retryRemained = 3;
    _webSocketChannel = success.webSocketChannel;
    _enableWebSocketPush();
    if (AppConfig.isWebSocketEchoPingEnabled) {
      _pingWebSocket();
    }
    _listenToWebSocket();
    _initStateChangeDeouncerTimer();
  }

  void _handleWebSocketConnectionRetry() {
    log('WebSocketController::_handleWebSocketConnectionRetry:_retryRemained = $_retryRemained');
    _cleanUpWebSocketResources();
    if (_retryRemained > 0) {
      _retryRemained--;
      _connectWebSocket();
    }
  }

  void _enableWebSocketPush() {
    log('WebSocketController::_enableWebSocketPush:');
    _webSocketChannel?.sink.add(jsonEncode(WebSocketPushEnableRequest.toJson(
      dataTypes: [TypeName.emailType, TypeName.mailboxType]
    )));
  }

  void _pingWebSocket() {
    log('WebSocketController::_pingWebSocket:');
    _webSocketPingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      log('WebSocketController::_pingWebSocket: Processing');
      _webSocketChannel?.sink.add(jsonEncode(WebSocketEchoRequest().toJson()));
    });
  }

  void _listenToWebSocket() {
    log('WebSocketController::_listenToWebSocket:');
    _webSocketSubscription = _webSocketChannel?.stream.listen(
      (data) {
        log('WebSocketController::_listenToWebSocket(): $data');
        if (session == null || accountId == null) return;
        if (data is String) {
          data = jsonDecode(data);
        }

        try {
          final stateChange = StateChange.fromJson(data);
          _stateChangeDebouncer?.value = stateChange;
        } catch (e) {
          logError('WebSocketController::_listenToWebSocket(): Data is not StateChange');
        }
      },
      cancelOnError: true,
      onError: (error) {
        logError('WebSocketController::_listenToWebSocket():Error: $error');
        handleFailureViewState(WebSocketConnectionFailed(exception: error));
      },
      onDone: () {
        log('WebSocketController::_listenToWebSocket():onDone');
        _handleWebSocketConnectionRetry();
      },
    );
  }

  void _initStateChangeDeouncerTimer() {
    log('WebSocketController::_initStateChangeDeouncerTimer:');
    _stateChangeDebouncer = Debouncer<StateChange?>(
      const Duration(milliseconds: FcmUtils.durationMessageComing),
      initialValue: null,
    );

    _stateChangeDebouncer?.values.listen(_handleStateChange);
  }

  void _handleStateChange(StateChange? stateChange) {
    try {
      log('WebSocketController::_handleStateChange:stateChange = $stateChange');
      if (stateChange == null || accountId == null || session == null) return;

      final mapTypeState = stateChange.getMapTypeState(accountId!);
      mappingTypeStateToAction(
        mapTypeState,
        accountId!,
        emailChangeListener: EmailChangeListener.instance,
        mailboxChangeListener: MailboxChangeListener.instance,
        session!.username,
        session: session,
      );
    } catch (e) {
      logError('WebSocketController::_handleStateChange:Exception = $e');
    }
  }

  void _monitorNetwork() {
    _networkConnectionController = getBinding<NetworkConnectionController>();
    _connectivitySubscription = _networkConnectionController
      ?.connectivity
      .onConnectivityChanged.listen((status) {
        if (status == ConnectivityResult.none) {
          log('WebSocketController::_monitorNetwork:No network connection');
          _cleanUpWebSocketResources();
        } else {
          log('WebSocketController::_monitorNetwork:Network connection restore');
          _connectWebSocket();
        }
      });
  }
}