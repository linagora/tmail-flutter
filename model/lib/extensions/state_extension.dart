
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:model/model.dart';

extension StateExtension on State {
  StateDao toStateDao(StateType stateType) {
    return StateDao(stateType, value);
  }
}