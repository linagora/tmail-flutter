import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class MarkAsStarEmailSuccess extends UIActionState {
  final Email updatedEmail;
  final MarkStarAction markStarAction;

  MarkAsStarEmailSuccess(
    this.updatedEmail,
    this.markStarAction,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [updatedEmail, markStarAction];
}

class MarkAsStarEmailFailure extends FeatureFailure {
  final dynamic exception;
  final MarkStarAction markStarAction;

  MarkAsStarEmailFailure(this.exception, this.markStarAction);

  @override
  List<Object> get props => [exception, markStarAction];
}