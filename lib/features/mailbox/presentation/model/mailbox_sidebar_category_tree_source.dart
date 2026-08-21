import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_category.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

/// Describes one product category whose tree can participate in the sidebar.
///
/// The source deliberately contains only presentation state. The sidebar view
/// can therefore render and measure any registered category without knowing
/// product-specific category names.
class MailboxSidebarCategoryTreeSource {
  const MailboxSidebarCategoryTreeSource({
    required this.category,
    required this.roots,
    required this.isAvailable,
    required this.isExpanded,
    required this.isFolderCategory,
    required this.initialDepth,
  }) : assert(initialDepth >= 0, 'A sidebar tree depth cannot be negative');

  final MailboxCategories category;
  final List<MailboxNode> roots;
  final bool isAvailable;
  final bool isExpanded;
  final bool isFolderCategory;
  final int initialDepth;
}
