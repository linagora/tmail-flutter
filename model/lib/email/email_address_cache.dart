
import 'package:core/data/local/config/email_address_table.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'email_address_cache.g.dart';

@JsonSerializable()
class EmailAddressCache with EquatableMixin {

  @JsonKey(name: EmailAddressTable.NAME)
  final String name;
  @JsonKey(name: EmailAddressTable.EMAIL)
  final String email;

  EmailAddressCache(this.name, this.email);

  factory EmailAddressCache.fromJson(Map<String, dynamic> json) => _$EmailAddressCacheFromJson(json);

  Map<String, dynamic> toJson() => _$EmailAddressCacheToJson(this);

  @override
  List<Object?> get props => [name, email];
}

extension EmailAddressCacheExtension on EmailAddressCache {
  EmailAddress toEmailAddress() => EmailAddress(name, email);
}