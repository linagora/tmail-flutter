import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class MarkAllAsUnreadSelectionAllEmailsLoading extends LoadingState {}

class MarkAllAsUnreadSelectionAllEmailsUpdating extends UIState {

  final int totalRead;
  final int countUnread;

  MarkAllAsUnreadSelectionAllEmailsUpdating({
    required this.totalRead,
    required this.countUnread
  });

  @override
  List<Object?> get props => [totalRead, countUnread];
}

class MarkAllAsUnreadSelectionAllEmailsAllSuccess extends UIActionState {

  MarkAllAsUnreadSelectionAllEmailsAllSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentMailboxState, currentEmailState);
}

class MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure extends UIActionState {

  final int countEmailsUnread;

  MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure(
    this.countEmailsUnread,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentMailboxState, currentEmailState);

  @override
  List<Object?> get props => [
    countEmailsUnread,
    ...super.props
  ];
}

class  MarkAllAsUnreadSelectionAllEmailsAllFailure extends FeatureFailure {}

class MarkAllAsUnreadSelectionAllEmailsFailure extends FeatureFailure {

  MarkAllAsUnreadSelectionAllEmailsFailure({
    dynamic exception
  }) : super(exception: exception);
}