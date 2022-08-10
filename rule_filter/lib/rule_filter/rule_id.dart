import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

@IdConverter()
class RuleId with EquatableMixin {
  final Id id;

  RuleId({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}
