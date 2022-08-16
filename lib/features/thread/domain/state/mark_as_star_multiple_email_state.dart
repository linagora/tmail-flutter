import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

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
  List<Object?> get props => [countMarkStarSuccess, markStarAction];
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
  List<Object> get props => [countMarkStarSuccess, markStarAction];
}

class MarkAsStarMultipleEmailFailure extends FeatureFailure {
  final dynamic exception;
  final MarkStarAction markStarAction;

  MarkAsStarMultipleEmailFailure(this.exception, this.markStarAction);

  @override
  List<Object> get props => [exception, markStarAction];
}