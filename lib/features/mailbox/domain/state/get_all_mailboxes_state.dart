import 'package:core/core.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class GetAllMailboxSuccess extends UIState {
  final List<PresentationMailbox> defaultMailboxList;
  final List<PresentationMailbox> folderMailboxList;

  GetAllMailboxSuccess({required this.defaultMailboxList, required this.folderMailboxList});

  @override
  List<Object> get props => [folderMailboxList];
}

class GetAllMailboxFailure extends FeatureFailure {
  final exception;

  GetAllMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}