import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class SaveEmailAsDraftsLoading extends UIState {

  SaveEmailAsDraftsLoading();

  @override
  List<Object?> get props => [];
}

class SaveEmailAsDraftsSuccess extends UIActionState {

  final Email emailAsDrafts;

  SaveEmailAsDraftsSuccess(
    this.emailAsDrafts,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [];
}

class SaveEmailAsDraftsFailure extends FeatureFailure {
  final dynamic exception;

  SaveEmailAsDraftsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}