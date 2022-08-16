
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class UIActionState extends UIState {

  jmap.State? currentEmailState;
  jmap.State? currentMailboxState;

  UIActionState(this.currentEmailState, this.currentMailboxState);

  @override
  List<Object?> get props => [currentEmailState, currentMailboxState];
}