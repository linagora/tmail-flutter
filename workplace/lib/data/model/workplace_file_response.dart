import 'package:json_annotation/json_annotation.dart';

part 'workplace_file_response.g.dart';

@JsonSerializable(createToJson: false)
class WorkplaceFileAttributesResponse {
  final String? name;

  const WorkplaceFileAttributesResponse({this.name});

  factory WorkplaceFileAttributesResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceFileAttributesResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class WorkplaceFileDataResponse {
  final String id;
  final WorkplaceFileAttributesResponse? attributes;

  const WorkplaceFileDataResponse({required this.id, this.attributes});

  factory WorkplaceFileDataResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceFileDataResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class WorkplaceFileResponse {
  final WorkplaceFileDataResponse data;

  const WorkplaceFileResponse({required this.data});

  factory WorkplaceFileResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceFileResponseFromJson(json);
}
