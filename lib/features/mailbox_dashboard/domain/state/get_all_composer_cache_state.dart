import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

class GetAllComposerCacheSuccess extends UIState {

  final List<ComposerCache> listComposerCache;

  GetAllComposerCacheSuccess(this.listComposerCache);

  @override
  List<Object> get props => [listComposerCache];
}

class GetAllComposerCacheFailure extends FeatureFailure {

  GetAllComposerCacheFailure(dynamic exception) : super(exception: exception);
}