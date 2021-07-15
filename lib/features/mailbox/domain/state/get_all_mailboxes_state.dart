import 'package:core/core.dart';
import 'package:model/model.dart';

class GetAllMailboxViewState extends ViewState {
  final List<Mailbox> mailboxList;

  GetAllMailboxViewState(this.mailboxList);

  @override
  List<Object> get props => [mailboxList];
}

class GetAllMailboxFailure extends FeatureFailure {
  final exception;

  GetAllMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}