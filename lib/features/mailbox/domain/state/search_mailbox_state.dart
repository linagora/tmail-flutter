import 'package:core/core.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class SearchMailboxSuccess extends UIState {

  final List<PresentationMailbox> mailboxesSearched;

  SearchMailboxSuccess(this.mailboxesSearched);

  @override
  List<Object?> get props => [mailboxesSearched];
}

class SearchMailboxFailure extends FeatureFailure {
  final dynamic exception;

  SearchMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}