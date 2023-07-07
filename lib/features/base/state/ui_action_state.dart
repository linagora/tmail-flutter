
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

abstract class UIActionState extends UIState {

  final jmap.State? currentEmailState;
  final jmap.State? currentMailboxState;

  UIActionState(this.currentEmailState, this.currentMailboxState);

  @override
  List<Object?> get props => [currentEmailState, currentMailboxState];
}