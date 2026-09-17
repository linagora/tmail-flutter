import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

typedef ResolveOwnerEmail = String? Function();

/// Feeds the ecosystem FQDN template into the provider so deployments without
/// an OIDC `workplaceFqdn` claim still reach their Workplace.
class WorkplaceFqdnEcosystemHandler implements LinagoraEcosystemHandler {
  final ResolveOwnerEmail _resolveOwnerEmail;

  const WorkplaceFqdnEcosystemHandler({
    required ResolveOwnerEmail resolveOwnerEmail,
  }) : _resolveOwnerEmail = resolveOwnerEmail;

  @override
  void onEcosystemLoaded(LinagoraEcosystem ecosystem) {
    _setFallback(_resolveFallbackFqdn(ecosystem));
  }

  @override
  void onEcosystemCleared() => _setFallback(null);

  String? _resolveFallbackFqdn(LinagoraEcosystem ecosystem) {
    final template = ecosystem.workplaceFqdnFallbackTemplate;
    if (template == null) return null;

    final ownerEmail = _resolveOwnerEmail()?.trim();
    if (ownerEmail == null || ownerEmail.isEmpty) return null;

    final resolved =
        PaywallUrlPattern(template).getQualifiedUrl(ownerEmail: ownerEmail).trim();
    return resolved.isEmpty ? null : resolved;
  }

  void _setFallback(String? fqdn) {
    appProviderContainer
        .read(workplaceFqdnProvider.notifier)
        .setFallbackFqdn(fqdn);
  }
}
