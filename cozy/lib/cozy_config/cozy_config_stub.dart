class _CozyConfigManagerStub {
  Future<void> injectCozyScript() async {
    throw UnimplementedError();
  }

  Future<void> initialize() async {
    throw UnimplementedError();
  }
}

class CozyConfig {
  static final CozyConfig _instance = CozyConfig._internal();

  factory CozyConfig() {
    return _instance;
  }

  CozyConfig._internal();

  final manager = _CozyConfigManagerStub();

  Future<bool> get isInsideCozy async {
    return false;
  }
}
