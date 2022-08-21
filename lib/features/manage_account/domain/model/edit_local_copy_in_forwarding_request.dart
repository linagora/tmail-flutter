import 'package:equatable/equatable.dart';
import 'package:forward/forward/tmail_forward.dart';

class EditLocalCopyInForwardingRequest with EquatableMixin {
  final TMailForward currentForward;
  final bool keepLocalCopy;

  EditLocalCopyInForwardingRequest({
    required this.currentForward,
    required this.keepLocalCopy,
  });

  TMailForward get newTMailForward {
    return currentForward.copyWith(localCopy: keepLocalCopy);
  }

  @override
  List<Object?> get props => [currentForward, keepLocalCopy];
}