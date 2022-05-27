
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

  final String? name;
  final Set<EmailAddress>? bcc;
  final Set<EmailAddress>? replyTo;
  final Signature? textSignature;
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