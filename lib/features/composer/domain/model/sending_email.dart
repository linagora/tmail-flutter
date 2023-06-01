
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:jmap_dart_client/http/converter/email_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/identities/identity_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/mailbox_id_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_extension.dart';

class SendingEmail with EquatableMixin {
  final String sendingId;
  final Email email;
  final MailboxId? sentMailboxId;
  final EmailId? emailIdDestroyed;
  final EmailId? emailIdAnsweredOrForwarded;
  final IdentityId? identityId;
  final EmailActionType emailActionType;
  final MailboxName? mailboxNameRequest;
  final Id? creationIdRequest;
  final DateTime createTime;

  SendingEmail({
    required this.sendingId,
    required this.email,
    required this.emailActionType,
    required this.createTime,
    this.sentMailboxId,
    this.emailIdDestroyed,
    this.emailIdAnsweredOrForwarded,
    this.identityId,
    this.mailboxNameRequest,
    this.creationIdRequest
  });

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('sendingId', sendingId);
    writeNotNull('email', email.asString());
    writeNotNull('emailActionType', emailActionType.name);
    writeNotNull('createTime', createTime.toIso8601String());
    writeNotNull('sentMailboxId', const MailboxIdNullableConverter().toJson(sentMailboxId));
    writeNotNull('emailIdDestroyed', const EmailIdNullableConverter().toJson(emailIdDestroyed));
    writeNotNull('emailIdAnsweredOrForwarded', const EmailIdNullableConverter().toJson(emailIdAnsweredOrForwarded));
    writeNotNull('identityId', const IdentityIdNullableConverter().toJson(identityId));
    writeNotNull('mailboxNameRequest', mailboxNameRequest?.name);
    writeNotNull('creationIdRequest', const IdNullableConverter().toJson(creationIdRequest));

    return val;
  }

  PresentationEmail get presentationEmail => email.toPresentationEmail();

  String getCreateTimeAt(String newLocale) {
    return DateFormat(createTime.toPattern(), newLocale).format(createTime);
  }

  @override
  List<Object?> get props => [
    sendingId,
    email,
    emailActionType,
    createTime,
    sentMailboxId,
    emailIdDestroyed,
    emailIdAnsweredOrForwarded,
    identityId,
    mailboxNameRequest,
    creationIdRequest
  ];
}