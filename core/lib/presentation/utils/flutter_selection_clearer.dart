import 'package:flutter/widgets.dart';

/// Clears the selection of the [SelectableRegion] enclosing a context.
class FlutterSelectionClearer {
  FlutterSelectionClearer._();

  /// Returns true when a [SelectableRegion] was found and cleared.
  static bool clearSelectableRegionOf(BuildContext context) {
    final selectableRegion = context
        .findAncestorStateOfType<SelectableRegionState>();
    if (selectableRegion == null) {
      return false;
    }

    selectableRegion.hideToolbar();
    selectableRegion.clearSelection();
    FocusManager.instance.primaryFocus?.unfocus();
    return true;
  }
}
