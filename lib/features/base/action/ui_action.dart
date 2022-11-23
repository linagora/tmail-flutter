
import 'package:equatable/equatable.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

abstract class Action with EquatableMixin {}

abstract class UIAction extends Action {}

abstract class FcmAction extends Action {}

abstract class FcmStateChangeAction extends FcmAction {
  final TypeName typeName;
  final jmap.State newState;

  FcmStateChangeAction(this.typeName, this.newState);
}