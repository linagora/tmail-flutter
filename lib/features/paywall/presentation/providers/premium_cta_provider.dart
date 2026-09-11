import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/saas/saas_account_capability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_system_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/linagora_ecosystem_providers.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

part 'premium_cta_provider.g.dart';

enum EcosystemUnavailableReason {
  missingAccount,
  missingJmapUrl,
  dependencyUnavailable,
  loadFailed,
}

sealed class EcosystemState {
  const EcosystemState();
}

class EcosystemLoading extends EcosystemState with EquatableMixin {
  const EcosystemLoading();

  @override
  List<Object?> get props => [];
}

class EcosystemUnavailable extends EcosystemState with EquatableMixin {
  final EcosystemUnavailableReason reason;
  final Object? error;

  const EcosystemUnavailable(this.reason, {this.error});

  @override
  List<Object?> get props => [reason, error];
}

class EcosystemAvailable extends EcosystemState with EquatableMixin {
  final LinagoraEcosystem ecosystem;

  const EcosystemAvailable(this.ecosystem);

  @override
  List<Object?> get props => [ecosystem];
}

enum PremiumCtaUnavailableReason {
  missingAccount,
  premiumNotAvailable,
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
) async {
  final interactor = ref.watch(getLinagoraEcosystemInteractorProvider);
  if (interactor == null) {
    logWarning('ecosystemProvider: GetLinagoraEcosystemInteractor is missing');
    throw StateError('GetLinagoraEcosystemInteractor is unavailable');
  }
  return _EcosystemLoader(ref).load(interactor, jmapUrl);
}

Duration? _neverRetry(int retryCount, Object error) => null;

@riverpod
EcosystemState activeEcosystem(Ref ref, AccountId? accountId, String? jmapUrl) {
  if (accountId == null) {
    return const EcosystemUnavailable(
      EcosystemUnavailableReason.missingAccount,
    );
  }
  if (ref.watch(getLinagoraEcosystemInteractorProvider) == null) {
    return const EcosystemUnavailable(
      EcosystemUnavailableReason.dependencyUnavailable,
    );
  }

  final normalizedJmapUrl = jmapUrl?.trim();
  if (normalizedJmapUrl == null || normalizedJmapUrl.isEmpty) {
    return const EcosystemUnavailable(
      EcosystemUnavailableReason.missingJmapUrl,
    );
  }

  return ref.watch(ecosystemProvider(accountId, normalizedJmapUrl)).when(
    loading: () => const EcosystemLoading(),
    error: (error, _) => EcosystemUnavailable(
      EcosystemUnavailableReason.loadFailed,
      error: error,
    ),
    data: EcosystemAvailable.new,
  );
}

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

/// Consumes the ecosystem interactor through the shared seam so the failure is
/// logged once and urgent exceptions still reach the re-login / reconnect flow
/// (ADR-0103), exactly like `BaseController.consumeState` does for GetX.
class _EcosystemLoader with InteractorConsumer {
  final Ref _ref;

  _EcosystemLoader(this._ref);

  Future<LinagoraEcosystem> load(
    GetLinagoraEcosystemInteractor interactor,
    String jmapUrl,
  ) async {
    LinagoraEcosystem? loadedEcosystem;
    Object? failure;
    StackTrace? failureStackTrace;

    await consumeInteractor(
      () => interactor.execute(jmapUrl).firstWhere(_isTerminalEcosystemState),
      isStale: () => !_ref.mounted,
      onSuccess: (success) {
        if (success is GetLinagoraEcosystemSuccess) {
          loadedEcosystem = success.linagoraEcosystem;
        }
      },
      onFailure: (error, stackTrace) {
        failure = error;
        failureStackTrace = stackTrace;
      },
    );

    final error = failure;
    if (error != null) {
      Error.throwWithStackTrace(error, failureStackTrace ?? StackTrace.current);
    }
    final ecosystem = loadedEcosystem;
    if (ecosystem == null) {
      throw StateError('Ecosystem result is unavailable');
    }
    return ecosystem;
  }
}

bool _isTerminalEcosystemState(Either<Failure, Success> state) => state.fold(
      (_) => true,
      (success) => success is! GettingLinagoraEcosystem,
    );

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
  final resolvedUrl = PaywallUrlPattern(template).getQualifiedUrl(
    ownerEmail: context.owner.email,
    domainName: context.owner.domainName,
  );
  if (!PaywallUtils.isValidPaywallUrl(resolvedUrl)) {
    logWarning('premiumCtaProvider: paywall template resolves to an unsafe URL');
    return const PremiumCtaUnavailable(
      PremiumCtaUnavailableReason.invalidDestination,
    );
  }
  return PremiumCtaAvailable(Uri.parse(resolvedUrl));
}
