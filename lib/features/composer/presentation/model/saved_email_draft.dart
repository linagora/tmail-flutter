import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/attachment.dart';

class SavedEmailDraft with EquatableMixin {
  final String content;
  final String subject;
  final Set<EmailAddress> toRecipients;
  final Set<EmailAddress> ccRecipients;
  final Set<EmailAddress> bccRecipients;
  final List<Attachment> attachments;
  final Identity? identity;
  final bool hasReadReceipt;

  SavedEmailDraft({
    required this.content,
    required this.subject,
    required this.toRecipients,
    required this.ccRecipients,
    required this.bccRecipients,
    required this.attachments,
    required this.identity,
    required this.hasReadReceipt,
  });
  
  @override
  List<Object?> get props => [
    content,
    subject,
    // Prevent identical Set<EmailAddress>
    {0: toRecipients},
    {1: ccRecipients},
    {2: bccRecipients},
    attachments,
    identity,
    hasReadReceipt
  ];
}