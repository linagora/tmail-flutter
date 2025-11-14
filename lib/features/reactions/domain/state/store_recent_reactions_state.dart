import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreRecentReactionsLoading extends LoadingState {}

class StoreRecentReactionsSuccess extends UIState {}

class StoreRecentReactionsFailure extends FeatureFailure {
  StoreRecentReactionsFailure(dynamic exception) : super(exception: exception);
}
