import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

class GetComposerCacheInLocalStorageBrowserLoading extends LoadingState {}

class GetComposerCacheInLocalStorageBrowserSuccess extends UIState {

  final ComposerCache composerCache;

  GetComposerCacheInLocalStorageBrowserSuccess(this.composerCache);

  @override
  List<Object> get props => [composerCache];
}

class GetComposerCacheInLocalStorageBrowserFailure extends FeatureFailure {

  GetComposerCacheInLocalStorageBrowserFailure(dynamic exception) : super(exception: exception);
}