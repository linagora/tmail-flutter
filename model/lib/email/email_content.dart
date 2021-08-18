
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';

class EmailContent with EquatableMixin {

  final EmailId id;
  final Set<EmailBodyPart>? htmlBody;
  final Set<EmailBodyPart>? attachments;
  final Map<PartId, EmailBodyValue>? bodyValues;

  EmailContent(
    this.id,
    {
      this.htmlBody,
      this.attachments,
      this.bodyValues
    }
  );

  @override
  List<Object?> get props => [
    id,
    htmlBody,
    attachments,
    bodyValues
  ];
}