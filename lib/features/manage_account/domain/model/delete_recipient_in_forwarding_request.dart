import 'package:equatable/equatable.dart';
import 'package:forward/forward/tmail_forward.dart';

class DeleteRecipientInForwardingRequest with EquatableMixin {
  final TMailForward currentForward;
  final Set<String> listRecipientDeleted;

  DeleteRecipientInForwardingRequest({
    required this.currentForward,
    required this.listRecipientDeleted,
  });

  TMailForward get newTMailForward {
    final newListRecipients = currentForward.forwards
        .where((recipient) => !listRecipientDeleted.contains(recipient))
        .toSet();

    return currentForward.copyWith(forwards: newListRecipients);
  }

  @override
  List<Object?> get props => [currentForward, listRecipientDeleted];
}