
class TwakeAppManager {
  bool _hasComposer = false;
  bool _isExecutingBeforeReconnect = false;

  void setHasComposer(bool value) => _hasComposer = value;

  bool get hasComposer => _hasComposer;

  void setExecutingBeforeReconnect(bool value) => _isExecutingBeforeReconnect = value;

  bool get isExecutingBeforeReconnect => _isExecutingBeforeReconnect;
}
