import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:labels/model/label.dart';

class GettingAllLabel extends LoadingState {}

class GetAllLabelSuccess extends UIState {
  final List<Label> labels;
  final State? newState;
  final AccountId accountId;

  GetAllLabelSuccess(this.labels, this.newState, this.accountId);

  @override
  List<Object?> get props => [labels, newState, accountId];
}

class GetAllLabelFailure extends FeatureFailure {
  final AccountId accountId;

  GetAllLabelFailure(dynamic exception, this.accountId) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, accountId];
}
