import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_sources.dart';

part 'workplace_fqdn_provider.g.dart';

/// The effective Workplace FQDN: the highest-priority source that has a value.
///
/// Every source is watched (via [workplaceFqdnSourcesProvider]'s readers), so
/// a higher-priority source that resolves late still takes over from a
/// lower-priority one already emitted.
@Riverpod(keepAlive: true)
String? workplaceFqdn(Ref ref) {
  String? resolved;
  for (final readSource in ref.watch(workplaceFqdnSourcesProvider)) {
    final fqdn = readSource(ref);
    resolved ??= fqdn;
  }
  return resolved;
}
