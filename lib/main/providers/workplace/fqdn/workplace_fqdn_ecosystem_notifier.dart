import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_source.dart';

part 'workplace_fqdn_ecosystem_notifier.g.dart';

/// Workplace FQDN resolved from the ecosystem `workplaceFqdnFallback` template.
@Riverpod(keepAlive: true)
class WorkplaceFqdnEcosystemNotifier extends _$WorkplaceFqdnEcosystemNotifier
    implements WorkplaceFqdnSource {
  @override
  String? build() => null;

  @override
  void setFqdn(String? rawFqdn) => state = normalizeWorkplaceFqdn(rawFqdn);
}
