import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workplace_fqdn_notifier.g.dart';

@Riverpod(keepAlive: true)
class WorkplaceFqdnNotifier extends _$WorkplaceFqdnNotifier {
  String? _fromUserInfo;
  String? _fromEcosystem;

  @override
  String? build() => null;

  /// The OIDC `/userInfo` claim — the preferred source.
  void setFqdn(String? rawFqdn) {
    _fromUserInfo = _normalize(rawFqdn);
    _emit();
  }

  /// The ecosystem `workplaceFqdnFallback` template, already resolved.
  void setFallbackFqdn(String? rawFqdn) {
    _fromEcosystem = _normalize(rawFqdn);
    _emit();
  }

  void _emit() => state = _fromUserInfo ?? _fromEcosystem;

  String? _normalize(String? rawFqdn) {
    final fqdn = rawFqdn?.trim();
    if (fqdn == null || fqdn.isEmpty) return null;
    final uri = Uri.tryParse(fqdn.startsWith('http') ? fqdn : 'https://$fqdn');
    return uri != null && (uri.scheme == 'https' || kDebugMode) ? fqdn : null;
  }
}
