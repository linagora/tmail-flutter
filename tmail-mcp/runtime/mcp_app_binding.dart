abstract class McpAppBinding {
  const McpAppBinding();

  String get name;

  bool get isEnabled;

  bool get ownsWidgetsBinding => false;

  void ensureInitialized();

  void registerExtensions() {}
}
