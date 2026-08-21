import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_category_tree_source.dart';

/// Selects the category trees that are currently visible in the mailbox
/// sidebar and adapts them for the design-system layout policy.
class MailboxSidebarVisibleTreeResolver {
  const MailboxSidebarVisibleTreeResolver();

  Iterable<LinagoraSidebarVisibleTree<MailboxNode>> resolve({
    required bool foldersExpanded,
    required Iterable<MailboxSidebarCategoryTreeSource> sources,
  }) sync* {
    for (final source in sources) {
      if (!_isVisible(source, foldersExpanded)) continue;

      yield LinagoraSidebarVisibleTree(
        roots: source.roots,
        initialDepth: source.initialDepth,
      );
    }
  }

  bool _isVisible(
    MailboxSidebarCategoryTreeSource source,
    bool foldersExpanded,
  ) {
    if (!source.isAvailable) return false;
    return !source.isFolderCategory ||
        (foldersExpanded && source.isExpanded);
  }
}
