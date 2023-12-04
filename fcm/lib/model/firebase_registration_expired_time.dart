
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';

class FirebaseRegistrationExpiredTime with EquatableMixin {

  final UTCDate value;

  FirebaseRegistrationExpiredTime(this.value);

  @override
  List<Object?> get props => [value];
}