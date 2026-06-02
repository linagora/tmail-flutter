import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkplaceFqdnNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFqdn(String? rawFqdn) {
    final fqdn = rawFqdn?.trim();
    if (fqdn == null || fqdn.isEmpty) {
      state = null;
      return;
    }
    final uri = Uri.tryParse(fqdn.startsWith('http') ? fqdn : 'https://$fqdn');
    state = uri != null && (uri.scheme == 'https' || kDebugMode) ? fqdn : null;
  }
}

final workplaceFqdnProvider = NotifierProvider<WorkplaceFqdnNotifier, String?>(
  WorkplaceFqdnNotifier.new,
);
