import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workplace_exchange_token_response.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class WorkplaceExchangeTokenResponse extends Equatable {
  final String? accessToken,
      clientId,
      clientSecret,
      refreshToken,
      registrationAccessToken,
      scope,
      tokenType;

  const WorkplaceExchangeTokenResponse({
    this.accessToken,
    this.clientId,
    this.clientSecret,
    this.refreshToken,
    this.registrationAccessToken,
    this.scope,
    this.tokenType,
  });

  factory WorkplaceExchangeTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceExchangeTokenResponseFromJson(json);

  @override
  List<Object?> get props => [
    accessToken,
    clientId,
    clientSecret,
    refreshToken,
    registrationAccessToken,
    scope,
    tokenType,
  ];
}
