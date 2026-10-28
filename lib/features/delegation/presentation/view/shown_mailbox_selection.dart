/// Removed once the dashboard selection moves to Riverpod.
abstract interface class ShownMailboxSelection {
  bool get hasOpenComposer;

  void clearSelectionAndSearch();
}
