import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/read_actions.dart';

class LoadingMarkAsMultipleEmailReadAll extends UIState {}

class MarkAsMultipleEmailReadAllSuccess extends UIState {
  final int countMarkAsReadSuccess;
  final ReadActions readActions;

  MarkAsMultipleEmailReadAllSuccess(
      this.countMarkAsReadSuccess,
      this.readActions,
  );

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

  MarkAsMultipleEmailReadHasSomeEmailFailure(
    this.countMarkAsReadSuccess,
    this.readActions,
  );

  @override
  List<Object?> get props => [countMarkAsReadSuccess, readActions];
}

class MarkAsMultipleEmailReadFailure extends FeatureFailure {
  final ReadActions readActions;

  MarkAsMultipleEmailReadFailure(this.readActions, dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [readActions, exception];
}