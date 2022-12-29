
import 'package:equatable/equatable.dart';

class FCMSubscription with EquatableMixin {

  final String deviceId;
  final String subscriptionId;

  FCMSubscription(this.deviceId, this.subscriptionId);

  @override
  List<Object?> get props => [
    deviceId,
    subscriptionId
  ];
}