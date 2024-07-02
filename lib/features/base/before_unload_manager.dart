typedef BeforeUnloadListener = Future<void> Function();

class BeforeUnloadManager {
  static final BeforeUnloadManager _instance = BeforeUnloadManager._();
  factory BeforeUnloadManager() => _instance;
  BeforeUnloadManager._();

  final _listeners = <BeforeUnloadListener>[];

  void addListener(BeforeUnloadListener listener) {
    _listeners.add(listener);
  }

  Future<void> executeBeforeUnloadListeners() async {
    await Future.wait(_listeners.map((listener) => listener.call()));
  }
}