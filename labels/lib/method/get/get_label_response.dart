import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:labels/labels.dart';

part 'get_label_response.g.dart';

@JsonSerializable(
  converters: [
    StateConverter(),
    AccountIdConverter(),
    IdConverter(),
  ],
)
class GetLabelResponse extends GetResponse<Label> {
  GetLabelResponse(super.accountId, super.state, super.list, super.notFound);

  factory GetLabelResponse.fromJson(Map<String, dynamic> json) =>
      _$GetLabelResponseFromJson(json);

  static GetLabelResponse deserialize(Map<String, dynamic> json) {
    return GetLabelResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetLabelResponseToJson(this);

  @override
  List<Object?> get props => [accountId, state, list, notFound];
}
