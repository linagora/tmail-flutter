
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/oidc/converter/uri_converter.dart';

part 'oidc_link_dto.g.dart';

@UriConverter()
@JsonSerializable()
class OIDCLinkDto with EquatableMixin {

  final Uri rel;
  final Uri href;

  OIDCLinkDto(this.rel, this.href);

  factory OIDCLinkDto.fromJson(Map<String, dynamic> json) => _$OIDCLinkDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OIDCLinkDtoToJson(this);

  @override
  List<Object?> get props => [rel, href];
}