import 'dart:async';
import 'dart:convert';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/web_socket_echo_request.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/web_socket_push_enable_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/web_socket_push_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/connect_web_socket_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/push_base_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/state_change_extension.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/mailbox_change_listener.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController extends PushBaseController {
  WebSocketController._internal();

  static final WebSocketController _instance = WebSocketController._internal();

  static WebSocketController get instance => _instance;

  ConnectWebSocketInteractor? _connectWebSocketInteractor;

  int _retryRemained = 3;
  WebSocketChannel? _webSocketChannel;
  Timer? _webSocketPingTimer;
  StreamSubscription? _webSocketSubscription;

  @override
  void handleFailureViewState(Failure failure) {
    logError('WebSocketController::handleFailureViewState():Failure $failure');
    _webSocketSubscription?.cancel();
    _webSocketChannel = null;
    _webSocketPingTimer?.cancel();
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
    super.initialize(accountId: accountId, session: session);

    _connectWebSocket(accountId, session);
  }

  void _connectWebSocket(AccountId? accountId, Session? session) {
    _connectWebSocketInteractor = getBinding<ConnectWebSocketInteractor>();
    if (_connectWebSocketInteractor == null || accountId == null || session == null) {
      return;
    }

    consumeState(_connectWebSocketInteractor!.execute(session, accountId));
  }
  
  void _handleWebSocketConnectionSuccess(WebSocketConnectionSuccess success) {
    log('WebSocketController::_handleWebSocketConnectionSuccess(): $success');
    _retryRemained = 3;
    _webSocketChannel = success.webSocketChannel;
    _enableWebSocketPush();
    if (AppConfig.isWebSocketEchoPingEnabled) {
      _pingWebSocket();
    }
    _listenToWebSocket();
  }

  void _handleWebSocketConnectionRetry() {
    _webSocketSubscription?.cancel();
    _webSocketChannel = null;
    _webSocketPingTimer?.cancel();
    if (_retryRemained > 0) {
      _retryRemained--;
      _connectWebSocket(accountId, session);
    }
  }

  void _enableWebSocketPush() {
    _webSocketChannel?.sink.add(jsonEncode(WebSocketPushEnableRequest.toJson(
      dataTypes: [TypeName.emailType, TypeName.mailboxType]
    )));
  }

  void _pingWebSocket() {
    _webSocketPingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _webSocketChannel?.sink.add(jsonEncode(WebSocketEchoRequest().toJson()));
    });
  }

  void _listenToWebSocket() {
    _webSocketSubscription = _webSocketChannel?.stream.listen(
      (data) {
        log('WebSocketController::_listenToWebSocket(): $data');
        if (session == null || accountId == null) return;
        if (data is String) {
          data = jsonDecode(data);
        }

        try {
          final stateChange = StateChange.fromJson(data);
          final mapTypeState = stateChange.getMapTypeState(accountId!);
          mappingTypeStateToAction(
            mapTypeState,
            accountId!,
            emailChangeListener: EmailChangeListener.instance,
            mailboxChangeListener: MailboxChangeListener.instance,
            session!.username,
            session: session);
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
}