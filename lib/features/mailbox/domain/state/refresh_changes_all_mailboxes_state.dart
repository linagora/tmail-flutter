import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class RefreshChangesAllMailboxSuccess extends UIState {
  final List<PresentationMailbox> mailboxList;
  final State? currentMailboxState;

  RefreshChangesAllMailboxSuccess({
    required this.mailboxList,
    required this.currentMailboxState
  });

  @override
  List<Object?> get props => [mailboxList, currentMailboxState];
}

class RefreshChangesAllMailboxFailure extends FeatureFailure {
  final dynamic exception;

  RefreshChangesAllMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}