import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_system_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/linagora_ecosystem_providers.dart';

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

typedef WatchEcosystem = AsyncValue<LinagoraEcosystem> Function(
  AccountId accountId,
  String jmapUrl,
);

Duration? neverRetryEcosystem(int retryCount, Object error) => null;

Future<LinagoraEcosystem> loadEcosystem(
  Ref ref,
  String jmapUrl,
) async {
  final interactor = ref.watch(getLinagoraEcosystemInteractorProvider);
  if (interactor == null) {
    logWarning('ecosystemProvider: GetLinagoraEcosystemInteractor is missing');
    throw StateError('GetLinagoraEcosystemInteractor is unavailable');
  }
  return _EcosystemLoader(ref).load(interactor, jmapUrl);
}

EcosystemState resolveActiveEcosystem(
  Ref ref,
  AccountId? accountId,
  String? jmapUrl,
  WatchEcosystem watchEcosystem,
) {
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

  return watchEcosystem(accountId, normalizedJmapUrl).when(
    loading: () => const EcosystemLoading(),
    error: (error, _) => EcosystemUnavailable(
      EcosystemUnavailableReason.loadFailed,
      error: error,
    ),
    data: EcosystemAvailable.new,
  );
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
