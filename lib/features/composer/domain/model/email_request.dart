
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class EmailRequest with EquatableMixin {

  final Email email;
  final Id submissionCreateId;
  final MailboxId? mailboxIdSaved;

  EmailRequest(this.email, this.submissionCreateId, {this.mailboxIdSaved});

  @override
  List<Object?> get props => [email, submissionCreateId, mailboxIdSaved];
}