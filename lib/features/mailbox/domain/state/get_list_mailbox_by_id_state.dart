import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class GetListMailboxByIdLoading extends LoadingState {}

class GetListMailboxByIdSuccess extends UIState {
  final List<MailboxId> mailboxIds;

  GetListMailboxByIdSuccess(this.mailboxIds);

  @override
  List<Object?> get props => [mailboxIds];
}

class GetListMailboxByIdFailure extends FeatureFailure {

  GetListMailboxByIdFailure(dynamic exception) : super(exception: exception);
}