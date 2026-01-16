import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/jmap/core/method/response/changes_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'changes_label_response.g.dart';

@JsonSerializable(
  converters: [
    StateConverter(),
    AccountIdConverter(),
    IdConverter(),
  ],
  createToJson: false,
)
class ChangesLabelResponse extends ChangesResponse {
  ChangesLabelResponse(
    super.accountId,
    super.oldState,
    super.newState,
    super.hasMoreChanges,
    super.created,
    super.updated,
    super.destroyed,
  );

  factory ChangesLabelResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangesLabelResponseFromJson(json);

  static ChangesLabelResponse deserialize(Map<String, dynamic> json) {
    return ChangesLabelResponse.fromJson(json);
  }

  @override
  List<Object?> get props => [
        accountId,
        oldState,
        newState,
        hasMoreChanges,
        created,
        updated,
        destroyed,
      ];
}
