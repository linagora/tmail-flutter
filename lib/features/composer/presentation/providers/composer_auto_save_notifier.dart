import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_cache_providers.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/resolve_composer_cache_for_restore_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/resolve_composer_cache_for_restore_interactor.dart';

class ComposerAutoSaveState extends Equatable {
  final bool hasRecoverableSnapshot;
  final bool isCleanClose;
  final String lastKnownHtmlContent;

  const ComposerAutoSaveState({
    this.hasRecoverableSnapshot = false,
    this.isCleanClose = false,
    this.lastKnownHtmlContent = '',
  });

  ComposerAutoSaveState copyWith({
    bool? hasRecoverableSnapshot,
    bool? isCleanClose,
    String? lastKnownHtmlContent,
  }) =>
      ComposerAutoSaveState(
        hasRecoverableSnapshot: hasRecoverableSnapshot ?? this.hasRecoverableSnapshot,
        isCleanClose: isCleanClose ?? this.isCleanClose,
        lastKnownHtmlContent: lastKnownHtmlContent ?? this.lastKnownHtmlContent,
      );

  @override
  List<Object?> get props => [
        hasRecoverableSnapshot,
        isCleanClose,
        lastKnownHtmlContent,
      ];
}

/// Riverpod [StateNotifier] for Android composer auto-save (see ADR-0086).
/// Keyed by composerId so each [ComposerController] gets an isolated instance.
/// Must be invalidated from [ComposerController.onClose] to prevent unbounded
/// family-instance growth in the global [ProviderContainer].
class ComposerAutoSaveNotifier extends StateNotifier<ComposerAutoSaveState> {
  final ResolveComposerCacheForRestoreInteractor _resolveInteractor;
  final RemoveAllComposerCacheInteractor _removeInteractor;

  ComposerAutoSaveNotifier(
    this._resolveInteractor,
    this._removeInteractor,
  ) : super(const ComposerAutoSaveState());

  bool get hasRecoverableSnapshot => state.hasRecoverableSnapshot;
  bool get isCleanClose => state.isCleanClose;
  String get lastKnownHtmlContent => state.lastKnownHtmlContent;

  void onSnapshotSaved() {
    state = state.copyWith(hasRecoverableSnapshot: true);
    log('ComposerAutoSaveNotifier::onSnapshotSaved: snapshot recorded');
  }

  void setCleanClose() {
    state = state.copyWith(isCleanClose: true);
    log('ComposerAutoSaveNotifier::setCleanClose: flagged');
  }

  void updateLastKnownContent(String content) {
    state = state.copyWith(lastKnownHtmlContent: content);
  }

  Future<ComposerPersistentCache?> restore(
    AccountId accountId,
    UserName userName,
  ) async {
    final result = await _resolveInteractor.execute(accountId, userName);
    return result.fold(
      (failure) {
        log('ComposerAutoSaveNotifier::restore: failure=${failure.runtimeType}');
        return null;
      },
      (success) {
        if (success is! ResolveComposerCacheForRestoreSuccess) return null;
        final cache = success.cache;
        if (cache != null) {
          state = state.copyWith(hasRecoverableSnapshot: true);
          log('ComposerAutoSaveNotifier::restore: found snapshot');
        }
        return cache;
      },
    );
  }

  Future<void> clearCache(AccountId accountId, UserName userName) async {
    final result = await _removeInteractor.execute(accountId, userName);
    result.fold(
      (failure) => log('ComposerAutoSaveNotifier::clearCache: failure=${failure.runtimeType}'),
      (_) {
        state = state.copyWith(hasRecoverableSnapshot: false);
        log('ComposerAutoSaveNotifier::clearCache: cleared');
      },
    );
  }
}

final composerAutoSaveProvider = StateNotifierProvider.family<
    ComposerAutoSaveNotifier, ComposerAutoSaveState, String>(
  (ref, composerId) => ComposerAutoSaveNotifier(
    ref.read(resolveComposerCacheForRestoreProvider),
    ref.read(removeAllComposerCacheProvider),
  ),
);
