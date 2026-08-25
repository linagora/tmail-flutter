import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

final mailboxSidebarTreeAdapter = LinagoraSidebarTreeAdapter<MailboxNode>(
  childrenOf: (node) => node.childrenItems,
  idOf: (node) => (node.item.namespace?.value, node.item.id, node.sidebarTreeEntryId),
  isExpanded: (node) => node.hasChildren() && node.expandMode.isExpanded,
);
