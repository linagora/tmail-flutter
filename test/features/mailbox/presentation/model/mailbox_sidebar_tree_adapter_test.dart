import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_tree_adapter.dart';

void main() {
  List<LinagoraSidebarTreeListEntry<MailboxNode>> flatten(
    List<MailboxNode> roots,
  ) {
    return LinagoraSidebarTreeFlattener.flatten(
      roots: roots,
      adapter: mailboxSidebarTreeAdapter,
    );
  }

  test('keeps identical mailbox IDs distinct across namespaces', () {
    final entries = flatten([
      _mailboxNode(namespace: 'Personal'),
      _mailboxNode(namespace: 'Team'),
    ]);

    expect(entries, hasLength(2));
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
  });

  test('keeps duplicate mailbox IDs in one tree from crashing flatten', () {
    final entries = flatten([
      _mailboxNode(namespace: 'Personal'),
      _mailboxNode(namespace: 'Personal'),
    ]);

    expect(entries, hasLength(2));
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
  });

  test('keeps duplicate mailbox IDs with a null namespace from crashing flatten',
      () {
    final entries = flatten([
      _mailboxNode(),
      _mailboxNode(),
    ]);

    expect(entries, hasLength(2));
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
  });
}

MailboxNode _mailboxNode({String? namespace}) => MailboxNode(
  PresentationMailbox(
    MailboxId(Id('same-server-id')),
    namespace: namespace == null ? null : Namespace(namespace),
  ),
);
