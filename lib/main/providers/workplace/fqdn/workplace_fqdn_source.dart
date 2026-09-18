import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads one source's Workplace FQDN off [ref], or null when that source has
/// nothing to offer. Implementations call `ref.watch(someSourceProvider)` so
/// the resolver keeps tracking that source as a dependency.
typedef WorkplaceFqdnSourceReader = String? Function(Ref ref);

/// One source of the Workplace FQDN. Every source exposes the same API so
/// [workplaceFqdnProvider] can rank them purely by list position.
abstract interface class WorkplaceFqdnSource {
  void setFqdn(String? rawFqdn);
}

/// Trims and validates a raw FQDN; returns null when it is unusable.
String? normalizeWorkplaceFqdn(String? rawFqdn) {
  final fqdn = rawFqdn?.trim();
  if (fqdn == null || fqdn.isEmpty) return null;
  final uri = Uri.tryParse(fqdn.startsWith('http') ? fqdn : 'https://$fqdn');
  return uri != null && _isUsableWorkplaceUri(uri) ? fqdn : null;
}

/// A bare host, no path/query/fragment, https outside debug builds.
bool _isUsableWorkplaceUri(Uri uri) {
  if (uri.host.isEmpty) return false;
  if (!_isBareUri(uri)) return false;
  return uri.scheme == 'https' || kDebugMode;
}

bool _isBareUri(Uri uri) =>
    uri.path.isEmpty && !uri.hasQuery && !uri.hasFragment;
