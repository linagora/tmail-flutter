import 'package:core/core.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

class GetComposerCacheSuccess extends UIState {

  final ComposerCache composerCache;

  GetComposerCacheSuccess(this.composerCache);

  @override
  List<Object> get props => [composerCache];
}

class GetComposerCacheFailure extends FeatureFailure {
  final dynamic exception;

  GetComposerCacheFailure(this.exception);

  @override
  List<Object> get props => [exception];
}