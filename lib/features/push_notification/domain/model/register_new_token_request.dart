
import 'package:equatable/equatable.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

class RegisterNewTokenRequest with EquatableMixin {

  final Id createRequestId;
  final FirebaseRegistration firebaseRegistration;

  RegisterNewTokenRequest(this.createRequestId, this.firebaseRegistration);

  @override
  List<Object?> get props => [
    createRequestId,
    firebaseRegistration
  ];
}