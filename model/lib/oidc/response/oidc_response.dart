
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/oidc/converter/uri_converter.dart';
import 'package:model/oidc/response/oidc_link_dto.dart';

part 'oidc_response.g.dart';

@UriConverter()
@JsonSerializable()
class OIDCResponse with EquatableMixin {

  final String subject;
  final List<OIDCLinkDto> links;

  OIDCResponse(this.subject, this.links);

  factory OIDCResponse.fromJson(Map<String, dynamic> json) => _$OIDCResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OIDCResponseToJson(this);

  @override
  List<Object?> get props => [subject, links];
}