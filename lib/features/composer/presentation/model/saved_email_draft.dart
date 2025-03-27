import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/email/attachment.dart';

part 'saved_email_draft.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class SavedEmailDraft with EquatableMixin {
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

  SavedEmailDraft({
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

  factory SavedEmailDraft.fromJson(Map<String, dynamic> json) => _$SavedEmailDraftFromJson(json);

  Map<String, dynamic> toJson() => _$SavedEmailDraftToJson(this);

  String asString() => jsonEncode(toJson());

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