
import 'package:equatable/equatable.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

abstract class Action with EquatableMixin {}

abstract class UIAction extends Action {}

abstract class PushNotificationStateChangeAction extends Action {
  final TypeName typeName;
  final jmap.State newState;

  PushNotificationStateChangeAction(this.typeName, this.newState);
}