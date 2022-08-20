import 'package:equatable/equatable.dart';
import 'package:forward/forward/tmail_forward.dart';

class AddRecipientInForwardingRequest with EquatableMixin {
  final TMailForward currentForward;
  final Set<String> listRecipientAdded;

  AddRecipientInForwardingRequest({
    required this.currentForward,
    required this.listRecipientAdded,
  });

  TMailForward get newTMailForward {
    final newListRecipients = currentForward.forwards
        .where((recipient) => !listRecipientAdded.contains(recipient))
        .toSet();
    newListRecipients.addAll(listRecipientAdded);
    return currentForward.copyWith(forwards: newListRecipients);
  }

  @override
  List<Object?> get props => [currentForward, listRecipientAdded];
}