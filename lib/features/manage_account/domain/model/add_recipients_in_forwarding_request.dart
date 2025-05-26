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
    final currentRecipients = currentForward.forwards ?? {};

    final updatedRecipients = {
      ...currentRecipients,
      ...listRecipientAdded,
    };

    return currentForward.copyWith(forwards: updatedRecipients);
  }

  @override
  List<Object?> get props => [currentForward, listRecipientAdded];
}