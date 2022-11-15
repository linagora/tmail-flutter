
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';

class FirebaseExpiredTime with EquatableMixin {

  final UTCDate value;

  FirebaseExpiredTime(this.value);

  @override
  List<Object?> get props => [value];
}