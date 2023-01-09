
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class MailboxUIAction extends UIAction {
  static final idle = MailboxUIAction();

  MailboxUIAction() : super();

  @override
  List<Object?> get props => [];
}

class SelectMailboxDefaultAction extends MailboxUIAction {
  SelectMailboxDefaultAction();

  @override
  List<Object?> get props => [];
}

class RefreshChangeMailboxAction extends MailboxUIAction {
  final jmap.State? newState;

  RefreshChangeMailboxAction(this.newState);

  @override
  List<Object?> get props => [newState];
}