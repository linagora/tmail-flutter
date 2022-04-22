import 'package:core/core.dart';
import 'package:model/email/read_actions.dart';

class MarkAsMultipleEmailReadAllSuccess extends UIState {
  final int countMarkAsReadSuccess;
  final ReadActions readActions;

  MarkAsMultipleEmailReadAllSuccess(this.countMarkAsReadSuccess, this.readActions);

  @override
  List<Object?> get props => [countMarkAsReadSuccess, readActions];
}

class MarkAsMultipleEmailReadAllFailure extends FeatureFailure {
  final ReadActions readActions;

  MarkAsMultipleEmailReadAllFailure(this.readActions);

  @override
  List<Object> get props => [readActions];
}

class MarkAsMultipleEmailReadHasSomeEmailFailure extends UIState {
  final int countMarkAsReadSuccess;
  final ReadActions readActions;

  MarkAsMultipleEmailReadHasSomeEmailFailure(this.countMarkAsReadSuccess, this.readActions);

  @override
  List<Object> get props => [countMarkAsReadSuccess, readActions];
}

class MarkAsMultipleEmailReadFailure extends FeatureFailure {
  final dynamic exception;
  final ReadActions readActions;

  MarkAsMultipleEmailReadFailure(this.exception, this.readActions);

  @override
  List<Object> get props => [exception, readActions];
}