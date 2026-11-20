import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:delegation/model/delegate.dart';

class GettingDelegates extends LoadingState {}

class GetDelegatesSuccess extends UIState {
  final List<Delegate> delegates;

  GetDelegatesSuccess(this.delegates);

  @override
  List<Object?> get props => [delegates];
}

class GetDelegatesFailure extends FeatureFailure {
  GetDelegatesFailure(Object? exception) : super(exception: exception);
}
