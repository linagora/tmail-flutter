import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_tree_adapter.dart';

void main() {
  test('keeps identical mailbox IDs distinct across namespaces', () {
    final entries = LinagoraSidebarTreeFlattener.flatten(
      roots: [
        _mailboxNode(namespace: 'Personal'),
        _mailboxNode(namespace: 'Team'),
      ],
      adapter: mailboxSidebarTreeAdapter,
    );

    expect(entries, hasLength(2));
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
  });
}

MailboxNode _mailboxNode({required String namespace}) => MailboxNode(
  PresentationMailbox(
    MailboxId(Id('same-server-id')),
    namespace: Namespace(namespace),
  ),
);
