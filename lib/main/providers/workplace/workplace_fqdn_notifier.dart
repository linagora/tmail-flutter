import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workplace_fqdn_notifier.g.dart';

@Riverpod(keepAlive: true)
class WorkplaceFqdnNotifier extends _$WorkplaceFqdnNotifier {
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
