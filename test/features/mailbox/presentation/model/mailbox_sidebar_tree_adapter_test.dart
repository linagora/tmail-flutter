import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
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

  test('preserves the sidebar ID when a mailbox node is copied', () {
    final node = _mailboxNode();
    final idBeforeCopy = flatten([node]).single.id;

    final copiedNode = node.copyWith();

    expect(flatten([copiedNode]).single.id, equals(idBeforeCopy));
  });

  test('preserves the sidebar ID across mailbox node state changes', () {
    final node = _mailboxNode();
    final idBeforeStateChange = flatten([node]).single.id;

    expect(
      flatten([node.toggleSelectMailboxNode()]).single.id,
      equals(idBeforeStateChange),
    );
    expect(
      flatten([
        node.toSelectedMailboxNode(selectMode: SelectMode.ACTIVE),
      ]).single.id,
      equals(idBeforeStateChange),
    );
  });

  test('still rejects a visible cycle', () {
    final node = MailboxNode(
      PresentationMailbox(MailboxId(Id('cycle'))),
      expandMode: ExpandMode.EXPAND,
    );
    node.addChildNode(node);

    expect(() => flatten([node]), throwsArgumentError);
  });
}

MailboxNode _mailboxNode({String? namespace}) => MailboxNode(
  PresentationMailbox(
    MailboxId(Id('same-server-id')),
    namespace: namespace == null ? null : Namespace(namespace),
  ),
);
