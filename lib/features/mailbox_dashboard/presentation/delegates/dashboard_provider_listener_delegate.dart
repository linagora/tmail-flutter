import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class DashboardProviderListenerDelegate {
  void listen(BuildContext context, WidgetRef ref);
}
