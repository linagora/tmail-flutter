import 'package:flutter_test/flutter_test.dart';

import '../../tmail-mcp/runtime/mcp_app_binding.dart';
import '../../tmail-mcp/runtime/mcp_app_runtime.dart';

void main() {
  test('skips disabled bindings', () {
    final disabled = _FakeBinding(name: 'off', enabled: false);
    final enabled = _FakeBinding(name: 'on', enabled: true);

    McpAppRuntime.bootstrap([disabled, enabled]);

    expect(disabled.initialized, isFalse);
    expect(disabled.extensionsRegistered, isFalse);
    expect(enabled.initialized, isTrue);
    expect(enabled.extensionsRegistered, isTrue);
  });

  test('initializes the WidgetsBinding owner before other bindings', () {
    final order = <String>[];
    final owner = _FakeBinding(
      name: 'owner',
      enabled: true,
      widgetsBindingOwner: true,
      order: order,
    );
    final other = _FakeBinding(
      name: 'other',
      enabled: true,
      order: order,
    );

    McpAppRuntime.bootstrap([other, owner]);

    expect(order, ['init:owner', 'init:other', 'ext:other', 'ext:owner']);
  });

  test('rejects two WidgetsBinding owners', () {
    expect(
      () => McpAppRuntime.bootstrap([
        _FakeBinding(
          name: 'a',
          enabled: true,
          widgetsBindingOwner: true,
        ),
        _FakeBinding(
          name: 'b',
          enabled: true,
          widgetsBindingOwner: true,
        ),
      ]),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('a, b'),
        ),
      ),
    );
  });
}

class _FakeBinding extends McpAppBinding {
  _FakeBinding({
    required this.name,
    required this.enabled,
    this.widgetsBindingOwner = false,
    this.order,
  });

  @override
  final String name;

  final bool enabled;
  final bool widgetsBindingOwner;
  final List<String>? order;

  bool initialized = false;
  bool extensionsRegistered = false;

  @override
  bool get isEnabled => enabled;

  @override
  bool get ownsWidgetsBinding => widgetsBindingOwner;

  @override
  void ensureInitialized() {
    initialized = true;
    order?.add('init:$name');
  }

  @override
  void registerExtensions() {
    extensionsRegistered = true;
    order?.add('ext:$name');
  }
}
