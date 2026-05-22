class AutoLoadMorePolicy {
  AutoLoadMorePolicy._();

  // <= 0 (not <= viewport) prevents loop on large screens where the first page
  // fills 1×–2× the viewport, leaving maxScrollExtent in range (0, viewport].
  static bool shouldAutoLoadMoreByScrollExtent(double maxScrollExtent) =>
      maxScrollExtent <= 0;

  // Strict < avoids a spurious load when estimated height equals viewport —
  // actual rendered height is usually larger than the 40 px/item estimate.
  static bool shouldAutoLoadMoreByEstimatedHeight(
    int totalHeight,
    int viewportHeight,
  ) =>
      totalHeight > 0 && totalHeight < viewportHeight;
}
