
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/identities/identity_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/identities/signature_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'identity_request_dto.g.dart';

@IdentityIdNullableConverter()
@SignatureNullableConverter()
@JsonSerializable()
class IdentityRequestDto with EquatableMixin {

  @JsonKey(includeIfNull: false)
  final String? name;

  @JsonKey(includeIfNull: false)
  final Set<EmailAddress>? bcc;

  @JsonKey(includeIfNull: false)
  final Set<EmailAddress>? replyTo;

  @JsonKey(includeIfNull: false)
  final Signature? textSignature;

  @JsonKey(includeIfNull: false)
  final Signature? htmlSignature;

  IdentityRequestDto({
    this.name,
    this.bcc,
    this.replyTo,
    this.textSignature,
    this.htmlSignature,
  });

  factory IdentityRequestDto.fromJson(Map<String, dynamic> json) => _$IdentityRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$IdentityRequestDtoToJson(this);

  @override
  List<Object?> get props => [
    name,
    bcc,
    replyTo,
    textSignature,
    htmlSignature,
  ];
}