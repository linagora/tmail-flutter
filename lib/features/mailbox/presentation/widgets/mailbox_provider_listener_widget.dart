import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_delete_trash_subfolders_listener_extension.dart';

class MailboxProviderListenerWidget extends ConsumerWidget {
  final Widget child;

  const MailboxProviderListenerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenDeleteTrashSubfolders(context, ref);
    return child;
  }
}
