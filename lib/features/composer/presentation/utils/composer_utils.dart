
import 'dart:collection';

class ComposerUtils {
  static const double normalWidth = 725;
  static const double normalHeight = 525;
  static const double minimizeWidth = 400;
  static const double minimizeHeight = 52;
  static const double composerExpandMoreButtonMaxWidth = 130;

  static int calculateNormalAndMinimizeWidgets(double width, int countNormalWidgets) {
    double remainingWidth = width - (countNormalWidgets * normalWidth);
    if (remainingWidth < 0) return countNormalWidgets;
    int countWidgets = countNormalWidgets + (remainingWidth / minimizeWidth).floor();
    return countWidgets;
  }

  static int calculateNormalWidgets(double width) => (width / normalWidth).floor();

  static int calculateMinimizeWidgets(double width) => (width / minimizeWidth).floor();

  static ({
  String? previousTargetId,
  String? targetId,
  String? nextTargetId,
  }) findSurroundingElements(Queue<String> queue, String targetId) {
    var ids = queue.toList(),
        index = ids.indexOf(targetId);

    return index == -1
      ? (previousTargetId: null, targetId: null, nextTargetId: null)
      : (
          previousTargetId: index > 0 ? ids[index - 1] : null,
          targetId: ids[index],
          nextTargetId: index < ids.length - 1 ? ids[index + 1] : null
        );
  }
}