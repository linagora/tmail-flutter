import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

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

class MoveAllSelectionAllEmailsAllSuccess extends UIState {
  final String destinationPath;

  MoveAllSelectionAllEmailsAllSuccess(this.destinationPath);

  @override
  List<Object?> get props => [destinationPath];
}

class MoveAllSelectionAllEmailsHasSomeEmailFailure extends UIState {
  final String destinationPath;
  final int countEmailsMoved;

  MoveAllSelectionAllEmailsHasSomeEmailFailure(
    this.destinationPath,
    this.countEmailsMoved,
  );

  @override
  List<Object?> get props => [
    countEmailsMoved,
    destinationPath,
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