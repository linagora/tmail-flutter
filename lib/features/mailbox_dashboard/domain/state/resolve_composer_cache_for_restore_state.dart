import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';

/// Emitted when the resolve logic completes, regardless of whether a
/// restorable snapshot was found.  [cache] is null when no valid snapshot
/// exists (expired, clean-close, or simply absent).
class ResolveComposerCacheForRestoreSuccess extends UIState {
  final ComposerPersistentCache? cache;

  ResolveComposerCacheForRestoreSuccess(this.cache);

  @override
  List<Object?> get props => [cache, ...super.props];
}

class ResolveComposerCacheForRestoreFailure extends FeatureFailure {
  ResolveComposerCacheForRestoreFailure(Object exception)
      : super(exception: exception);
}
