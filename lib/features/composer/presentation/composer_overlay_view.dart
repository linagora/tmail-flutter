
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/expand_composer_button.dart';

class ComposerOverlayView extends StatefulWidget {
  const ComposerOverlayView({super.key});

  @override
  State<ComposerOverlayView> createState() => _ComposerOverlayViewState();
}

class _ComposerOverlayViewState extends State<ComposerOverlayView> {

  final ComposerManager _composerManager = Get.find<ComposerManager>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final composers = _composerManager.composers;
      if (composers.isEmpty) return const SizedBox.shrink();

      if (composers.length == 1) {
        return _composerManager.getComposerView(_composerManager.singleComposerId);
      }

      return Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: LayoutBuilder(
              builder: (_, constraints) {
                final availableWidth = constraints.maxWidth - ComposerUtils.composerExpandMoreButtonMaxWidth;

                final composerIds = _composerManager.composerIdsQueue.toList();
                final composerViews = composerIds
                  .map((id) => _composerManager.getComposerView(id))
                  .toList();

                final countNormalComposer = composerViews.where(
                  (view) => view.controller.screenDisplayMode.value == ScreenDisplayMode.normal,
                ).length;

                final maxNormalComposer = ComposerUtils.calculateNormalWidgets(availableWidth);
                final countDisplayNormalComposer = min(
                  countNormalComposer,
                  maxNormalComposer,
                );

                final countDisplayComposer = countDisplayNormalComposer > 0
                  ? ComposerUtils.calculateNormalAndMinimizeWidgets(availableWidth, countDisplayNormalComposer)
                  : ComposerUtils.calculateMinimizeWidgets(availableWidth);

                if (countDisplayComposer < 1) return const SizedBox.shrink();

                Iterable<String> composerIdsDisplayed = [];
                if (composerIds.length > countDisplayComposer) {
                  composerIdsDisplayed = composerIds
                    .reversed
                    .take(countDisplayComposer)
                    .toList()
                    .reversed;
                } else {
                  composerIdsDisplayed = composerIds;
                }

                final countMinimizeComposer =
                    composerIdsDisplayed.length - countDisplayNormalComposer;

                int countComposerHidden = composerIds.length - countDisplayComposer;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (countComposerHidden > 0)
                      ExpandComposerButton(
                        imagePaths: _imagePaths,
                        countComposerHidden: countComposerHidden,
                        onToggleDisplayComposerAction: () {},
                      ),
                    ...composerIdsDisplayed.mapIndexed((index, id) {
                      final composerView = _composerManager.getComposerView(id);
                      final isMinimized = countDisplayNormalComposer < 1 ||
                          (countMinimizeComposer > 0 && index < countMinimizeComposer);

                      composerView.controller.screenDisplayMode.value = isMinimized
                          ? ScreenDisplayMode.minimize
                          : ScreenDisplayMode.normal;

                      return composerView;
                    }).toList(),
                  ],
                );
              }
          ),
        ),
      );
    });
  }
}
