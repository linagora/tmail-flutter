import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/saas/saas_account_capability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/active_ecosystem_provider.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_provider.dart';

part 'premium_cta_provider.g.dart';

Duration? _neverRetry(int retryCount, Object error) =>
    neverRetryEcosystem(retryCount, error);

enum PremiumCtaUnavailableReason {
  missingAccount,
  premiumNotAvailable,
  notInsideCozy,
  highestSubscription,
  missingJmapUrl,
  ecosystemUnavailable,
  paywallNotConfigured,
  invalidDestination,
}

sealed class PremiumCtaState {
  const PremiumCtaState();
}

class PremiumCtaLoading extends PremiumCtaState with EquatableMixin {
  const PremiumCtaLoading();

  @override
  List<Object?> get props => [];
}

class PremiumCtaUnavailable extends PremiumCtaState with EquatableMixin {
  final PremiumCtaUnavailableReason reason;
  final Object? error;

  const PremiumCtaUnavailable(this.reason, {this.error});

  @override
  List<Object?> get props => [reason, error];
}

class PremiumCtaAvailable extends PremiumCtaState with EquatableMixin {
  final Uri destination;

  const PremiumCtaAvailable(this.destination);

  @override
  List<Object?> get props => [destination];
}

/// The identity that fills the paywall URL template.
@immutable
class PremiumCtaOwner with EquatableMixin {
  final String email;
  final String? domainName;

  const PremiumCtaOwner({required this.email, this.domainName});

  @override
  List<Object?> get props => [email, domainName];
}

/// Identity of one premium CTA consumer.
///
/// Only the SaaS capability is kept instead of the whole [Session]: it is the
/// single session value the CTA depends on, and it keeps this family key cheap
/// to hash and free of a session-sized retained object.
@immutable
class PremiumCtaContext with EquatableMixin {
  final AccountId accountId;
  final SaaSAccountCapability? capability;
  final PremiumCtaOwner owner;
  final String? jmapUrl;

  const PremiumCtaContext({
    required this.accountId,
    required this.capability,
    required this.owner,
    this.jmapUrl,
  });

  static PremiumCtaContext? tryCreate({
    required Session? session,
    required AccountId? accountId,
    required PremiumCtaOwner owner,
    String? jmapUrl,
  }) {
    if (session == null || accountId == null) return null;
    return PremiumCtaContext(
      accountId: accountId,
      capability: session.getSaaSAccountCapability(accountId),
      owner: owner,
      jmapUrl: jmapUrl,
    );
  }

  @override
  List<Object?> get props => [accountId, capability, owner, jmapUrl];
}

/// Fetches the ecosystem once per (account, JMAP URL) pair.
///
/// Auto-disposed: [EcosystemProviderListenerDelegate] holds a session-long
/// subscription on [activeEcosystemProvider] for the signed-in account, which
/// is what keeps this result warm for the imperative `read` call sites
/// (composer over-quota dialog, sidebar scroll offset).
@Riverpod(retry: _neverRetry)
Future<LinagoraEcosystem> ecosystem(
  Ref ref,
  AccountId accountId,
  String jmapUrl,
) => loadEcosystem(ref, jmapUrl);

@riverpod
EcosystemState activeEcosystem(Ref ref, AccountId? accountId, String? jmapUrl) =>
    resolveActiveEcosystem(
      ref,
      accountId,
      jmapUrl,
      (accountId, jmapUrl) => ref.watch(
        ecosystemProvider(accountId, jmapUrl),
      ),
    );

@riverpod
PremiumCtaState premiumCta(Ref ref, PremiumCtaContext? context) {
  if (context == null) {
    return const PremiumCtaUnavailable(
      PremiumCtaUnavailableReason.missingAccount,
    );
  }

  final capability = context.capability;
  if (capability?.isAlreadyHighestSubscription == true) {
    return const PremiumCtaUnavailable(
      PremiumCtaUnavailableReason.highestSubscription,
    );
  }
  if (capability?.isPremiumAvailable != true) {
    return const PremiumCtaUnavailable(
      PremiumCtaUnavailableReason.premiumNotAvailable,
    );
  }

  final insideCozy = ref.watch(insideCozyProvider);
  if (insideCozy.isLoading) return const PremiumCtaLoading();
  if (insideCozy.value != true) {
    return const PremiumCtaUnavailable(
      PremiumCtaUnavailableReason.notInsideCozy,
    );
  }

  final workplaceUrl = PaywallUtils.buildWorkplacePaywallUrl(
    ref.watch(workplaceFqdnProvider),
  );
  if (PaywallUtils.isValidPaywallUrl(workplaceUrl)) {
    return PremiumCtaAvailable(Uri.parse(workplaceUrl));
  }

  return switch (ref.watch(
    activeEcosystemProvider(context.accountId, context.jmapUrl),
  )) {
    EcosystemLoading() => const PremiumCtaLoading(),
    EcosystemUnavailable(:final reason, :final error) => PremiumCtaUnavailable(
        reason == EcosystemUnavailableReason.missingJmapUrl
            ? PremiumCtaUnavailableReason.missingJmapUrl
            : PremiumCtaUnavailableReason.ecosystemUnavailable,
        error: error,
      ),
    EcosystemAvailable(:final ecosystem) => _resolveEcosystemPaywall(
        context,
        ecosystem,
      ),
  };
}

PremiumCtaState _resolveEcosystemPaywall(
  PremiumCtaContext context,
  LinagoraEcosystem ecosystem,
) {
  final template = ecosystem.paywallUrlTemplate;
  if (template == null) {
    return const PremiumCtaUnavailable(
      PremiumCtaUnavailableReason.paywallNotConfigured,
    );
  }
  final resolvedUrl = PaywallUrlPattern(template).resolveQualifiedUrl(
    ownerEmail: context.owner.email,
    domainName: context.owner.domainName,
  );
  if (resolvedUrl == null || !PaywallUtils.isValidPaywallUrl(resolvedUrl)) {
    logWarning('premiumCtaProvider: paywall template resolves to an unsafe URL');
    return const PremiumCtaUnavailable(
      PremiumCtaUnavailableReason.invalidDestination,
    );
  }
  return PremiumCtaAvailable(Uri.parse(resolvedUrl));
}
