import 'package:collection/collection.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';

extension ListLabelExtension on List<Label> {
  void sortByAlphabetically() {
    sortByCompare<Label>(
      (label) => label,
      (label, otherLabel) => label.compareAlphabetically(otherLabel),
    );
  }

  List<String> get displayNameNotNullList => map((label) => label.safeDisplayName)
      .where((name) => name.trim().isNotEmpty)
      .toList();

  List<String> getDisplayNameListWithoutSelectedLabel(Label selectedLabel) {
    return map((label) => label.safeDisplayName)
        .where((name) =>
            name.trim().isNotEmpty && name != selectedLabel.safeDisplayName)
        .toList();
  }
}
