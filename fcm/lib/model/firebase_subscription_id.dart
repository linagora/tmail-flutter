
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

class FirebaseSubscriptionId with EquatableMixin {

  final Id id;

  FirebaseSubscriptionId(this.id);

  @override
  List<Object?> get props => [id];
}