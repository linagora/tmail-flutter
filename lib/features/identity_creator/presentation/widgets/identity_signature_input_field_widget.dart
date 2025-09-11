import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:tmail_ui_user/features/base/widget/dialog_picker/color_dialog_picker.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/toolbar_rich_text_builder_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/local_file_drop_zone_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/toolbar_rich_text_widget.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/insert_image_loading_indicator.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class IdentitySignatureInputFieldWidget extends StatelessWidget {
  final IdentityCreatorController controller;

  const IdentitySignatureInputFieldWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: AppColor.m3Neutral90),
              ),
              padding: const EdgeInsetsDirectional.only(
                start: 8,
                end: 8,
                top: 4,
                bottom: 8,
              ),
              child: _buildSignatureHtmlTemplate(
                context,
                constraints.maxWidth,
              ),
            ),
            Obx(() {
              final draggableAppState = controller.draggableAppState.value;
              if (draggableAppState == DraggableAppState.inActive) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: PointerInterceptor(
                  child: LocalFileDropZoneWidget(
                    imagePaths: controller.imagePaths,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    margin: EdgeInsets.zero,
                    onLocalFileDropZoneListener: (details) =>
                        controller.onLocalFileDropZoneListener(
                      context: context,
                      details: details,
                      maxWidth: constraints.maxWidth,
                    ),
                  ),
                ),
              );
            }),
            Obx(() {
              final isUploading =
                  controller.publicAssetController?.isUploading.isTrue ?? false;
              final isCompressingInlineImage =
                  controller.isCompressingInlineImage.isTrue;

              return InsertImageLoadingIndicator(
                isInserting: isUploading || isCompressingInlineImage,
              );
            }),
            Obx(() {
              bool isOverlayEnabled = ColorDialogPicker().isOpened.isTrue;

              if (isOverlayEnabled) {
                return Positioned.fill(
                  child: PointerInterceptor(
                    child: const SizedBox.expand(),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        );
      },
    );
  }

  Widget _buildSignatureHtmlTemplate(BuildContext context, double maxWidth) {
    if (PlatformInfo.isWeb) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToolbarRichTextWidget(
            richTextController: controller.richTextWebController!,
            imagePaths: controller.imagePaths,
            padding: const EdgeInsets.only(bottom: 12),
            isMobile: controller.responsiveUtils.isMobile(context),
            extendedOption: [
              Container(
                margin: ToolbarRichTextBuilderStyle.optionPadding,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.m3Neutral90,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                height: 40,
                child: TMailButtonWidget.fromIcon(
                  icon: controller.imagePaths.icAddPicture,
                  padding: const EdgeInsets.all(5),
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).insertImage,
                  onTapActionCallback: () => controller.pickImage(context),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 189,
            child: _buildHtmlEditorWeb(
              context,
              controller.contentHtmlEditor,
              maxWidth,
            ),
          ),
        ],
      );
    } else {
      return _buildHtmlEditor(
        context,
        initialContent: controller.contentHtmlEditor,
      );
    }
  }

  Widget _buildHtmlEditorWeb(
    BuildContext context,
    String initContent,
    double maxWidth,
  ) {
    final richTextWebController = controller.richTextWebController!;

    return html_editor_browser.HtmlEditor(
      key: const Key('identity_create_editor_web'),
      controller: richTextWebController.editorController,
      htmlEditorOptions: html_editor_browser.HtmlEditorOptions(
        shouldEnsureVisible: true,
        hint: '',
        darkMode: false,
        cacheHTMLAssetOffline: true,
        initialText: initContent.isEmpty ? null : initContent,
        disableDragAndDrop: true,
        spellCheck: true,
        normalizeHtmlTextWhenDropping: true,
        normalizeHtmlTextWhenPasting: true,
        customBodyCssStyle: HtmlUtils.customInlineBodyCssStyleHtmlEditor(
          direction: AppUtils.getCurrentDirection(context),
        ),
        customInternalCSS: HtmlTemplate.webCustomInternalStyleCSS(),
      ),
      htmlToolbarOptions: const html_editor_browser.HtmlToolbarOptions(
        toolbarType: html_editor_browser.ToolbarType.hide,
        defaultToolbarButtons: [],
      ),
      otherOptions: const html_editor_browser.OtherOptions(height: 200),
      callbacks: html_editor_browser.Callbacks(
        onBeforeCommand: controller.updateContentHtmlEditor,
        onChangeContent: (content) {
          controller.updateContentHtmlEditor(content);
          if (!controller.isLoadSignatureCompleted) {
            controller.onLoadSignatureCompleted(content);
          }
        },
        onInit: () {
          richTextWebController.editorController.setOnDragDropEvent();
          richTextWebController.editorController.setFullScreen();
          controller.updateContentHtmlEditor(initContent);
        },
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Future.delayed(const Duration(milliseconds: 500), () {
            richTextWebController.editorController.setFocus();
          });
          richTextWebController.closeAllMenuPopup();
        },
        onChangeSelection: richTextWebController.onEditorSettingsChange,
        onChangeCodeview: controller.updateContentHtmlEditor,
        onDragEnter: controller.handleOnDragEnterSignatureEditorWeb,
        onDragLeave: (_) {},
        onImageUpload: (listFileUpload) => controller.onPasteImageSuccess(
          context,
          listFileUpload,
          maxWidth: maxWidth,
        ),
        onImageUploadError: (listFileUpload, base64, uploadError) =>
            controller.onPasteImageFailure(
          context,
          listFileUpload,
          base64: base64,
          uploadError: uploadError,
        ),
      ),
    );
  }

  Widget _buildHtmlEditor(BuildContext context, {String? initialContent}) {
    return HtmlEditor(
      key: controller.htmlKey,
      minHeight: ConstantsUI.htmlContentMinHeight.toInt(),
      maxHeight:
          PlatformInfo.isIOS ? ConstantsUI.composerHtmlContentMaxHeight : null,
      addDefaultSelectionMenuItems: false,
      initialContent: initialContent ?? '',
      customStyleCss: HtmlTemplate.mobileCustomInternalStyleCSS(
        direction: AppUtils.getCurrentDirection(context),
      ),
      onCreated: (editorApi) => controller.initRichTextForMobile(
        context,
        editorApi,
      ),
    );
  }
}
