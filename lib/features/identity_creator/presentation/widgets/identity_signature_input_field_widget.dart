import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:tmail_ui_user/features/composer/presentation/mixin/rich_text_button_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/local_file_drop_zone_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/insert_image_loading_indicator.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class IdentitySignatureInputFieldWidget extends StatelessWidget
    with RichTextButtonMixin {
  final IdentityCreatorController controller;

  IdentitySignatureInputFieldWidget({
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
          ToolbarRichTextWebBuilder(
            richTextWebController: controller.richTextWebController!,
            padding: const EdgeInsets.only(bottom: 12),
            extendedOption: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: buildWrapIconStyleText(
                  icon: buildIconWithTooltip(
                    path: controller.imagePaths.icAddPicture,
                    tooltip: AppLocalizations.of(context).insertImage,
                  ),
                  hasDropdown: false,
                  onTap: () => controller.pickImage(context),
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
        customBodyCssStyle: HtmlUtils.customCssStyleHtmlEditor(
          direction: AppUtils.getCurrentDirection(context),
        ),
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
      customStyleCss: HtmlUtils.customCssStyleHtmlEditor(
        direction: AppUtils.getCurrentDirection(context),
      ),
      onCreated: (editorApi) => controller.initRichTextForMobile(
        context,
        editorApi,
      ),
    );
  }
}
