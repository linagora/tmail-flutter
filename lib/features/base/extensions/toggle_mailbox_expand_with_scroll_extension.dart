import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_category_tree_source_resolver.dart';

/// Expand actions for the folder trees that do not scroll the expanded item
/// into view by themselves.
///
/// Views built on the design system sidebar already handle that scrolling, so
/// they call the plain toggles of [BaseMailboxController] instead.
extension ToggleMailboxExpandWithScrollExtension on BaseMailboxController {
  void toggleMailboxFolderWithScroll(
    MailboxNode selectedMailboxNode,
    ScrollController scrollController,
    GlobalKey itemKey,
  ) {
    final newExpandMode = toggleMailboxFolder(selectedMailboxNode);
    if (newExpandMode == null) return;

    triggerScrollWhenExpandFolder(newExpandMode, itemKey, scrollController);
  }

  void toggleMailboxCategoriesWithScroll(
    MailboxCategories category,
    ScrollController scrollController,
    GlobalKey itemKey,
  ) {
    final newExpandMode = toggleMailboxCategories(category);
    final categoryIsAvailable = const MailboxSidebarCategoryTreeSourceResolver()
        .resolve(this)
        .any(
      (source) => source.category == category && source.isAvailable,
    );
    if (!categoryIsAvailable) return;

    triggerScrollWhenExpandFolder(newExpandMode, itemKey, scrollController);
  }
}
