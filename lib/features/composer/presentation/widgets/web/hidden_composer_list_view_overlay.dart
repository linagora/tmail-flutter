
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/hidden_composer_item_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/hidden_composer_item.dart';

typedef OnRemoveHiddenComposerItem = Function(ComposerController controller);
typedef OnShowComposerAction = Function(String composerId);

class HiddenComposerListViewOverlay extends StatelessWidget {

  final ComposerManager composerManager;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnRemoveHiddenComposerItem onRemoveHiddenComposerItem;
  final OnShowComposerAction onShowComposerAction;

  const HiddenComposerListViewOverlay({
    super.key,
    required this.composerManager,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.onRemoveHiddenComposerItem,
    required this.onShowComposerAction,
  });

  @override
  Widget build(BuildContext context) {
    final hiddenComposerIds = composerManager.hiddenComposerIds;
    final maxHeight = responsiveUtils.getSizeScreenHeight(context)
      - ComposerStyle.composerExpandMoreButtonMaxHeight
      - ComposerStyle.padding * 2;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      width: HiddenComposerItemStyle.width,
      child: ListView.builder(
        itemCount: hiddenComposerIds.length,
        shrinkWrap: true,
        padding: const EdgeInsetsDirectional.only(end: 16),
        itemBuilder: (context, index) {
          final composerId = hiddenComposerIds[index];
          final controller = composerManager.getComposerView(composerId).controller;
          final subjectEmail = controller.subjectEmail.value ?? '';

          return HiddenComposerItem(
            imagePaths: imagePaths,
            composerSubject: subjectEmail,
            onCloseViewAction: () => onRemoveHiddenComposerItem(controller),
            onShowComposer: () => onShowComposerAction(composerId),
          );
        }),
    );
  }
}
