import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_category_tree_source.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_visible_tree_resolver.dart';

void main() {
  const resolver = MailboxSidebarVisibleTreeResolver();

  group('MailboxSidebarVisibleTreeResolver', () {
    test('keeps only the default tree when the folders section is collapsed', () {
      final exchangeNode = _node('exchange');
      final personalNode = _node('personal');
      final teamNode = _node('team');

      final trees = resolver.resolve(
        foldersExpanded: false,
        sources: [
          _source(
            category: MailboxCategories.exchange,
            roots: [exchangeNode],
          ),
          _source(
            category: MailboxCategories.personalFolders,
            roots: [personalNode],
          ),
          _source(
            category: MailboxCategories.teamMailboxes,
            roots: [teamNode],
          ),
        ],
      ).toList();

      expect(trees, hasLength(1));
      expect(trees.single.roots, [exchangeNode]);
      expect(trees.single.initialDepth, 0);
    });

    test('ignores an unavailable category even when it has roots', () {
      final exchangeNode = _node('exchange');
      final personalNode = _node('personal');

      final trees = resolver.resolve(
        foldersExpanded: true,
        sources: [
          _source(
            category: MailboxCategories.exchange,
            roots: [exchangeNode],
          ),
          _source(
            category: MailboxCategories.personalFolders,
            roots: [personalNode],
            isAvailable: false,
          ),
        ],
      ).toList();

      expect(trees, hasLength(1));
      expect(trees.single.roots, [exchangeNode]);
    });

    test('ignores a collapsed folder category while keeping expanded categories', () {
      final personalNode = _node('personal');
      final teamNode = _node('team');

      final trees = resolver.resolve(
        foldersExpanded: true,
        sources: [
          _source(
            category: MailboxCategories.personalFolders,
            roots: [personalNode],
            isExpanded: false,
          ),
          _source(
            category: MailboxCategories.teamMailboxes,
            roots: [teamNode],
          ),
        ],
      ).toList();

      expect(trees, hasLength(1));
      expect(trees.single.roots, [teamNode]);
      expect(trees.single.initialDepth, 1);
    });

    test('keeps every expanded source in registration order and depth', () {
      final exchangeNode = _node('exchange');
      final personalNode = _node('personal');
      final teamNode = _node('team');

      final trees = resolver.resolve(
        foldersExpanded: true,
        sources: [
          _source(
            category: MailboxCategories.exchange,
            roots: [exchangeNode],
          ),
          _source(
            category: MailboxCategories.personalFolders,
            roots: [personalNode],
          ),
          _source(
            category: MailboxCategories.teamMailboxes,
            roots: [teamNode],
          ),
        ],
      ).toList();

      expect(trees.map((tree) => tree.roots.single), [
        exchangeNode,
        personalNode,
        teamNode,
      ]);
      expect(trees.map((tree) => tree.initialDepth), [0, 1, 1]);
    });
  });
}

MailboxSidebarCategoryTreeSource _source({
  required MailboxCategories category,
  required List<MailboxNode> roots,
  bool isExpanded = true,
  bool isAvailable = true,
}) {
  final isFolderCategory = category != MailboxCategories.exchange;

  return MailboxSidebarCategoryTreeSource(
      category: category,
      roots: roots,
      isAvailable: isAvailable,
      isExpanded: isExpanded,
      isFolderCategory: isFolderCategory,
      initialDepth: isFolderCategory ? 1 : 0,
    );
}

MailboxNode _node(String value) => MailboxNode(
  PresentationMailbox(MailboxId(Id(value))),
);
