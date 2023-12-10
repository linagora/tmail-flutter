import 'package:email_recovery/email_recovery/converter/status_converter.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:email_recovery/email_recovery/status.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:email_recovery/email_recovery/converter/email_recovery_action_id_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/http/converter/utc_date_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/unsigned_int_nullable_converter.dart';

part 'email_recovery_action.g.dart';

@EmailRecoveryActionIdConverter()
@UTCDateNullableConverter()
@UnsignedIntNullableConverter()
@StatusConverter()
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class EmailRecoveryAction with EquatableMixin {
  final EmailRecoveryActionId? id;
  final UTCDate? deletedBefore;
  final UTCDate? deletedAfter;
  final UTCDate? receivedBefore;
  final UTCDate? receivedAfter;
  final bool? hasAttachment;
  final String? subject;
  final String? sender;
  final List<String>? recipients;
  final UnsignedInt? successfulRestoreCount;
  final UnsignedInt? errorRestoreCount;
  final Status? status;

  EmailRecoveryAction({
    this.id,
    this.deletedBefore,
    this.deletedAfter,
    this.receivedBefore,
    this.receivedAfter,
    this.hasAttachment,
    this.subject,
    this.sender,
    this.recipients,
    this.successfulRestoreCount,
    this.errorRestoreCount,
    this.status,
  });

  factory EmailRecoveryAction.fromJson(Map<String, dynamic> json) =>
      _$EmailRecoveryActionFromJson(json);
  
  Map<String, dynamic> toJson() => _$EmailRecoveryActionToJson(this);

  EmailRecoveryAction copyWith({
    EmailRecoveryActionId? id,
    UTCDate? deletedBefore,
    UTCDate? deletedAfter,
    UTCDate? receivedBefore,
    UTCDate? receivedAfter,
    bool? hasAttachment,
    String? subject,
    String? sender,
    List<String>? recipients,
    UnsignedInt? successfulRestoreCount,
    UnsignedInt? errorRestoreCount,
    Status? status,
  }) {
    return EmailRecoveryAction(
      id: id ?? this.id,
      deletedBefore: deletedBefore ?? this.deletedBefore,
      deletedAfter: deletedAfter ?? this.deletedAfter,
      receivedBefore: receivedBefore ?? this.receivedBefore,
      receivedAfter: receivedAfter ?? this.receivedAfter,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      subject: subject ?? this.subject,
      sender: sender ?? this.sender,
      recipients: recipients ?? this.recipients,
      successfulRestoreCount: successfulRestoreCount ?? this.successfulRestoreCount,
      errorRestoreCount: errorRestoreCount ?? this.errorRestoreCount,
      status: status ?? this.status,
    );
  }

  List<Object?> get props => [
    id,
    deletedBefore,
    deletedAfter,
    receivedBefore,
    receivedAfter,
    hasAttachment,
    subject,
    sender,
    recipients,
    successfulRestoreCount,
    errorRestoreCount,
    status,
  ];
}