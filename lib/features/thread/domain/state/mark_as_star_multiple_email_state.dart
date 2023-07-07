import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:model/email/mark_star_action.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class LoadingMarkAsStarMultipleEmailAll extends UIState {}

class MarkAsStarMultipleEmailAllSuccess extends UIActionState {
  final int countMarkStarSuccess;
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailAllSuccess(
    this.countMarkStarSuccess,
    this.markStarAction,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [countMarkStarSuccess, markStarAction, ...super.props];
}

class MarkAsStarMultipleEmailAllFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailAllFailure(this.markStarAction);

  @override
  List<Object> get props => [markStarAction];
}

class MarkAsStarMultipleEmailHasSomeEmailFailure extends UIActionState {
  final int countMarkStarSuccess;
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailHasSomeEmailFailure(
    this.countMarkStarSuccess,
    this.markStarAction,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [countMarkStarSuccess, markStarAction, ...super.props];
}

class MarkAsStarMultipleEmailFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailFailure(this.markStarAction, dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [markStarAction, exception];
}