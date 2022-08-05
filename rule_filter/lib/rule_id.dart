import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

enum RuleIdType {
  singleton('singleton');
  const RuleIdType(this.value);
  final String value;
}

@JsonSerializable()
@IdConverter()
class RuleId with EquatableMixin {
  final Id id;

  RuleId(this.id);

  @override
  List<Object?> get props => [id];
}

extension RuleIdSingleton on RuleId {
 static get ruleIdSingleton => RuleId(Id(RuleIdType.singleton.value));
}