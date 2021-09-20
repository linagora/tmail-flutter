import 'package:core/core.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_request.dart';

class MoveToMailboxSuccess extends UIState {
  final MoveRequest moveRequest;

  MoveToMailboxSuccess(this.moveRequest);

  @override
  List<Object?> get props => [moveRequest];
}

class MoveToMailboxFailure extends FeatureFailure {
  final exception;

  MoveToMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}