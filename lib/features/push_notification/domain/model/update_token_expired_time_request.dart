
import 'package:equatable/equatable.dart';
import 'package:fcm/model/firebase_registration_expired_time.dart';
import 'package:fcm/model/firebase_registration_id.dart';

class UpdateTokenExpiredTimeRequest with EquatableMixin {

  final FirebaseRegistrationId firebaseRegistrationId;
  final FirebaseRegistrationExpiredTime firebaseRegistrationExpiredTime;

  UpdateTokenExpiredTimeRequest(
    this.firebaseRegistrationId,
    this.firebaseRegistrationExpiredTime
  );

  @override
  List<Object?> get props => [
    firebaseRegistrationId,
    firebaseRegistrationExpiredTime
  ];
}