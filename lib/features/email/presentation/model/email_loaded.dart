import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';

class EmailLoaded with EquatableMixin {
  final String emailContent;
  final String emailContentDisplayed;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  EmailLoaded(
    this.emailContent,
    this.emailContentDisplayed,
    this.attachments,
    this.emailCurrent,
  );

  @override
  List<Object?> get props => [
    emailContent,
    emailContentDisplayed,
    attachments,
    emailCurrent
  ];
}
