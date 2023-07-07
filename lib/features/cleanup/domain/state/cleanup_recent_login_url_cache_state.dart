import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class CleanupRecentLoginUrlCacheSuccess extends UIState {}

class CleanupRecentLoginUrlCacheFailure extends FeatureFailure {

  CleanupRecentLoginUrlCacheFailure(dynamic exception) : super(exception: exception);
}