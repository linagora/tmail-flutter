
import 'package:equatable/equatable.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_category.dart';

class MailboxCategoriesExpandMode with EquatableMixin {
  MailboxCategoriesExpandMode({
    required Map<MailboxCategories, ExpandMode> expandModes,
  }) : _expandModes = Map.unmodifiable({
         for (final category in MailboxCategories.values)
           category: expandModes[category] ?? ExpandMode.EXPAND,
       });

  final Map<MailboxCategories, ExpandMode> _expandModes;

  factory MailboxCategoriesExpandMode.initial() {
    return MailboxCategoriesExpandMode.all(ExpandMode.EXPAND);
  }

  factory MailboxCategoriesExpandMode.all(ExpandMode expandMode) {
    return MailboxCategoriesExpandMode(
      expandModes: {
        for (final category in MailboxCategories.values) category: expandMode,
      },
    );
  }

  ExpandMode getExpandMode(MailboxCategories category) =>
      _expandModes[category]!;

  MailboxCategoriesExpandMode withExpandMode(
    MailboxCategories category,
    ExpandMode expandMode,
  ) {
    return MailboxCategoriesExpandMode(
      expandModes: {..._expandModes, category: expandMode},
    );
  }

  @override
  List<Object?> get props => [
    for (final category in MailboxCategories.values) _expandModes[category],
  ];
}
