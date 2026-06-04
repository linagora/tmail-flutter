import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class DashboardProviderListenerDelegate {
  void listen(BuildContext context, WidgetRef ref);

  void dispose();
}

// Factory function type for creating delegates.
// Using a factory instead of passing delegate instances directly ensures
// mutable subscription state always lives in State, not on widget properties.
typedef DashboardDelegateFactory = DashboardProviderListenerDelegate Function();
