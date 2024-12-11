import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

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

class MarkAllAsStarredSelectionAllEmailsAllSuccess extends UIActionState {

  MarkAllAsStarredSelectionAllEmailsAllSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentMailboxState, currentEmailState);
}

class MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure extends UIActionState {

  final int countStarred;

  MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure(
    this.countStarred,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentMailboxState, currentEmailState);

  @override
  List<Object?> get props => [
    countStarred,
    ...super.props
  ];
}

class  MarkAllAsStarredSelectionAllEmailsAllFailure extends FeatureFailure {}

class MarkAllAsStarredSelectionAllEmailsFailure extends FeatureFailure {

  MarkAllAsStarredSelectionAllEmailsFailure({
    dynamic exception
  }) : super(exception: exception);
}