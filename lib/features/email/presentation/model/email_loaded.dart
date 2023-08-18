import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';

class EmailLoaded with EquatableMixin {
  final String htmlContent;
  final List<Attachment> attachments;
  final Email? emailCurrent;

  EmailLoaded({
    required this.htmlContent,
    required this.attachments,
    this.emailCurrent,
  });

  @override
  List<Object?> get props => [
    htmlContent,
    attachments,
    emailCurrent
  ];
}
