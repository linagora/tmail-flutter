import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class GetAllMailboxSuccess extends UIState {
  final List<Mailbox> mailboxList;

  GetAllMailboxSuccess(this.mailboxList);

  @override
  List<Object> get props => [mailboxList];
}

class GetAllMailboxFailure extends FeatureFailure {
  final exception;

  GetAllMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}