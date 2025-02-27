import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/update_screen_display_mode_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ComposerManager extends GetxController {
  final RxMap<String, ComposerView> composers = <String, ComposerView>{}.obs;
  final Queue<String> composerIdsQueue = Queue<String>();

  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();

  void addComposer(ComposerArguments composerArguments) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    ComposerBindings(composerId: id, composerArguments: composerArguments).dependencies();

    composers[id] = ComposerView(key: Key(id), composerId: id);
    composerIdsQueue.add(id);

    _syncQueueIfNeeded();
  }

  void removeComposer(String id) {
    if (!composers.containsKey(id)) return;

    composerIdsQueue.remove(id);
    composers.remove(id);
    ComposerBindings(composerId: id).dispose();

    _syncQueueIfNeeded();
  }

  void _syncQueueIfNeeded() {
    if (currentContext != null && composerIdsQueue.isNotEmpty) {
      syncComposerStateWhenComposerQueueChanged(
        screenWidth: _responsiveUtils.getSizeScreenWidth(currentContext!),
      );
    }
  }

  ({
    String? previousTargetId,
    String? targetId,
    String? nextTargetId,
  }) findSurroundingComposerIds(String targetId) {
    var ids = composerIdsQueue.toList(),
        index = ids.indexOf(targetId);

    return index == -1
      ? (previousTargetId: null, targetId: null, nextTargetId: null)
      : (
          previousTargetId: index > 0 ? ids[index - 1] : null,
          targetId: ids[index],
          nextTargetId: index < ids.length - 1 ? ids[index + 1] : null
        );
  }

  String? findFirstNormalComposerIdInQueue() {
    return composerIdsQueue
      .toList()
      .reversed
      .firstWhereOrNull((id) => getComposerView(id).controller.isNormalScreen);
  }

  (
    double availableWidth,
    double totalWidth,
    Map<String, ComposerController> composerControllers
  ) _setUpDataToSyncComposerQueue({required double screenWidth}) {
    double totalWidth = 0;
    double countDisplayedComposer = 0;
    final composerControllers = <String, ComposerController>{};

    for (var id in composerIdsQueue) {
      final controller = getComposerView(id).controller;
      final composerWidth = controller.composerWidth;
      if (!controller.isHiddenScreen) {
        countDisplayedComposer++;
      }
      composerControllers[id] = controller;
      totalWidth += composerWidth;
    }

    final availableWidth = screenWidth
      - ComposerStyle.composerExpandMoreButtonMaxWidth
      - ComposerStyle.padding * 3
      - (countDisplayedComposer - 1) * ComposerStyle.space;

    return (
      availableWidth,
      totalWidth,
      composerControllers,
    );
  }

  void syncComposerStateWhenComposerQueueChanged({required double screenWidth}) {
    var (availableWidth, totalWidth, composerControllers) =
      _setUpDataToSyncComposerQueue(screenWidth: screenWidth);

    if (totalWidth < availableWidth) {
      final currentHiddenComposerIds = hiddenComposerIds;
      if (currentHiddenComposerIds.isEmpty) return;

      for (var index = currentHiddenComposerIds.length - 1; index >= 0; index--) {
        final newTotalWidth = totalWidth + ComposerStyle.minimizeWidth;
        if (newTotalWidth > availableWidth) break;

        final id = currentHiddenComposerIds.elementAt(index);
        final controller = composerControllers[id]!;
        controller.setScreenDisplayMode(ScreenDisplayMode.minimize);
        totalWidth = newTotalWidth;
      }
    } else if (totalWidth > availableWidth) {
      final currentDisplayedComposerIds = displayedComposerIds;
      if (currentDisplayedComposerIds.isEmpty) return;

      for (var id in currentDisplayedComposerIds) {
        final controller = composerControllers[id]!;

        if (controller.isNormalScreen) {
          var newTotalWidth = totalWidth - (ComposerStyle.normalWidth - ComposerStyle.minimizeWidth);
          var newDisplayMode = ScreenDisplayMode.minimize;

          if (newTotalWidth > availableWidth) {
            newTotalWidth = totalWidth - ComposerStyle.normalWidth;
            newDisplayMode = ScreenDisplayMode.hidden;
          }

          controller.setScreenDisplayMode(newDisplayMode);
          totalWidth = newTotalWidth;
        } else if (controller.isMinimizeScreen) {
          final newTotalWidth = totalWidth - ComposerStyle.minimizeWidth;
          controller.setScreenDisplayMode(ScreenDisplayMode.hidden);
          totalWidth = newTotalWidth;
        }

        if (totalWidth <= availableWidth) break;
      }
    }
  }

  void syncComposerStateWhenComposerDisplayModeChanged({
    required double screenWidth,
    required String updatedComposerId,
    required ScreenDisplayMode newDisplayMode,
  }) {
    if (composerIdsQueue.isEmpty) return;

    var (availableWidth, totalWidth, composerControllers) =
      _setUpDataToSyncComposerQueue(screenWidth: screenWidth);

    if (totalWidth < availableWidth) {
      final currentHiddenComposerIds = hiddenComposerIds;
      if (currentHiddenComposerIds.isEmpty) return;

      for (var index = currentHiddenComposerIds.length - 1; index >= 0; index--) {
        final newTotalWidth = totalWidth + ComposerStyle.minimizeWidth;
        if (newTotalWidth > availableWidth) break;

        final id = currentHiddenComposerIds.elementAt(index);
        composerControllers[id]!.setScreenDisplayMode(ScreenDisplayMode.minimize);
        totalWidth = newTotalWidth;
      }
    } else if (totalWidth > availableWidth) {
      for (var id in minimizeComposerIds) {
        if (id == updatedComposerId) continue;

        composerControllers[id]!.setScreenDisplayMode(ScreenDisplayMode.hidden);
        totalWidth -= ComposerStyle.minimizeWidth;
        if (totalWidth <= availableWidth) return;
      }

      for (var id in normalComposerIds) {
        if (id == updatedComposerId) continue;

        final controller = composerControllers[id]!;
        var newTotalWidth = totalWidth - (ComposerStyle.normalWidth - ComposerStyle.minimizeWidth);

        if (newTotalWidth <= availableWidth) {
          controller.setScreenDisplayMode(ScreenDisplayMode.minimize);
          return;
        }

        newTotalWidth = totalWidth - ComposerStyle.normalWidth;
        if (newTotalWidth <= availableWidth) {
          controller.setScreenDisplayMode(ScreenDisplayMode.hidden);
          return;
        }

        totalWidth = newTotalWidth;
      }
    }
  }

  void syncComposerStateWhenResponsiveChanged({required double screenWidth}) =>
      syncComposerStateWhenComposerQueueChanged(screenWidth: screenWidth);

  bool get hasComposer => composerIdsQueue.isNotEmpty;

  int get countComposerHidden => composers.values
    .where((composerView) => composerView.controller.isHiddenScreen)
    .length;

  ComposerView? get firstFullScreenComposerView => composers.values
    .firstWhereOrNull((composerView) => composerView.controller.isFullScreen);

  ComposerView? get firstComposerViewWhenResponsiveChanged {
    final conditionsMap = {
      ScreenDisplayMode.fullScreen: composers.values.where((view) => view.controller.isFullScreen).toList(),
      ScreenDisplayMode.normal: composers.values.where((view) => view.controller.isNormalScreen).toList(),
      ScreenDisplayMode.minimize: composers.values.where((view) => view.controller.isMinimizeScreen).toList(),
      ScreenDisplayMode.hidden: composers.values.where((view) => view.controller.isHiddenScreen).toList(),
    };

    if (conditionsMap[ScreenDisplayMode.fullScreen]!.isNotEmpty) {
      return conditionsMap[ScreenDisplayMode.fullScreen]!.first;
    }

    if (conditionsMap[ScreenDisplayMode.normal]!.isNotEmpty) {
      return conditionsMap[ScreenDisplayMode.normal]!.first;
    }

    if (conditionsMap[ScreenDisplayMode.minimize]!.isNotEmpty) {
      return conditionsMap[ScreenDisplayMode.minimize]!.first;
    }

    return conditionsMap[ScreenDisplayMode.hidden]!.isNotEmpty
      ? conditionsMap[ScreenDisplayMode.hidden]!.first
      : null;
  }

  List<String> get hiddenComposerIds {
    return composerIdsQueue
      .where((id) => getComposerView(id).controller.isHiddenScreen)
      .toList();
  }

  List<String> get displayedComposerIds {
    return composerIdsQueue
      .where((id) => !getComposerView(id).controller.isHiddenScreen)
      .toList();
  }

  List<String> get minimizeComposerIds {
    return composerIdsQueue
      .where((id) => getComposerView(id).controller.isMinimizeScreen)
      .toList();
  }

  List<String> get normalComposerIds {
    return composerIdsQueue
      .where((id) => getComposerView(id).controller.isNormalScreen)
      .toList();
  }

  void showComposerIfHidden(String composerId) {
    if (!composers.containsKey(composerId)) return;
    composerIdsQueue.remove(composerId);
    composerIdsQueue.add(composerId);
    final composerView = getComposerView(composerId);
    composerView.controller.setScreenDisplayMode(ScreenDisplayMode.normal);
    _syncQueueIfNeeded();
  }

  ComposerView getComposerView(String id) => composers[id]!;

  @override
  void onClose() {
    composerIdsQueue.clear();
    super.onClose();
  }
}