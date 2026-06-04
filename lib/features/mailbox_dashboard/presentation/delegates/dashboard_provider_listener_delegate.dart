import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class DashboardProviderListenerDelegate {
  // contextOf() is called per-callback so each side effect (toast, dialog) gets a live BuildContext.
  void setup(WidgetRef ref, BuildContext Function() contextOf);

  void dispose();
}

// Factory keeps mutable subscription state inside State, not on a widget property.
typedef DashboardDelegateFactory = DashboardProviderListenerDelegate Function();
