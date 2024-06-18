import 'package:core/utils/app_logger.dart';

typedef BeforeUnloadListener = Future<void> Function();

class BeforeUnloadManager {
  static final BeforeUnloadManager _instance = BeforeUnloadManager._();
  factory BeforeUnloadManager() => _instance;
  BeforeUnloadManager._();

  final _listeners = <BeforeUnloadListener>[];

  void addListener(BeforeUnloadListener listener) {
    _listeners.add(listener);
  }

  void removeListener(BeforeUnloadListener listener) {
    _listeners.remove(listener);
  }

  Future<void> executeBeforeUnloadListeners() async {
    await Future.wait(_listeners.map((listener) => listener.call()))
      .onError((error, stackTrace) => [logError(error.toString())]);
  }
}