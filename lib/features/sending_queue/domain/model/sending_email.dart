import 'dart:convert';

import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:jmap_dart_client/http/converter/email_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/identities/identity_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/mailbox_id_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';

class SendingEmail with EquatableMixin {
  final String sendingId;
  final Email email;
  final MailboxId? sentMailboxId;
  final EmailId? emailIdDestroyed;
  final EmailId? emailIdAnsweredOrForwarded;
  final IdentityId? identityId;
  final EmailActionType emailActionType;
  final DateTime createTime;
  final SelectMode selectMode;
  final SendingState sendingState;
  final EmailId? previousEmailId;

  SendingEmail({
    required this.sendingId,
    required this.email,
    required this.emailActionType,
    required this.createTime,
    this.sentMailboxId,
    this.emailIdDestroyed,
    this.emailIdAnsweredOrForwarded,
    this.identityId,
    this.selectMode = SelectMode.INACTIVE,
    this.sendingState = SendingState.waiting,
    this.previousEmailId,
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
    writeNotNull('previousEmailId', const EmailIdNullableConverter().toJson(previousEmailId));

    return val;
  }

  PresentationEmail get presentationEmail => email.sendingEmailToPresentationEmail();

  String getCreateTimeAt(String newLocale) {
    return DateFormat(createTime.toPattern(), newLocale).format(createTime);
  }

  factory SendingEmail.fromJson(Map<String, dynamic> json) {
    return SendingEmail(
      sendingId: json['sendingId'] as String,
      email: Email.fromJson(jsonDecode(json['email'])),
      emailActionType: _getEmailActionType(json['emailActionType'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
      sentMailboxId: const MailboxIdNullableConverter().fromJson(json['sentMailboxId'] as String?),
      emailIdDestroyed: const EmailIdNullableConverter().fromJson(json['emailIdDestroyed'] as String?),
      emailIdAnsweredOrForwarded: const EmailIdNullableConverter().fromJson(json['emailIdAnsweredOrForwarded'] as String?),
      identityId: const IdentityIdNullableConverter().fromJson(json['identityId'] as String?),
      previousEmailId: const EmailIdNullableConverter().fromJson(json['previousEmailId'] as String?),
    );
  }

  static EmailActionType _getEmailActionType(String value) {
    return EmailActionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => throw ArgumentError('Invalid email action type: $value'),
    );
  }

  bool get isSelected => selectMode == SelectMode.ACTIVE;

  bool get isWaiting => sendingState == SendingState.waiting;

  bool get isError => sendingState == SendingState.error;

  bool get isSuccess => sendingState == SendingState.success;

  bool get isCanceled => sendingState == SendingState.canceled;

  bool get isRunning => sendingState == SendingState.running;

  bool get isEditableSupported {
    if (PlatformInfo.isAndroid) {
      return isWaiting || isRunning || isCanceled;
    } else if (PlatformInfo.isIOS) {
      return isWaiting || isCanceled;
    } else {
      return false;
    }
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
    selectMode,
    sendingState,
    previousEmailId,
  ];
}