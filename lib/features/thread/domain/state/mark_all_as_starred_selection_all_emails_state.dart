import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class MarkAllAsStarredSelectionAllEmailsLoading extends LoadingState {}

class MarkAllAsStarredSelectionAllEmailsUpdating extends UIState {

  final int total;
  final int countStarred;

  MarkAllAsStarredSelectionAllEmailsUpdating({
    required this.total,
    required this.countStarred
  });

  @override
  List<Object?> get props => [total, countStarred];
}

class MarkAllAsStarredSelectionAllEmailsAllSuccess extends UIState {}

class MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure extends UIState {

  final int countStarred;

  MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure(this.countStarred);

  @override
  List<Object?> get props => [countStarred];
}

class MarkAllAsStarredSelectionAllEmailsFailure extends FeatureFailure {

  MarkAllAsStarredSelectionAllEmailsFailure({
    dynamic exception
  }) : super(exception: exception);
}