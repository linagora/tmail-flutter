import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_collection.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_tree_adapter.dart';

mixin MailboxSidebarTreeLayoutMixin on BaseMailboxController {
  final mailboxSidebarTreeProjection =
      LinagoraSidebarTreeProjection<MailboxNode>(
    layoutPolicy: LinagoraSidebarTreeLayoutPolicy(
      adapter: mailboxSidebarTreeAdapter,
    ),
  );
  final mailboxSidebarTreeLayoutRevision = 0.obs;

  void invalidateMailboxSidebarTreeLayout() {
    mailboxSidebarTreeLayoutRevision.value++;
  }

  @override
  void updateMailboxTree({
    required MailboxCollection mailboxCollection,
    bool isRefreshTrigger = true,
  }) {
    super.updateMailboxTree(
      mailboxCollection: mailboxCollection,
      isRefreshTrigger: isRefreshTrigger,
    );
    invalidateMailboxSidebarTreeLayout();
  }

  @override
  ExpandMode? toggleMailboxFolder(MailboxNode selectedMailboxNode) {
    final newExpandMode = super.toggleMailboxFolder(selectedMailboxNode);
    if (newExpandMode != null) invalidateMailboxSidebarTreeLayout();

    return newExpandMode;
  }

  @override
  ExpandMode toggleMailboxCategories(MailboxCategories category) {
    final newExpandMode = super.toggleMailboxCategories(category);
    invalidateMailboxSidebarTreeLayout();

    return newExpandMode;
  }
}
