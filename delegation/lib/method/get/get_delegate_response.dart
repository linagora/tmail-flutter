import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_delegate_response.g.dart';

/// James sends no `state` for this method, so the base without a required state is used.
@JsonSerializable(converters: [IdConverter()], createToJson: false)
class GetDelegateResponse extends GetResponseNoAccountId<Delegate> {
  GetDelegateResponse(super.list, super.notFound);

  factory GetDelegateResponse.fromJson(Map<String, dynamic> json) =>
      _$GetDelegateResponseFromJson(json);

  static GetDelegateResponse deserialize(Map<String, dynamic> json) =>
      GetDelegateResponse.fromJson(json);

  @override
  List<Object?> get props => [list, notFound];
}
