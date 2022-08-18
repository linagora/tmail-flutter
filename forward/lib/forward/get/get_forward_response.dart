import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_forward_response.g.dart';

@StateConverter()
@AccountIdConverter()
@IdConverter()
@JsonSerializable()
class GetForwardResponse extends GetResponse<TMailForward> {
  GetForwardResponse(AccountId accountId, State state, List<TMailForward> list, List<Id>? notFound) : super(accountId, state, list, notFound);

  factory GetForwardResponse.fromJson(Map<String, dynamic> json) => _$GetForwardResponseFromJson(json);

  static GetForwardResponse deserialize(Map<String, dynamic> json) {
    return GetForwardResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetForwardResponseToJson(this);

  @override
  List<Object?> get props => [accountId, state, list, notFound];
}