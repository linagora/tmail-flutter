import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';
import 'package:scribe/scribe/ai/presentation/widgets/button/ai_assistant_button.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_attachment_extension_registry_provider.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/composer_overflow_action_bar.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/more_options_menu_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MobileResponsiveAppBarComposerWidget extends ConsumerWidget {

  final ImagePaths imagePaths;
  final bool isCodeViewEnabled;
  final bool isSendButtonEnabled;
  final bool isFormattingOptionsEnabled;
  final bool hasRequestReadReceipt;
  final bool isMarkAsImportant;
  final bool isEmailChanged;
  final CustomPopupMenuController menuMoreOptionController;
  final VoidCallback onCloseViewAction;
  final VoidCallback attachFileAction;
  final VoidCallback insertImageAction;
  final VoidCallback sendMessageAction;
  final VoidCallback openRichToolbarAction;
  final VoidCallback toggleCodeViewAction;
  final VoidCallback toggleRequestReadReceiptAction;
  final VoidCallback printDraftAction;
  final VoidCallback saveToDraftsAction;
  final VoidCallback saveToTemplateAction;
  final VoidCallback deleteComposerAction;
  final VoidCallback toggleMarkAsImportantAction;
  final OnOpenAiAssistantModal? onOpenAiAssistantModal;
  final String? composerId;

  const MobileResponsiveAppBarComposerWidget({
    super.key,
    required this.imagePaths,
    required this.isCodeViewEnabled,
    required this.isFormattingOptionsEnabled,
    required this.isSendButtonEnabled,
    required this.hasRequestReadReceipt,
    required this.isMarkAsImportant,
    required this.isEmailChanged,
    required this.menuMoreOptionController,
    required this.openRichToolbarAction,
    required this.onCloseViewAction,
    required this.attachFileAction,
    required this.insertImageAction,
    required this.sendMessageAction,
    required this.toggleCodeViewAction,
    required this.toggleRequestReadReceiptAction,
    required this.printDraftAction,
    required this.saveToDraftsAction,
    required this.saveToTemplateAction,
    required this.deleteComposerAction,
    required this.toggleMarkAsImportantAction,
    this.onOpenAiAssistantModal,
    this.composerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref
        .watch(composerAttachmentExtensionRegistryProvider)
        .extensions;
    return Container(
      height: MobileAppBarComposerWidgetStyle.height,
      color: MobileAppBarComposerWidgetStyle.backgroundColor,
      padding: MobileAppBarComposerWidgetStyle.padding,
      child: Row(
        children: [
          TMailButtonWidget.fromIcon(
            key: const Key(UiKeys.closeComposerButton),
            icon: imagePaths.icCancel,
            backgroundColor: Colors.transparent,
            tooltipMessage: AppLocalizations.of(context).saveAndClose,
            iconSize: MobileAppBarComposerWidgetStyle.iconSize,
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            onTapActionCallback: onCloseViewAction
          ),
          Expanded(
            // Rebuild when a plugin starts or stops showing its button.
            child: ListenableBuilder(
              listenable: Listenable.merge([
                for (final plugin in plugins) plugin.availability,
              ]),
              builder: (context, _) => ComposerOverflowActionBar(
                  actions: _buildOverflowActions(context, plugins),
                  slotWidth: MobileAppBarComposerWidgetStyle.actionSlotWidth,
                  reservedWidth: MobileAppBarComposerWidgetStyle.trailingReservedWidth,
                  trailingBuilder: (overflowMenuItems) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
                      TMailButtonWidget.fromIcon(
                        key: const ValueKey(UiKeys.sendEmailButton),
                        icon: isSendButtonEnabled
                          ? imagePaths.icSendMobile
                          : imagePaths.icSendDisable,
                        backgroundColor: Colors.transparent,
                        padding: MobileAppBarComposerWidgetStyle.iconPadding,
                        iconSize: MobileAppBarComposerWidgetStyle.sendButtonIconSize,
                        tooltipMessage: AppLocalizations.of(context).send,
                        onTapActionCallback: sendMessageAction,
                      ),
                      const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
                      MoreOptionsMenuComposerWidget(
                        imagePaths: imagePaths,
                        menuController: menuMoreOptionController,
                        overflowMenuItems: overflowMenuItems,
                        isCodeViewEnabled: isCodeViewEnabled,
                        hasRequestReadReceipt: hasRequestReadReceipt,
                        isMarkAsImportant: isMarkAsImportant,
                        isEmailChanged: isEmailChanged,
                        toggleCodeViewAction: toggleCodeViewAction,
                        toggleRequestReadReceiptAction: toggleRequestReadReceiptAction,
                        printDraftAction: printDraftAction,
                        saveToDraftsAction: saveToDraftsAction,
                        saveToTemplateAction: saveToTemplateAction,
                        deleteComposerAction: deleteComposerAction,
                        toggleMarkAsImportantAction: toggleMarkAsImportantAction,
                      ),
                    ],
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ComposerOverflowAction> _buildOverflowActions(
    BuildContext context,
    List<ComposerAttachmentPlugin> plugins,
  ) {
    final appLocalizations = AppLocalizations.of(context);
    return [
      if (onOpenAiAssistantModal != null)
        ComposerOverflowAction(
          button: AiAssistantButton(
            imagePaths: imagePaths,
            margin: const EdgeInsetsDirectional.only(
              end: MobileAppBarComposerWidgetStyle.space,
            ),
            onOpenAiAssistantModal: onOpenAiAssistantModal!,
          ),
          menuItem: _buildMenuItem(
            icon: imagePaths.icGradientSparkle,
            label: ScribeLocalizations.of(context).aiAssistant,
            iconColor: null,
            // No anchor inside the menu; the modal uses its default placement.
            onTap: () => onOpenAiAssistantModal!(null, null),
          ),
        ),
      ComposerOverflowAction(
        button: Padding(
          padding: const EdgeInsetsDirectional.only(
            end: MobileAppBarComposerWidgetStyle.space,
          ),
          child: TMailButtonWidget.fromIcon(
            icon: imagePaths.icRichToolbar,
            padding: MobileAppBarComposerWidgetStyle.richTextIconPadding,
            backgroundColor: isFormattingOptionsEnabled
              ? MobileAppBarComposerWidgetStyle.selectedBackgroundColor
              : Colors.transparent,
            iconSize: MobileAppBarComposerWidgetStyle.richTextIconSize,
            iconColor: isFormattingOptionsEnabled
              ? MobileAppBarComposerWidgetStyle.selectedIconColor
              : MobileAppBarComposerWidgetStyle.iconColor,
            tooltipMessage: appLocalizations.formattingOptions,
            onTapActionCallback: openRichToolbarAction,
          ),
        ),
        menuItem: _buildMenuItem(
          icon: imagePaths.icRichToolbar,
          label: appLocalizations.formattingOptions,
          isSelected: isFormattingOptionsEnabled,
          onTap: openRichToolbarAction,
        ),
      ),
      ComposerOverflowAction(
        button: TMailButtonWidget.fromIcon(
          icon: imagePaths.icAttachFile,
          iconColor: MobileAppBarComposerWidgetStyle.iconColor,
          backgroundColor: Colors.transparent,
          iconSize: MobileAppBarComposerWidgetStyle.iconSize,
          tooltipMessage: appLocalizations.attach_file,
          onTapActionCallback: attachFileAction,
        ),
        menuItem: _buildMenuItem(
          icon: imagePaths.icAttachFile,
          label: appLocalizations.attach_file,
          onTap: attachFileAction,
        ),
      ),
      for (final plugin in plugins.where((plugin) => plugin.isAvailable))
        ComposerOverflowAction(
          button: plugin.buildToolbarButton(
            context,
            composerId: composerId ?? '',
            imagePaths: imagePaths,
            style: ComposerToolbarButtonStyle(
              tooltipLabel: appLocalizations.attach_file,
              iconColor: MobileAppBarComposerWidgetStyle.iconColor,
              iconSize: MobileAppBarComposerWidgetStyle.iconSize,
              margin: const EdgeInsetsDirectional.only(
                start: MobileAppBarComposerWidgetStyle.space,
              ),
            ),
          ),
          menuItem: plugin.buildContextMenuTile(
            context,
            imagePaths: imagePaths,
            composerId: composerId,
            onDismiss: menuMoreOptionController.hideMenu,
          ),
        ),
      if (!isCodeViewEnabled)
        ComposerOverflowAction(
          button: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: MobileAppBarComposerWidgetStyle.space,
            ),
            child: TMailButtonWidget.fromIcon(
              icon: imagePaths.icInsertImage,
              iconColor: MobileAppBarComposerWidgetStyle.iconColor,
              backgroundColor: Colors.transparent,
              iconSize: MobileAppBarComposerWidgetStyle.iconSize,
              tooltipMessage: appLocalizations.insertImage,
              onTapActionCallback: insertImageAction,
            ),
          ),
          menuItem: _buildMenuItem(
            icon: imagePaths.icInsertImage,
            label: appLocalizations.insertImage,
            onTap: insertImageAction,
          ),
        ),
    ];
  }

  Widget _buildMenuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor = MobileAppBarComposerWidgetStyle.popupItemIconColor,
    bool isSelected = false,
  }) {
    return PopupItemWidget(
      iconAction: icon,
      nameAction: label,
      styleName: MobileAppBarComposerWidgetStyle.popupItemTextStyle,
      padding: MobileAppBarComposerWidgetStyle.popupItemPadding,
      colorIcon: iconColor,
      selectedIcon: imagePaths.icFilterSelected,
      isSelected: isSelected,
      onCallbackAction: () {
        menuMoreOptionController.hideMenu();
        onTap();
      },
    );
  }
}
