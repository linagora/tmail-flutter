import 'mcp_app_binding.dart';

class McpAppRuntime {
  static void bootstrap(List<McpAppBinding> bindings) {
    final enabled = [for (final binding in bindings) if (binding.isEnabled) binding];
    final owners = [
      for (final binding in enabled)
        if (binding.ownsWidgetsBinding) binding,
    ];
    if (owners.length > 1) {
      throw StateError(
        'Only one MCP binding may own WidgetsBinding. '
        'Got: ${owners.map((binding) => binding.name).join(', ')}',
      );
    }
    for (final binding in owners) {
      binding.ensureInitialized();
    }
    for (final binding in enabled) {
      if (!binding.ownsWidgetsBinding) {
        binding.ensureInitialized();
      }
    }
    for (final binding in enabled) {
      binding.registerExtensions();
    }
  }
}
