import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_category_tree_source.dart';

class MailboxSidebarCategoryTreeSourceResolver {
  const MailboxSidebarCategoryTreeSourceResolver();

  List<MailboxSidebarCategoryTreeSource> resolve(
    BaseMailboxController controller,
  ) {
    final categoryExpandModes = controller.mailboxCategoriesExpandMode.value;

    return [
      MailboxSidebarCategoryTreeSource(
        category: MailboxCategories.exchange,
        roots: controller.defaultRootNode.childrenItems ?? const <MailboxNode>[],
        isAvailable: controller.defaultMailboxIsNotEmpty,
        isExpanded: true,
        isFolderCategory: false,
        initialDepth: 0,
      ),
      MailboxSidebarCategoryTreeSource(
        category: MailboxCategories.personalFolders,
        roots: controller.personalRootNode.childrenItems ?? const <MailboxNode>[],
        isAvailable: controller.personalMailboxIsNotEmpty,
        isExpanded: MailboxCategories.personalFolders
            .getExpandMode(categoryExpandModes)
            .isExpanded,
        isFolderCategory: true,
        initialDepth: 1,
      ),
      MailboxSidebarCategoryTreeSource(
        category: MailboxCategories.teamMailboxes,
        roots: controller.teamMailboxesRootNode.childrenItems ?? const <MailboxNode>[],
        isAvailable: controller.teamMailboxesIsNotEmpty,
        isExpanded: MailboxCategories.teamMailboxes
            .getExpandMode(categoryExpandModes)
            .isExpanded,
        isFolderCategory: true,
        initialDepth: 1,
      ),
    ];
  }
}
