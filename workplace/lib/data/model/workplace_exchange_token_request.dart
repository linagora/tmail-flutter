import 'package:json_annotation/json_annotation.dart';

part 'workplace_exchange_token_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class WorkplaceExchangeTokenRequest {
  final String idToken;

  const WorkplaceExchangeTokenRequest({required this.idToken});

  Map<String, dynamic> toJson() => _$WorkplaceExchangeTokenRequestToJson(this);
}