import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
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

    _arrangeComposerIfNeeded();
  }

  void removeComposer(String id) {
    if (!composers.containsKey(id)) return;

    composerIdsQueue.remove(id);
    composers.remove(id);
    ComposerBindings(composerId: id).dispose();

    _arrangeComposerIfNeeded();
  }

  void _arrangeComposerIfNeeded() {
    if (currentContext != null && composerIdsQueue.isNotEmpty) {
      arrangeComposerWhenComposerQueueChanged(
        screenWidth: _responsiveUtils.getSizeScreenWidth(currentContext!),
      );
    }
  }

  (
    double availableScreenWidth,
    double totalOpenedComposersWidth,
    Map<String, ComposerController> composerControllers
  ) _getSizeToArrangeComposer({required double screenWidth}) {
    double totalOpenedComposersWidth = 0;
    double countDisplayedComposer = 0;
    final composerControllers = <String, ComposerController>{};

    for (var id in composerIdsQueue) {
      final controller = getComposerView(id).controller;
      final composerWidth = controller.composerWidth;
      if (!controller.isHiddenScreen) {
        countDisplayedComposer++;
      }
      composerControllers[id] = controller;
      totalOpenedComposersWidth += composerWidth;
    }

    final availableScreenWidth = screenWidth
      - ComposerStyle.composerExpandMoreButtonMaxWidth
      - ComposerStyle.padding * 2
      - (countDisplayedComposer - 1) * ComposerStyle.space;
    log('ComposerManager::_getSizeToArrangeComposers:screenWidth = $screenWidth | availableScreenWidth = $availableScreenWidth | totalOpenedComposersWidth = $totalOpenedComposersWidth');
    return (
      availableScreenWidth,
      totalOpenedComposersWidth,
      composerControllers,
    );
  }

  void _showMinimizedComposersIfOverflow({
    required double availableScreenWidth,
    required double totalOpenedComposersWidth,
    required Map<String, ComposerController> composerControllers,
  }) {
    final currentHiddenComposerIds = hiddenComposerIds;
    if (currentHiddenComposerIds.isEmpty) return;

    for (var index = currentHiddenComposerIds.length - 1; index >= 0; index--) {
      final newTotalWidth = totalOpenedComposersWidth + ComposerStyle.minimizeWidth;
      if (newTotalWidth > availableScreenWidth) break;

      final id = currentHiddenComposerIds.elementAt(index);
      composerControllers[id]!.setScreenDisplayMode(ScreenDisplayMode.minimize);
      totalOpenedComposersWidth = newTotalWidth;
    }
  }

  void _hideComposersIfFit({
    required double availableScreenWidth,
    required double totalOpenedComposersWidth,
    required Map<String, ComposerController> composerControllers,
  }) {
    final currentDisplayedComposerIds = displayedComposerIds;
    if (currentDisplayedComposerIds.isEmpty) return;

    for (var id in currentDisplayedComposerIds) {
      final controller = composerControllers[id]!;

      if (controller.isNormalScreen) {
        var newTotalWidth = totalOpenedComposersWidth - (ComposerStyle.normalWidth - ComposerStyle.minimizeWidth);
        var newDisplayMode = ScreenDisplayMode.minimize;

        if (newTotalWidth > availableScreenWidth) {
          newTotalWidth = totalOpenedComposersWidth - ComposerStyle.normalWidth;
          newDisplayMode = ScreenDisplayMode.hidden;
        }

        controller.setScreenDisplayMode(newDisplayMode);
        totalOpenedComposersWidth = newTotalWidth;
      } else if (controller.isMinimizeScreen) {
        final newTotalWidth = totalOpenedComposersWidth - ComposerStyle.minimizeWidth;
        controller.setScreenDisplayMode(ScreenDisplayMode.hidden);
        totalOpenedComposersWidth = newTotalWidth;
      }

      if (totalOpenedComposersWidth <= availableScreenWidth) break;
    }
  }

  void arrangeComposerWhenComposerQueueChanged({required double screenWidth}) {
    var (availableScreenWidth, totalOpenedComposersWidth, composerControllers) =
      _getSizeToArrangeComposer(screenWidth: screenWidth);

    if (totalOpenedComposersWidth < availableScreenWidth) {
      _showMinimizedComposersIfOverflow(
        availableScreenWidth: availableScreenWidth,
        totalOpenedComposersWidth: totalOpenedComposersWidth,
        composerControllers: composerControllers,
      );
    } else if (totalOpenedComposersWidth > availableScreenWidth) {
      _hideComposersIfFit(
        availableScreenWidth: availableScreenWidth,
        totalOpenedComposersWidth: totalOpenedComposersWidth,
        composerControllers: composerControllers,
      );
    }
  }

  void _hideComposersPreferringMinimizedIfFit({
    required String updatedComposerId,
    required double availableScreenWidth,
    required double totalOpenedComposersWidth,
    required Map<String, ComposerController> composerControllers,
  }) {
    for (var id in minimizeComposerIds) {
      if (id == updatedComposerId) continue;

      composerControllers[id]!.setScreenDisplayMode(ScreenDisplayMode.hidden);
      totalOpenedComposersWidth -= ComposerStyle.minimizeWidth;
      if (totalOpenedComposersWidth <= availableScreenWidth) return;
    }

    for (var id in normalComposerIds) {
      if (id == updatedComposerId) continue;

      final controller = composerControllers[id]!;
      var newTotalWidth = totalOpenedComposersWidth - (ComposerStyle.normalWidth - ComposerStyle.minimizeWidth);

      if (newTotalWidth <= availableScreenWidth) {
        controller.setScreenDisplayMode(ScreenDisplayMode.minimize);
        return;
      }

      newTotalWidth = totalOpenedComposersWidth - ComposerStyle.normalWidth;
      if (newTotalWidth <= availableScreenWidth) {
        controller.setScreenDisplayMode(ScreenDisplayMode.hidden);
        return;
      }

      totalOpenedComposersWidth = newTotalWidth;
    }
  }

  void arrangeComposerWhenComposerDisplayModeChanged({
    required double screenWidth,
    required String updatedComposerId,
    required ScreenDisplayMode newDisplayMode,
  }) {
    if (composerIdsQueue.isEmpty) return;

    if (newDisplayMode.isNotContentVisible()) {
      composers.refresh();
      return;
    }

    var (availableScreenWidth, totalOpenedComposersWidth, composerControllers) =
      _getSizeToArrangeComposer(screenWidth: screenWidth);

    if (totalOpenedComposersWidth < availableScreenWidth) {
      _showMinimizedComposersIfOverflow(
        availableScreenWidth: availableScreenWidth,
        totalOpenedComposersWidth: totalOpenedComposersWidth,
        composerControllers: composerControllers,
      );
    } else if (totalOpenedComposersWidth > availableScreenWidth) {
      _hideComposersPreferringMinimizedIfFit(
        updatedComposerId: updatedComposerId,
        availableScreenWidth: availableScreenWidth,
        totalOpenedComposersWidth: totalOpenedComposersWidth,
        composerControllers: composerControllers,
      );
    }
  }

  void arrangeComposerWhenResponsiveChanged({required double screenWidth}) =>
    arrangeComposerWhenComposerQueueChanged(screenWidth: screenWidth);

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

  bool get isAllHiddenComposer {
    return composerIdsQueue.every((id) => getComposerView(id).controller.isHiddenScreen);
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
    _arrangeComposerIfNeeded();
  }

  ComposerView getComposerView(String id) => composers[id]!;

  @override
  void onClose() {
    composerIdsQueue.clear();
    super.onClose();
  }
}