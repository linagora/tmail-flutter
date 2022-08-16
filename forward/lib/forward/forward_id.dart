import 'package:equatable/equatable.dart';
import 'package:forward/forward/converter/forward_id_coverter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

enum ForwardIdType {
  singleton('singleton');

  const ForwardIdType(this.value);

  final String value;
}

class ForwardId with EquatableMixin {
  final Id id;

  ForwardId({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}

extension ForwardIdSingleton on ForwardId {
  static ForwardId get forwardIdSingleton => ForwardId(id: Id(ForwardIdType.singleton.value));
}
