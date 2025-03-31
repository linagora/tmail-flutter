class CozyConfigManager {
  Future<void> injectCozyScript() async {
    throw UnimplementedError('Cannot use injectCozyScript in non-web environment');
  }

  Future<void> initialize() async {
    throw UnimplementedError('Cannot initialize in non-web environment');
  }

  Future<bool> get isInsideCozy async {
    return false;
  }
}