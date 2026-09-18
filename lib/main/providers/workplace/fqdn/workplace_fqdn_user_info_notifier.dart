import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_source.dart';

part 'workplace_fqdn_user_info_notifier.g.dart';

/// Workplace FQDN from the OIDC `/userInfo` claim.
@Riverpod(keepAlive: true)
class WorkplaceFqdnUserInfoNotifier extends _$WorkplaceFqdnUserInfoNotifier
    implements WorkplaceFqdnSource {
  @override
  String? build() => null;

  @override
  void setFqdn(String? rawFqdn) => state = normalizeWorkplaceFqdn(rawFqdn);
}
