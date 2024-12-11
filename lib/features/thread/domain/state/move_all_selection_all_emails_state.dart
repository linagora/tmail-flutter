import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class MoveAllSelectionAllEmailsLoading extends LoadingState {}

class MoveAllSelectionAllEmailsUpdating extends UIState {

  final int total;
  final int countMoved;

  MoveAllSelectionAllEmailsUpdating({
    required this.total,
    required this.countMoved
  });

  @override
  List<Object?> get props => [total, countMoved];
}

class MoveAllSelectionAllEmailsAllSuccess extends UIActionState {
  final String destinationPath;

  MoveAllSelectionAllEmailsAllSuccess(
    this.destinationPath,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    destinationPath,
    ...super.props
  ];
}

class MoveAllSelectionAllEmailsHasSomeEmailFailure extends UIActionState {
  final String destinationPath;
  final int countEmailsMoved;

  MoveAllSelectionAllEmailsHasSomeEmailFailure(
    this.destinationPath,
    this.countEmailsMoved,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    countEmailsMoved,
    destinationPath,
    ...super.props
  ];
}

class MoveAllSelectionAllEmailsAllFailure extends FeatureFailure {
  final String destinationPath;

  MoveAllSelectionAllEmailsAllFailure(this.destinationPath);

  @override
  List<Object?> get props => [destinationPath];
}

class MoveAllSelectionAllEmailsFailure extends FeatureFailure {

  final String destinationPath;

  MoveAllSelectionAllEmailsFailure({
    required this.destinationPath,
    dynamic exception
  }) : super(exception: exception);

  @override
  List<Object?> get props => [destinationPath, ...super.props];
}