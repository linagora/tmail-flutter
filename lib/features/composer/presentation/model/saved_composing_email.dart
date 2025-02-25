import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/email/attachment.dart';

part 'saved_composing_email.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class SavedComposingEmail with EquatableMixin {
  final String content;
  final String subject;
  final Set<EmailAddress> toRecipients;
  final Set<EmailAddress> ccRecipients;
  final Set<EmailAddress> bccRecipients;
  final Set<EmailAddress> replyToRecipients;
  final List<Attachment> attachments;
  final Identity? identity;
  final bool hasReadReceipt;
  final bool isMarkAsImportant;

  SavedComposingEmail({
    required this.content,
    required this.subject,
    required this.toRecipients,
    required this.ccRecipients,
    required this.bccRecipients,
    required this.replyToRecipients,
    required this.attachments,
    required this.identity,
    required this.hasReadReceipt,
    this.isMarkAsImportant = false,
  });

  factory SavedComposingEmail.fromJson(Map<String, dynamic> json) => _$SavedComposingEmailFromJson(json);

  Map<String, dynamic> toJson() => _$SavedComposingEmailToJson(this);

  String asString() => jsonEncode(toJson());

  factory SavedComposingEmail.empty() {
    return SavedComposingEmail(
      subject: '',
      content: '',
      toRecipients: {},
      ccRecipients: {},
      bccRecipients: {},
      replyToRecipients: {},
      attachments: [],
      identity: null,
      hasReadReceipt: false,
    );
  }

  @override
  List<Object?> get props => [
    content,
    subject,
    toRecipients,
    ccRecipients,
    bccRecipients,
    replyToRecipients,
    attachments,
    identity,
    hasReadReceipt,
    isMarkAsImportant,
  ];
}