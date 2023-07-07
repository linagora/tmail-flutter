
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreMailboxStateToRefreshLoading extends UIState {}

class StoreMailboxStateToRefreshSuccess extends UIState {}

class StoreMailboxStateToRefreshFailure extends FeatureFailure {

  StoreMailboxStateToRefreshFailure(dynamic exception) : super(exception: exception);
}