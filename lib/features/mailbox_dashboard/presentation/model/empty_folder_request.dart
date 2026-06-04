import 'package:model/mailbox/presentation_mailbox.dart';

class EmptyFolderRequest {
  final PresentationMailbox mailbox;

  // Explicit routing key set at the trigger point — not inferred from mailbox
  // properties — so routing works for folders with or without a role.
  final String tag;

  const EmptyFolderRequest({required this.mailbox, required this.tag});
}
