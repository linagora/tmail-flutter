import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_filter.g.dart';

@JsonSerializable()
class ContactFilter extends Filter {

  final String text;

  ContactFilter(this.text);

  factory ContactFilter.fromJson(Map<String, dynamic> json) =>
      _$ContactFilterFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ContactFilterToJson(this);

  @override
  List<Object?> get props => [text];
}