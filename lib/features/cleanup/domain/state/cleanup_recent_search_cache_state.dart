import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class CleanupRecentSearchCacheSuccess extends UIState {}

class CleanupRecentSearchCacheFailure extends FeatureFailure {

  CleanupRecentSearchCacheFailure(dynamic exception) : super(exception: exception);
}