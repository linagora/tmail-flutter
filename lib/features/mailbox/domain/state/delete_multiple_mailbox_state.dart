import 'package:core/presentation/state/failure.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class DeleteMultipleMailboxAllSuccess extends UIActionState {

  final List<MailboxId> listMailboxIdDeleted;

  DeleteMultipleMailboxAllSuccess(this.listMailboxIdDeleted, {
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [listMailboxIdDeleted];
}

class DeleteMultipleMailboxHasSomeSuccess extends UIActionState {

  final List<MailboxId> listMailboxIdDeleted;

  DeleteMultipleMailboxHasSomeSuccess(this.listMailboxIdDeleted, {
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [listMailboxIdDeleted];
}

class DeleteMultipleMailboxAllFailure extends FeatureFailure {

  DeleteMultipleMailboxAllFailure();

  @override
  List<Object> get props => [];
}

class DeleteMultipleMailboxFailure extends FeatureFailure {
  final dynamic exception;

  DeleteMultipleMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}