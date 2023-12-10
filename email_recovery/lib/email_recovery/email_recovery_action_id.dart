import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

@IdConverter()
class EmailRecoveryActionId with EquatableMixin {
  final Id id;

  EmailRecoveryActionId(this.id);
  
  @override
  List<Object?> get props => [id];
}