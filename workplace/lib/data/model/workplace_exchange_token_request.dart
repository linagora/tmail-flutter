import 'package:json_annotation/json_annotation.dart';
import 'package:workplace/data/model/workplace_enums.dart';

part 'workplace_exchange_token_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class WorkplaceExchangeTokenRequest {
  final String idToken;
  final WorkplaceExchangeType exchangeType;

  const WorkplaceExchangeTokenRequest({
    required this.idToken,
    required this.exchangeType,
  });

  Map<String, dynamic> toJson() => _$WorkplaceExchangeTokenRequestToJson(this);
}