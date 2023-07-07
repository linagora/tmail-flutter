import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class CleanupRecentLoginUsernameCacheSuccess extends UIState {}

class CleanupRecentLoginUsernameCacheFailure extends FeatureFailure {

  CleanupRecentLoginUsernameCacheFailure(dynamic exception) : super(exception: exception);
}