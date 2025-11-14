import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'oidc_user_info.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OidcUserInfo with EquatableMixin {
  @JsonKey(name: 'sid')
  final String? id;

  final String? email;

  final String? sub;

  final String? name;

  @JsonKey(name: 'preferred_username')
  final String? preferredUsername;

  @JsonKey(name: 'given_name')
  final String? givenName;

  @JsonKey(name: 'family_name')
  final String? familyName;

  final String? workplaceFqdn;

  const OidcUserInfo({
    this.id,
    this.sub,
    this.name,
    this.preferredUsername,
    this.givenName,
    this.familyName,
    this.email,
    this.workplaceFqdn,
  });

  /// Factory for creating object from JSON
  factory OidcUserInfo.fromJson(Map<String, dynamic> json) =>
      _$OidcUserInfoFromJson(json);

  /// Convert object to JSON map
  Map<String, dynamic> toJson() => _$OidcUserInfoToJson(this);

  @override
  List<Object?> get props => [
        id,
        sub,
        name,
        preferredUsername,
        givenName,
        familyName,
        email,
        workplaceFqdn,
      ];
}
