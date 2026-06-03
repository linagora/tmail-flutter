import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/resolve_composer_cache_for_restore_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_cache_interactor_providers.dart';

part 'composer_auto_save_notifier.g.dart';

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

/// Riverpod [Notifier] for Android composer auto-save (see ADR-0086).
/// Keyed by composerId so each [ComposerController] gets an isolated instance.
/// Must be invalidated from [ComposerController.onClose] to prevent unbounded
/// family-instance growth in the global [ProviderContainer].
@Riverpod(keepAlive: true)
class ComposerAutoSaveNotifier extends _$ComposerAutoSaveNotifier {
  @override
  ComposerAutoSaveState build(String composerId) => const ComposerAutoSaveState();

  bool get mounted => ref.mounted;
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
    final result = await ref.read(resolveComposerCacheForRestoreProvider).execute(accountId, userName);
    return result.fold(
      (failure) {
        log('ComposerAutoSaveNotifier::restore: failure=${failure.runtimeType}');
        return null;
      },
      (success) {
        if (success is! ResolveComposerCacheForRestoreSuccess) return null;
        final cache = success.cache;
        if (cache != null && mounted) {
          state = state.copyWith(hasRecoverableSnapshot: true);
          log('ComposerAutoSaveNotifier::restore: found snapshot');
        }
        return cache;
      },
    );
  }

  Future<void> clearCache(AccountId accountId, UserName userName) async {
    final result = await ref.read(removeAllComposerCacheProvider).execute(accountId, userName);
    result.fold(
      (failure) => log('ComposerAutoSaveNotifier::clearCache: failure=${failure.runtimeType}'),
      (_) {
        if (!mounted) return;
        state = state.copyWith(hasRecoverableSnapshot: false);
        log('ComposerAutoSaveNotifier::clearCache: cleared');
      },
    );
  }
}
