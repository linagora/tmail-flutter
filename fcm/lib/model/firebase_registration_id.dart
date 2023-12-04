
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

class FirebaseRegistrationId with EquatableMixin {

  final Id id;

  FirebaseRegistrationId(this.id);

  @override
  List<Object?> get props => [id];
}