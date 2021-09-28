import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class GetAllMailboxSuccess extends UIState {
  final List<PresentationMailbox> defaultMailboxList;
  final List<PresentationMailbox> folderMailboxList;
  final State? currentMailboxState;

  GetAllMailboxSuccess({
    required this.defaultMailboxList,
    required this.folderMailboxList,
    required this.currentMailboxState
  });

  @override
  List<Object?> get props => [defaultMailboxList, folderMailboxList, currentMailboxState];
}

class GetAllMailboxFailure extends FeatureFailure {
  final exception;

  GetAllMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}