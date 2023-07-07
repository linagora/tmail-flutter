import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

class GetComposerCacheSuccess extends UIState {

  final ComposerCache composerCache;

  GetComposerCacheSuccess(this.composerCache);

  @override
  List<Object> get props => [composerCache];
}

class GetComposerCacheFailure extends FeatureFailure {

  GetComposerCacheFailure(dynamic exception) : super(exception: exception);
}