import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/unsigned_int_extension.dart';

extension SortOrderExtension on SortOrder {
  int compareToSort(SortOrder sortOrder) => value.compareToSort(sortOrder.value);
}