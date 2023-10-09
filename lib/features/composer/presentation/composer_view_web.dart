import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/desktop_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/mobile_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/tablet_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/web_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/insert_image_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/desktop_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/attachment_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/bottom_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/mobile_responsive_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ComposerView extends GetWidget<ComposerController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: _responsiveUtils,
      mobile: MobileResponsiveContainerView(
        childBuilder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => MobileResponsiveAppBarComposerWidget(
                isCodeViewEnabled: controller.richTextWebController.codeViewEnabled,
                isFormattingOptionsEnabled: controller.richTextWebController.isFormattingOptionsEnabled,
                openRichToolbarAction: controller.richTextWebController.toggleFormattingOptions,
                isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                onCloseViewAction: () => controller.saveToDraftAndClose(context),
                attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
                insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                sendMessageAction: () => controller.sendEmailAction(context),
                openContextMenuAction: (position) {
                  controller.openPopupMenuAction(
                    context,
                    position,
                    _createMoreOptionPopupItems(context),
                    radius: ComposerStyle.popupMenuRadius
                  );
                },
              )),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(
                    context,
                    constraints,
                    _responsiveUtils
                  )
                ),
                child: SingleChildScrollView(
                  controller: controller.scrollControllerEmailAddress,
                  child: Obx(() => Column(
                    children: [
                      RecipientComposerWidget(
                        prefix: PrefixEmailAddress.to,
                        listEmailAddress: controller.listToEmailAddress,
                        ccState: controller.ccRecipientState.value,
                        bccState: controller.bccRecipientState.value,
                        expandMode: controller.toAddressExpandMode.value,
                        controller: controller.toEmailAddressController,
                        focusNode: controller.toAddressFocusNode,
                        autoDisposeFocusNode: false,
                        keyTagEditor: controller.keyToEmailTagEditor,
                        isInitial: controller.isInitialRecipient.value,
                        padding: ComposerStyle.mobileRecipientPadding,
                        margin: ComposerStyle.mobileRecipientMargin,
                        nextFocusNode: controller.getNextFocusOfToEmailAddress(),
                        onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                        onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                        onAddEmailAddressTypeAction: controller.addEmailAddressType,
                        onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                        onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                        onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                        onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                      ),
                      if (controller.ccRecipientState.value == PrefixRecipientState.enabled)
                        RecipientComposerWidget(
                          prefix: PrefixEmailAddress.cc,
                          listEmailAddress: controller.listCcEmailAddress,
                          expandMode: controller.ccAddressExpandMode.value,
                          controller: controller.ccEmailAddressController,
                          focusNode: controller.ccAddressFocusNode,
                          autoDisposeFocusNode: false,
                          keyTagEditor: controller.keyCcEmailTagEditor,
                          isInitial: controller.isInitialRecipient.value,
                          nextFocusNode: controller.getNextFocusOfCcEmailAddress(),
                          padding: ComposerStyle.mobileRecipientPadding,
                          margin: ComposerStyle.mobileRecipientMargin,
                          onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                          onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                          onDeleteEmailAddressTypeAction: controller.deleteEmailAddressType,
                          onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                          onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                          onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                          onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                        ),
                      if (controller.bccRecipientState.value == PrefixRecipientState.enabled)
                        RecipientComposerWidget(
                          prefix: PrefixEmailAddress.bcc,
                          listEmailAddress: controller.listBccEmailAddress,
                          expandMode: controller.bccAddressExpandMode.value,
                          controller: controller.bccEmailAddressController,
                          focusNode: controller.bccAddressFocusNode,
                          autoDisposeFocusNode: false,
                          keyTagEditor: controller.keyBccEmailTagEditor,
                          isInitial: controller.isInitialRecipient.value,
                          nextFocusNode: controller.subjectEmailInputFocusNode,
                          padding: ComposerStyle.mobileRecipientPadding,
                          margin: ComposerStyle.mobileRecipientMargin,
                          onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                          onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                          onDeleteEmailAddressTypeAction: controller.deleteEmailAddressType,
                          onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                          onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                          onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                          onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                        ),
                    ],
                  )),
                )
              ),
              SubjectComposerWidget(
                focusNode: controller.subjectEmailInputFocusNode,
                textController: controller.subjectEmailInputController,
                onTextChange: controller.setSubjectEmail,
                padding: ComposerStyle.mobileSubjectPadding,
                margin: ComposerStyle.mobileSubjectMargin,
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  log('ComposerView::build:mobile:constraints: $constraints');
                  return Stack(
                    children: [
                      Padding(
                        padding: ComposerStyle.mobileEditorPadding,
                        child: Obx(() => WebEditorView(
                          editorController: controller.richTextWebController.editorController,
                          arguments: controller.composerArguments.value,
                          contentViewState: controller.emailContentsViewState.value,
                          currentWebContent: controller.textEditorWeb,
                          onInitial: controller.handleInitHtmlEditorWeb,
                          onChangeContent: controller.onChangeTextEditorWeb,
                          onFocus: controller.handleOnFocusHtmlEditorWeb,
                          onUnFocus: controller.handleOnUnFocusHtmlEditorWeb,
                          onMouseDown: controller.handleOnMouseDownHtmlEditorWeb,
                          onEditorSettings: controller.richTextWebController.onEditorSettingsChange,
                          onImageUploadSuccessAction: (fileUpload) => controller.handleImageUploadSuccess(context, fileUpload),
                          onImageUploadFailureAction: (fileUpload, base64Str, uploadError) {
                            return controller.handleImageUploadFailure(
                              context: context,
                              uploadError: uploadError,
                              fileUpload: fileUpload,
                              base64Str: base64Str,
                            );
                          },
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        )),
                      ),
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Obx(() => InsertImageLoadingBarWidget(
                          uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                          viewState: controller.viewState.value,
                          padding: ComposerStyle.insertImageLoadingBarPadding,
                        )),
                      ),
                    ],
                  );
                }),
              ),
              Obx(() {
                if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                  return AttachmentComposerWidget(
                    listFileUploaded: controller.uploadController.listUploadAttachments,
                    isCollapsed: controller.isAttachmentCollapsed,
                    onDeleteAttachmentAction: (fileState) => controller.deleteAttachmentUploaded(fileState.uploadTaskId),
                    onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              Obx(() {
                if (controller.richTextWebController.isFormattingOptionsEnabled) {
                  return ToolbarRichTextWebBuilder(
                    richTextWebController: controller.richTextWebController,
                    padding: ComposerStyle.richToolbarPadding,
                    decoration: const BoxDecoration(
                        color: ComposerStyle.richToolbarColor,
                        boxShadow: ComposerStyle.richToolbarShadow
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              })
            ]
          );
        }
      ),
      desktop: Obx(() => DesktopResponsiveContainerView(
        childBuilder: (context, constraints) {
          return Column(children: [
            Obx(() => DesktopAppBarComposerWidget(
              emailSubject: controller.subjectEmail.value ?? '',
              displayMode: controller.screenDisplayMode.value,
              onCloseViewAction: () => controller.saveToDraftAndClose(context),
              onChangeDisplayModeAction: controller.displayScreenTypeComposerAction,
              constraints: constraints,
            )),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(
                  context,
                  constraints,
                  _responsiveUtils
                )
              ),
              child: SingleChildScrollView(
                controller: controller.scrollControllerEmailAddress,
                child: Obx(() => Column(
                  children: [
                    RecipientComposerWidget(
                      prefix: PrefixEmailAddress.to,
                      listEmailAddress: controller.listToEmailAddress,
                      ccState: controller.ccRecipientState.value,
                      bccState: controller.bccRecipientState.value,
                      expandMode: controller.toAddressExpandMode.value,
                      controller: controller.toEmailAddressController,
                      focusNode: controller.toAddressFocusNode,
                      autoDisposeFocusNode: false,
                      keyTagEditor: controller.keyToEmailTagEditor,
                      isInitial: controller.isInitialRecipient.value,
                      padding: ComposerStyle.desktopRecipientPadding,
                      margin: ComposerStyle.desktopRecipientMargin,
                      nextFocusNode: controller.getNextFocusOfToEmailAddress(),
                      onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                      onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                      onAddEmailAddressTypeAction: controller.addEmailAddressType,
                      onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                      onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                      onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                      onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                    ),
                    if (controller.ccRecipientState.value == PrefixRecipientState.enabled)
                      RecipientComposerWidget(
                        prefix: PrefixEmailAddress.cc,
                        listEmailAddress: controller.listCcEmailAddress,
                        expandMode: controller.ccAddressExpandMode.value,
                        controller: controller.ccEmailAddressController,
                        focusNode: controller.ccAddressFocusNode,
                        autoDisposeFocusNode: false,
                        keyTagEditor: controller.keyCcEmailTagEditor,
                        isInitial: controller.isInitialRecipient.value,
                        nextFocusNode: controller.getNextFocusOfCcEmailAddress(),
                        padding: ComposerStyle.desktopRecipientPadding,
                        margin: ComposerStyle.desktopRecipientMargin,
                        onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                        onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                        onDeleteEmailAddressTypeAction: controller.deleteEmailAddressType,
                        onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                        onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                        onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                        onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                      ),
                    if (controller.bccRecipientState.value == PrefixRecipientState.enabled)
                      RecipientComposerWidget(
                        prefix: PrefixEmailAddress.bcc,
                        listEmailAddress: controller.listBccEmailAddress,
                        expandMode: controller.bccAddressExpandMode.value,
                        controller: controller.bccEmailAddressController,
                        focusNode: controller.bccAddressFocusNode,
                        autoDisposeFocusNode: false,
                        keyTagEditor: controller.keyBccEmailTagEditor,
                        isInitial: controller.isInitialRecipient.value,
                        nextFocusNode: controller.subjectEmailInputFocusNode,
                        padding: ComposerStyle.desktopRecipientPadding,
                        margin: ComposerStyle.desktopRecipientMargin,
                        onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                        onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                        onDeleteEmailAddressTypeAction: controller.deleteEmailAddressType,
                        onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                        onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                        onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                        onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                      ),
                  ],
                )),
              )
            ),
            SubjectComposerWidget(
              focusNode: controller.subjectEmailInputFocusNode,
              textController: controller.subjectEmailInputController,
              onTextChange: controller.setSubjectEmail,
              padding: ComposerStyle.desktopSubjectPadding,
              margin: ComposerStyle.desktopSubjectMargin,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ComposerStyle.borderColor,
                      width: 1
                    )
                  ),
                  color: ComposerStyle.backgroundEditorColor
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  log('ComposerView::build:desktop:constraints: $constraints');
                  return Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: ComposerStyle.desktopEditorPadding,
                              child: Obx(() => WebEditorView(
                                editorController: controller.richTextWebController.editorController,
                                arguments: controller.composerArguments.value,
                                contentViewState: controller.emailContentsViewState.value,
                                currentWebContent: controller.textEditorWeb,
                                onInitial: controller.handleInitHtmlEditorWeb,
                                onChangeContent: controller.onChangeTextEditorWeb,
                                onFocus: controller.handleOnFocusHtmlEditorWeb,
                                onUnFocus: controller.handleOnUnFocusHtmlEditorWeb,
                                onMouseDown: controller.handleOnMouseDownHtmlEditorWeb,
                                onEditorSettings: controller.richTextWebController.onEditorSettingsChange,
                                onImageUploadSuccessAction: (fileUpload) => controller.handleImageUploadSuccess(context, fileUpload),
                                onImageUploadFailureAction: (fileUpload, base64Str, uploadError) {
                                  return controller.handleImageUploadFailure(
                                    context: context,
                                    uploadError: uploadError,
                                    fileUpload: fileUpload,
                                    base64Str: base64Str,
                                  );
                                },
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                              )),
                            ),
                          ),
                          Obx(() {
                            if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                              return AttachmentComposerWidget(
                                listFileUploaded: controller.uploadController.listUploadAttachments,
                                isCollapsed: controller.isAttachmentCollapsed,
                                onDeleteAttachmentAction: (fileState) => controller.deleteAttachmentUploaded(fileState.uploadTaskId),
                                onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.richTextWebController.isFormattingOptionsEnabled) {
                              return ToolbarRichTextWebBuilder(
                                richTextWebController: controller.richTextWebController,
                                padding: ComposerStyle.richToolbarPadding,
                                decoration: const BoxDecoration(
                                  color: ComposerStyle.richToolbarColor,
                                  boxShadow: ComposerStyle.richToolbarShadow
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          })
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Obx(() => InsertImageLoadingBarWidget(
                          uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                          viewState: controller.viewState.value,
                          padding: ComposerStyle.insertImageLoadingBarPadding,
                        )),
                      ),
                    ],
                  );
                }),
              ),
            ),
            Obx(() => BottomBarComposerWidget(
              isCodeViewEnabled: controller.richTextWebController.codeViewEnabled,
              isFormattingOptionsEnabled: controller.richTextWebController.isFormattingOptionsEnabled,
              openRichToolbarAction: controller.richTextWebController.toggleFormattingOptions,
              attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
              insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
              showCodeViewAction: controller.richTextWebController.toggleCodeView,
              deleteComposerAction: () => controller.closeComposer(context),
              saveToDraftAction: () => controller.saveToDraftAction(context),
              sendMessageAction: () => controller.sendEmailAction(context),
              requestReadReceiptAction: (position) {
                controller.openPopupMenuAction(
                  context,
                  position,
                  _createReadReceiptPopupItems(context),
                  radius: ComposerStyle.popupMenuRadius
                );
              },
            )),
          ]);
        },
        displayMode: controller.screenDisplayMode.value,
        emailSubject: controller.subjectEmail.value ?? '',
        onCloseViewAction: () => controller.saveToDraftAndClose(context),
        onChangeDisplayModeAction: controller.displayScreenTypeComposerAction,
      )),
      tablet: TabletResponsiveContainerView(
        childBuilder: (context, constraints) {
          return Column(children: [
            Obx(() => DesktopAppBarComposerWidget(
              emailSubject: controller.subjectEmail.value ?? '',
              onCloseViewAction: () => controller.saveToDraftAndClose(context),
              constraints: constraints,
            )),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(
                  context,
                  constraints,
                  _responsiveUtils
                )
              ),
              child: SingleChildScrollView(
                controller: controller.scrollControllerEmailAddress,
                child: Obx(() => Column(
                  children: [
                    RecipientComposerWidget(
                      prefix: PrefixEmailAddress.to,
                      listEmailAddress: controller.listToEmailAddress,
                      ccState: controller.ccRecipientState.value,
                      bccState: controller.bccRecipientState.value,
                      expandMode: controller.toAddressExpandMode.value,
                      controller: controller.toEmailAddressController,
                      focusNode: controller.toAddressFocusNode,
                      autoDisposeFocusNode: false,
                      keyTagEditor: controller.keyToEmailTagEditor,
                      isInitial: controller.isInitialRecipient.value,
                      padding: ComposerStyle.tabletRecipientPadding,
                      margin: ComposerStyle.tabletRecipientMargin,
                      nextFocusNode: controller.getNextFocusOfToEmailAddress(),
                      onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                      onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                      onAddEmailAddressTypeAction: controller.addEmailAddressType,
                      onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                      onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                      onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                      onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                    ),
                    if (controller.ccRecipientState.value == PrefixRecipientState.enabled)
                      RecipientComposerWidget(
                        prefix: PrefixEmailAddress.cc,
                        listEmailAddress: controller.listCcEmailAddress,
                        expandMode: controller.ccAddressExpandMode.value,
                        controller: controller.ccEmailAddressController,
                        focusNode: controller.ccAddressFocusNode,
                        autoDisposeFocusNode: false,
                        keyTagEditor: controller.keyCcEmailTagEditor,
                        isInitial: controller.isInitialRecipient.value,
                        nextFocusNode: controller.getNextFocusOfCcEmailAddress(),
                        padding: ComposerStyle.tabletRecipientPadding,
                        margin: ComposerStyle.tabletRecipientMargin,
                        onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                        onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                        onDeleteEmailAddressTypeAction: controller.deleteEmailAddressType,
                        onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                        onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                        onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                        onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                      ),
                    if (controller.bccRecipientState.value == PrefixRecipientState.enabled)
                      RecipientComposerWidget(
                        prefix: PrefixEmailAddress.bcc,
                        listEmailAddress: controller.listBccEmailAddress,
                        expandMode: controller.bccAddressExpandMode.value,
                        controller: controller.bccEmailAddressController,
                        focusNode: controller.bccAddressFocusNode,
                        autoDisposeFocusNode: false,
                        keyTagEditor: controller.keyBccEmailTagEditor,
                        isInitial: controller.isInitialRecipient.value,
                        nextFocusNode: controller.subjectEmailInputFocusNode,
                        padding: ComposerStyle.tabletRecipientPadding,
                        margin: ComposerStyle.tabletRecipientMargin,
                        onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
                        onShowFullListEmailAddressAction: controller.showFullEmailAddress,
                        onDeleteEmailAddressTypeAction: controller.deleteEmailAddressType,
                        onUpdateListEmailAddressAction: controller.updateListEmailAddress,
                        onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
                        onFocusNextAddressAction: controller.handleFocusNextAddressAction,
                        onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
                      ),
                  ],
                )),
              )
            ),
            SubjectComposerWidget(
              focusNode: controller.subjectEmailInputFocusNode,
              textController: controller.subjectEmailInputController,
              onTextChange: controller.setSubjectEmail,
              padding: ComposerStyle.tabletSubjectPadding,
              margin: ComposerStyle.tabletSubjectMargin,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ComposerStyle.borderColor,
                      width: 1
                    )
                  ),
                  color: ComposerStyle.backgroundEditorColor
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  log('ComposerView::build:tablet:constraints: $constraints');
                  return Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: ComposerStyle.tabletEditorPadding,
                              child: Obx(() => WebEditorView(
                                editorController: controller.richTextWebController.editorController,
                                arguments: controller.composerArguments.value,
                                contentViewState: controller.emailContentsViewState.value,
                                currentWebContent: controller.textEditorWeb,
                                onInitial: controller.handleInitHtmlEditorWeb,
                                onChangeContent: controller.onChangeTextEditorWeb,
                                onFocus: controller.handleOnFocusHtmlEditorWeb,
                                onUnFocus: controller.handleOnUnFocusHtmlEditorWeb,
                                onMouseDown: controller.handleOnMouseDownHtmlEditorWeb,
                                onEditorSettings: controller.richTextWebController.onEditorSettingsChange,
                                onImageUploadSuccessAction: (fileUpload) => controller.handleImageUploadSuccess(context, fileUpload),
                                onImageUploadFailureAction: (fileUpload, base64Str, uploadError) {
                                  return controller.handleImageUploadFailure(
                                    context: context,
                                    uploadError: uploadError,
                                    fileUpload: fileUpload,
                                    base64Str: base64Str,
                                  );
                                },
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                              )),
                            ),
                          ),
                          Obx(() {
                            if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                              return AttachmentComposerWidget(
                                listFileUploaded: controller.uploadController.listUploadAttachments,
                                isCollapsed: controller.isAttachmentCollapsed,
                                onDeleteAttachmentAction: (fileState) => controller.deleteAttachmentUploaded(fileState.uploadTaskId),
                                onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.richTextWebController.isFormattingOptionsEnabled) {
                              return ToolbarRichTextWebBuilder(
                                richTextWebController: controller.richTextWebController,
                                padding: ComposerStyle.richToolbarPadding,
                                decoration: const BoxDecoration(
                                  color: ComposerStyle.richToolbarColor,
                                  boxShadow: ComposerStyle.richToolbarShadow
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          })
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Obx(() => InsertImageLoadingBarWidget(
                          uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                          viewState: controller.viewState.value,
                          padding: ComposerStyle.insertImageLoadingBarPadding,
                        )),
                      ),
                    ],
                  );
                }),
              ),
            ),
            Obx(() => BottomBarComposerWidget(
              isCodeViewEnabled: controller.richTextWebController.codeViewEnabled,
              isFormattingOptionsEnabled: controller.richTextWebController.isFormattingOptionsEnabled,
              openRichToolbarAction: controller.richTextWebController.toggleFormattingOptions,
              attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
              insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
              showCodeViewAction: controller.richTextWebController.toggleCodeView,
              deleteComposerAction: () => controller.closeComposer(context),
              saveToDraftAction: () => controller.saveToDraftAction(context),
              sendMessageAction: () => controller.sendEmailAction(context),
              requestReadReceiptAction: (position) {
                controller.openPopupMenuAction(
                  context,
                  position,
                  _createReadReceiptPopupItems(context),
                  radius: ComposerStyle.popupMenuRadius
                );
              },
            )),
          ]);
        },
      )
    );
  }

  List<PopupMenuEntry> _createReadReceiptPopupItems(BuildContext context) {
    return [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          _imagePaths.icReadReceipt,
          AppLocalizations.of(context).requestReadReceipt,
          styleName: ComposerStyle.popupItemTextStyle,
          padding: ComposerStyle.popupItemPadding,
          selectedIcon: _imagePaths.icFilterSelected,
          isSelected: controller.hasRequestReadReceipt.value,
          onCallbackAction: () {
            popBack();
            controller.toggleRequestReadReceipt();
          }
        )
      ),
    ];
  }

  List<PopupMenuEntry> _createMoreOptionPopupItems(BuildContext context) {
    return [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          _imagePaths.icStyleCodeView,
          AppLocalizations.of(context).embedCode,
          styleName: ComposerStyle.popupItemTextStyle,
          colorIcon: ComposerStyle.popupItemIconColor,
          padding: ComposerStyle.popupItemPadding,
          selectedIcon: _imagePaths.icFilterSelected,
          isSelected: controller.richTextWebController.codeViewEnabled,
          onCallbackAction: () {
            popBack();
            controller.richTextWebController.toggleCodeView();
          }
        )
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          _imagePaths.icReadReceipt,
          AppLocalizations.of(context).requestReadReceipt,
          styleName: ComposerStyle.popupItemTextStyle,
          padding: ComposerStyle.popupItemPadding,
          colorIcon: ComposerStyle.popupItemIconColor,
          selectedIcon: _imagePaths.icFilterSelected,
          isSelected: controller.hasRequestReadReceipt.value,
          onCallbackAction: () {
            popBack();
            controller.toggleRequestReadReceipt();
          }
        )
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          _imagePaths.icSaveToDraft,
          AppLocalizations.of(context).saveAsDraft,
          colorIcon: ComposerStyle.popupItemIconColor,
          styleName: ComposerStyle.popupItemTextStyle,
          padding: ComposerStyle.popupItemPadding,
          onCallbackAction: () {
            popBack();
            controller.saveToDraftAction(context);
          }
        )
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          _imagePaths.icDeleteMailbox,
          AppLocalizations.of(context).delete,
          styleName: ComposerStyle.popupItemTextStyle,
          padding: ComposerStyle.popupItemPadding,
          onCallbackAction: () {
            popBack();
            controller.closeComposer(context);
          },
        )
      ),
    ];
  }
}