import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';

class EmailLoaded with EquatableMixin {
  final List<EmailContent> emailContents;
  final List<EmailContent> emailContentsDisplayed;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  EmailLoaded(
    this.emailContents,
    this.emailContentsDisplayed,
    this.attachments,
    this.emailCurrent,
  );

  @override
  List<Object?> get props => [
    emailContents,
    emailContentsDisplayed,
    attachments,
    emailCurrent
  ];
}
