import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_button_arrow_down_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/label_input_field_builder.dart';
import 'package:tmail_ui_user/features/base/widget/modal_list_action_button_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/modal_folder_tree_list_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxCreatorView extends GetWidget<MailboxCreatorController> {
  @override
  final controller = Get.find<MailboxCreatorController>();

  MailboxCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (_, constraints) {
      final currentScreenWidth = constraints.maxWidth;
      final currentScreenHeight = constraints.maxHeight;
      final maxScreenHeight =
          controller.isFolderModalEnabled.isTrue ? 570 : 500;
      final isExceedSize = currentScreenHeight > maxScreenHeight;
      final isMobile = currentScreenWidth < ResponsiveUtils.minTabletWidth;

      List<Widget> fieldsWidgets = [
        Obx(
          () => LabelInputFieldBuilder(
            label: appLocalizations.folderName,
            hintText: appLocalizations.enterTheFolderName,
            textEditingController: controller.nameInputController,
            focusNode: controller.nameInputFocusNode,
            errorText: controller.getErrorInputNameString(context),
            arrangeHorizontally: false,
            isLabelHasColon: false,
            labelStyle: ThemeUtils.textStyleInter600().copyWith(
              fontSize: 14,
              height: 18 / 14,
              color: Colors.black,
            ),
            runSpacing: 16,
            inputFieldMaxWidth: double.infinity,
            onTextChange: controller.setNewNameMailbox,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 26, bottom: 16),
          child: Text(
            appLocalizations.selectTheFolderLocation,
            style: ThemeUtils.textStyleInter600().copyWith(
              fontSize: 14,
              height: 18 / 14,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Obx(() {
          final selectedMailbox = controller.selectedMailbox.value;
          final isFolderModalEnabled = controller.isFolderModalEnabled.isTrue;

          final folderLocationWidget = AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isFolderModalEnabled
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color: AppColor.m3Neutral90,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsetsDirectional.only(
                      start: 14,
                      top: 13,
                      bottom: 13,
                      end: 4,
                    ),
                    child: Obx(
                      () => ModalFolderTreeListWidget(
                        defaultTree: controller.defaultMailboxTree.value,
                        personalTree: controller.personalMailboxTree.value,
                        imagePaths: controller.imagePaths,
                        listScrollController:
                            controller.listFolderScrollController,
                        mailboxIdSelected: selectedMailbox?.id,
                        onSelectFolderAction: (node) =>
                            controller.selectMailboxLocation(context, node),
                        onToggleFolderAction: controller.toggleFolder,
                      ),
                    ),
                  )
                : DefaultButtonArrowDownFieldWidget(
                    text: selectedMailbox?.getDisplayName(context) ??
                        appLocalizations.personalFolders,
                    icon: MailboxIconWidget(
                      icon: selectedMailbox
                              ?.getMailboxIcon(controller.imagePaths) ??
                          controller.imagePaths.icFolderMailbox,
                    ),
                    iconArrowDown: controller.imagePaths.icDropDown,
                    onTap: () => controller.openFolderModal(context),
                  ),
          );

          if (isExceedSize) {
            return Flexible(child: folderLocationWidget);
          } else {
            return folderLocationWidget;
          }
        }),
        ModalListActionButtonWidget(
          positiveLabel: appLocalizations.createFolder,
          negativeLabel: appLocalizations.cancel,
          padding: const EdgeInsets.symmetric(vertical: 25),
          onPositiveAction: () => controller.createNewMailbox(context),
          onNegativeAction: controller.closeView,
        )
      ];

      Widget bodyWidget = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 2,
            ),
          ],
        ),
        width: math.min(
          currentScreenWidth - 32,
          554,
        ),
        constraints: BoxConstraints(
          maxHeight: math.min(
            currentScreenHeight - 100,
            671,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: isExceedSize
                ? EdgeInsetsDirectional.only(
                    start: 32,
                    end: 32,
                    bottom: isMobile ? 0 : 16,
                  )
                : EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 64,
                    alignment: Alignment.center,
                    padding: !isExceedSize
                        ? EdgeInsetsDirectional.only(
                            start: 32,
                            end: 32,
                            top: 16,
                            bottom: isMobile ? 0 : 16,
                          )
                        : EdgeInsets.zero,
                    child: Text(
                      appLocalizations.createANewFolder,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColor.m3SurfaceBackground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Obx(() {
                    final folderName = controller.selectedMailbox.value
                            ?.getDisplayName(context) ??
                        appLocalizations.personalFolders;
                    return Center(
                      child: Padding(
                        padding: !isExceedSize
                            ? EdgeInsetsDirectional.only(
                                start: 32,
                                end: 32,
                                bottom: isMobile ? 0 : 16,
                              )
                            : EdgeInsets.zero,
                        child: Text(
                          appLocalizations
                              .subtitleDisplayTheFolderNameLocationInFolderCreationModal(
                            folderName,
                          ),
                          style: ThemeUtils.textStyleInter400.copyWith(
                            color: AppColor.steelGrayA540,
                            fontSize: 13,
                            height: 20 / 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  if (isExceedSize)
                    ...fieldsWidgets
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: 32,
                            end: 32,
                            bottom: isMobile ? 0 : 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: fieldsWidgets,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            DefaultCloseButtonWidget(
              iconClose: controller.imagePaths.icCloseDialog,
              onTapActionCallback: controller.closeView,
            ),
          ],
        ),
      );

      bodyWidget = Center(child: bodyWidget);

      if (PlatformInfo.isMobile) {
        bodyWidget = GestureDetector(
          onTap: controller.closeView,
          child: Scaffold(
            backgroundColor: AppColor.blackAlpha20,
            body: GestureDetector(
              onTap: controller.nameInputFocusNode.unfocus,
              child: bodyWidget,
            ),
          ),
        );
      }

      return bodyWidget;
    });
  }
}
