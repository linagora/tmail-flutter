import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class RefreshChangesAllMailboxLoading extends LoadingState {}

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

  RefreshChangesAllMailboxFailure(dynamic exception) : super(exception: exception);
}