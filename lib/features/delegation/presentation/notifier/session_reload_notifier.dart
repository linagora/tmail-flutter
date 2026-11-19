import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/delegation_ended_coordinator.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/session_reload.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_enabled_provider.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/active_ecosystem_provider.dart';

part 'session_reload_notifier.g.dart';

typedef CurrentTime = DateTime Function();

final sessionReloadClockProvider = Provider<CurrentTime>((ref) => DateTime.now);

/// Re-reads the session, since the server pushes no session change. Holds the last applied re-read.
/// See ADR-0114 §Sync and §Revocation.
@Riverpod(keepAlive: true)
class SessionReloadNotifier extends _$SessionReloadNotifier with InteractorConsumer {
  static const resumeInterval = Duration(minutes: 1);

  GetSessionInteractor get _getSessionInteractor => Get.find<GetSessionInteractor>();

  Future<SessionReload?>? _inFlight;
  Future<SessionReload?>? _queued;
  DateTime? _lastResumeReadAt;
  final _listedAfterAccountNotFound = <AccountId>{};
  int _resumeCount = 0;

  /// Riverpod keeps this instance across rebuilds, so the fields of an ended session are reset here.
  @override
  SessionReload? build() {
    _inFlight = null;
    _queued = null;
    _lastResumeReadAt = null;
    _listedAfterAccountNotFound.clear();
    _resumeCount = 0;
    return null;
  }

  /// Starts after every change made before the call, so a removed mailbox is never listed again.
  Future<Session?> reload() async => (await _readAfterCurrent())?.session;

  void reloadOnResume() {
    if (!ref.read(delegationEnabledProvider)) return;
    _resumeCount++;
    _listedAfterAccountNotFound.clear();
    final now = ref.read(sessionReloadClockProvider)();
    final lastReadAt = _lastResumeReadAt;
    if (lastReadAt != null && now.difference(lastReadAt) < resumeInterval) return;
    _lastResumeReadAt = now;
    unawaited(_readAfterCurrent());
  }

  /// Not throttled. Once a re-read still lists the shown account, its errors wait for the next resume.
  void reloadOnAccountNotFound() {
    final shownAccount = ref.read(activeAccountProvider);
    if (shownAccount == null || !shownAccount.isDelegated) return;
    if (!ref.read(delegationEnabledProvider)) return;
    final accountId = shownAccount.accountId;
    if (_listedAfterAccountNotFound.contains(accountId)) return;

    // A read answered after a resume must not restore the suppression that resume cleared.
    final resumeCountAtTrigger = _resumeCount;
    unawaited(_readAfterCurrent().then((reload) {
      if (resumeCountAtTrigger != _resumeCount) return;
      if (reload != null && reload.session.isDelegatedAccount(accountId)) {
        _listedAfterAccountNotFound.add(accountId);
      }
    }));
  }

  /// One read in flight. Calls made meanwhile share a single read that starts after it.
  Future<SessionReload?> _readAfterCurrent() {
    final inFlight = _inFlight;
    if (inFlight == null) return _startRead();
    final isStale = _staleGuardOfCurrentBuild();
    return _queued ??= inFlight.then((_) {
      if (isStale()) return null;
      _queued = null;
      return _startRead();
    });
  }

  Future<SessionReload?> _startRead() {
    late final Future<SessionReload?> read;
    read = _readAndApply().whenComplete(() {
      if (identical(_inFlight, read)) _inFlight = null;
    });
    return _inFlight = read;
  }

  Future<SessionReload?> _readAndApply() async {
    final isStale = _staleGuardOfCurrentBuild();
    Session? reloadedSession;
    try {
      await consumeInteractor(InteractorConsumeRequest(
        // The cache fallback would hide an expired login on mobile.
        run: () => _getSessionInteractor.execute(fallbackToCache: false).last,
        isStale: isStale,
        onSuccess: (success) {
          // A cached session still lists a revoked mailbox.
          if (success is GetSessionSuccess && !success.fromCache) {
            reloadedSession = success.session;
          }
        },
        onFailure: (_, __) {},
        // A background re-read stays silent offline, an expired login still signs out.
        shouldRouteUrgentException: shouldRouteEcosystemUrgentException,
      ));
      final session = reloadedSession;
      if (session == null || isStale()) return null;
      return await _apply(session, isStale);
    } catch (error, stackTrace) {
      // Callers are unawaited and a queued read waits on this one, so it never throws.
      logError(
        'SessionReloadNotifier::_readAndApply: ${error.runtimeType}',
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// [ref] moves to the next build, so a read started before a rebuild checks its own one.
  StaleGuard _staleGuardOfCurrentBuild() {
    final buildRef = ref;
    return () => !buildRef.mounted;
  }

  /// A late re-read never revives a signed-out or changed user.
  Future<SessionReload?> _apply(Session session, StaleGuard isStale) async {
    final shownAccount = ref.read(activeAccountProvider);
    if (shownAccount?.session.username != session.username) return null;

    final revoked = _isRevokedAndIdle(shownAccount!, session);
    final leave = revoked ? await ref.read(delegationEndedCoordinatorProvider).leave(shownAccount, isStale) : null;
    if (isStale()) return null;
    if (!ref.read(activeAccountProvider.notifier).applyReloadedSession(session)) return null;

    return state = SessionReload(
      session,
      revokedOwnerEmailAddress: revoked ? shownAccount.ownerEmailAddress : null,
      lostComposerCount: leave?.lostComposerCount ?? 0,
      keptComposerCount: leave?.keptComposerCount ?? 0,
      droppedAttachmentNames: leave?.droppedAttachmentNames ?? const [],
      couldNotReturnToMine: leave?.couldNotReturnToMine ?? false,
    );
  }

  /// A switch in flight to a revoked account cancels itself once the session drops it.
  bool _isRevokedAndIdle(ActiveAccount shownAccount, Session session) {
    return shownAccount.isDelegated &&
        !session.isDelegatedAccount(shownAccount.accountId) &&
        !ref.read(accountSwitchProvider).isSwitching;
  }
}
