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
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_utils.dart';
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
      syncComposerQueue(
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

  bool isExceedsScreenSize({required double screenWidth}) {
    final availableWidth = screenWidth
      - ComposerUtils.composerExpandMoreButtonMaxWidth
      - ComposerUtils.horizontalPadding * 2;

    double totalWidth = composerIdsQueue.fold<double>(
      0,
      (sum, id) => sum + getComposerView(id).controller.composerWidth,
    );

    return totalWidth > availableWidth;
  }

  void syncComposerQueue({required double screenWidth}) {
    if (composerIdsQueue.isEmpty) return;

    final availableWidth = screenWidth
        - ComposerUtils.composerExpandMoreButtonMaxWidth
        - ComposerUtils.horizontalPadding * 2;

    double totalWidth = 0;
    final composerControllers = <String, ComposerController>{};

    for (var id in composerIdsQueue) {
      final controller = getComposerView(id).controller;
      final composerWidth = controller.composerWidth;
      composerControllers[id] = controller;
      totalWidth += composerWidth;
    }

    for (var id in composerIdsQueue) {
      final controller = composerControllers[id]!;

      if (controller.isNormalScreen) {
        controller.setScreenDisplayMode(ScreenDisplayMode.minimize);
        totalWidth -= (ComposerUtils.normalWidth - ComposerUtils.minimizeWidth);
      } else if (controller.isMinimizeScreen) {
        controller.setScreenDisplayMode(ScreenDisplayMode.hidden);
        totalWidth -= ComposerUtils.minimizeWidth;
      }

      if (totalWidth <= availableWidth) break;
    }

    for (var id in composerIdsQueue) {
      final controller = composerControllers[id]!;
      final composerWidth = controller.composerWidth;

      if (totalWidth + (ComposerUtils.normalWidth - composerWidth) <= availableWidth) {
        controller.setScreenDisplayMode(ScreenDisplayMode.normal);
        totalWidth += (ComposerUtils.normalWidth - composerWidth);
      } else if (totalWidth + (ComposerUtils.minimizeWidth - composerWidth) <= availableWidth) {
        controller.setScreenDisplayMode(ScreenDisplayMode.minimize);
        totalWidth += (ComposerUtils.minimizeWidth - composerWidth);
      }
    }

    composers.refresh();
  }

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

  ComposerView getComposerView(String id) => composers[id]!;

  @override
  void onClose() {
    composerIdsQueue.clear();
    super.onClose();
  }
}