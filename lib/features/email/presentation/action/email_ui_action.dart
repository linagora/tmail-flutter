
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class EmailUIAction extends UIAction {
  static final idle = EmailUIAction();

  EmailUIAction() : super();

  @override
  List<Object?> get props => [];
}

class RefreshChangeEmailAction extends EmailUIAction {
  final jmap.State? newState;

  RefreshChangeEmailAction(this.newState);

  @override
  List<Object?> get props => [newState];
}