import 'package:core/presentation/state/failure.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:model/email/mark_star_action.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class MarkAsStarEmailSuccess extends UIActionState {
  final MarkStarAction markStarAction;

  MarkAsStarEmailSuccess(
    this.markStarAction,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [markStarAction, ...super.props];
}

class MarkAsStarEmailFailure extends FeatureFailure {
  final MarkStarAction markStarAction;

  MarkAsStarEmailFailure(this.markStarAction, {dynamic exception}) : super(exception: exception);

  @override
  List<Object?> get props => [markStarAction, ...super.props];
}