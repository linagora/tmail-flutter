
import 'package:equatable/equatable.dart';
import 'package:fcm/model/firebase_subscription.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

class RegisterNewTokenRequest with EquatableMixin {

  final Id createRequestId;
  final FirebaseSubscription firebaseSubscription;

  RegisterNewTokenRequest(this.createRequestId, this.firebaseSubscription);

  @override
  List<Object?> get props => [
    createRequestId,
    firebaseSubscription
  ];
}