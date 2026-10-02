import 'mcp_app_binding.dart';

class McpAppRuntime {
  static void bootstrap(List<McpAppBinding> bindings) {
    final enabled = bindings.where((binding) => binding.isEnabled).toList();
    final owners = enabled
        .where((binding) => binding.ownsWidgetsBinding)
        .toList();
    _assertSingleOwner(owners);
    _initialize(owners, enabled);
    for (final binding in enabled) {
      binding.registerExtensions();
    }
  }

  static void _assertSingleOwner(List<McpAppBinding> owners) {
    if (owners.length <= 1) return;
    throw StateError(
      'Only one MCP binding may own WidgetsBinding. '
      'Got: ${owners.map((binding) => binding.name).join(', ')}',
    );
  }

  static void _initialize(
    List<McpAppBinding> owners,
    List<McpAppBinding> enabled,
  ) {
    for (final binding in owners) {
      binding.ensureInitialized();
    }
    for (final binding in enabled) {
      if (binding.ownsWidgetsBinding) continue;
      binding.ensureInitialized();
    }
  }
}
