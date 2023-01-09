
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/email_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/state_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_payload.g.dart';

@EmailIdNullableConverter()
@StateNullableConverter()
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class NotificationPayload with EquatableMixin {

  final EmailId? emailId;
  final jmap.State? newState;

  NotificationPayload({this.emailId, this.newState});

  factory NotificationPayload.fromJson(Map<String, dynamic> json) => _$NotificationPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPayloadToJson(this);

  String get encodeToString => jsonEncode(toJson());

  @override
  List<Object?> get props => [emailId, newState];
}