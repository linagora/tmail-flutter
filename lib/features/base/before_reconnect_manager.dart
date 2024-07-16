import 'package:core/utils/app_logger.dart';

typedef BeforeReconnectListener = Future<void> Function();

class BeforeReconnectManager {
  static final BeforeReconnectManager _instance = BeforeReconnectManager._();
  factory BeforeReconnectManager() => _instance;
  BeforeReconnectManager._();

  final _listeners = <BeforeReconnectListener>[];

  void addListener(BeforeReconnectListener listener) {
    _listeners.add(listener);
  }

  void removeListener(BeforeReconnectListener listener) {
    _listeners.remove(listener);
  }

  Future<void> executeBeforeReconnectListeners() async {
    await Future.wait(_listeners.map((listener) => listener.call()))
      .onError((error, stackTrace) => [logError(error.toString())]);
  }
}