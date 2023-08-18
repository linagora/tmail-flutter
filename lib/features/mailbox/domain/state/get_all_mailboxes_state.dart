import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class GetAllMailboxLoading extends LoadingState {}

class GetAllMailboxSuccess extends UIState {
  final List<PresentationMailbox> mailboxList;
  final State? currentMailboxState;

  GetAllMailboxSuccess({
    required this.mailboxList,
    required this.currentMailboxState
  });

  @override
  List<Object?> get props => [mailboxList, currentMailboxState];
}

class GetAllMailboxFailure extends FeatureFailure {

  GetAllMailboxFailure(dynamic exception) : super(exception: exception);
}