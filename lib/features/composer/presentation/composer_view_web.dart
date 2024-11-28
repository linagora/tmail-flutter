import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/composer_print_draft_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/desktop_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/mobile_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/tablet_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/web_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/insert_image_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_mobile_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/attachment_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/attachment_drop_zone_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/bottom_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/desktop_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/from_composer_drop_down_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/local_file_drop_zone_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/mobile_responsive_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/toolbar_rich_text_builder.dart';

class ComposerView extends GetWidget<ComposerController> {

  const ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: controller.responsiveUtils,
      mobile: MobileResponsiveContainerView(
        childBuilder: (context, constraints) {
          return GestureDetector(
            onTap: () => controller.clearFocus(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => MobileResponsiveAppBarComposerWidget(
                  imagePaths: controller.imagePaths,
                  isCodeViewEnabled: controller.richTextWebController!.codeViewEnabled,
                  isFormattingOptionsEnabled: controller.richTextWebController!.isFormattingOptionsEnabled,
                  openRichToolbarAction: controller.richTextWebController!.toggleFormattingOptions,
                  isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                  hasRequestReadReceipt: controller.hasRequestReadReceipt.value,
                  isEmailChanged: controller.isEmailChanged.value,
                  menuMoreOptionController: controller.menuMoreOptionController!,
                  onCloseViewAction: () => controller.handleClickCloseComposer(context),
                  attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
                  insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                  sendMessageAction: () => controller.handleClickSendButton(context),
                  toggleCodeViewAction: controller.richTextWebController!.toggleCodeView,
                  printDraftAction: () => controller.printDraft(context),
                  toggleRequestReadReceiptAction: () => controller.toggleRequestReadReceipt(context),
                  saveToDraftsAction: () => controller.handleClickSaveAsDraftsButton(context),
                  deleteComposerAction: () => controller.handleClickDeleteComposer(context),
                )),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(
                      context,
                      constraints,
                      controller.responsiveUtils
                    )
                  ),
                  child: SingleChildScrollView(
                    controller: controller.scrollControllerEmailAddress,
                    child: Obx(() => Column(
                      children: [
                        if (controller.fromRecipientState.value == PrefixRecipientState.enabled)
                          Tooltip(
                            message: controller.identitySelected.value?.email ?? '',
                            child: FromComposerMobileWidget(
                              selectedIdentity: controller.identitySelected.value,
                              imagePaths: controller.imagePaths,
                              responsiveUtils: controller.responsiveUtils,
                              margin: ComposerStyle.mobileRecipientMargin,
                              padding: ComposerStyle.mobileRecipientPadding,
                              onTap: () => controller.openSelectIdentityBottomSheet(context)
                            ),
                          ),
                        RecipientComposerWidget(
                          prefix: PrefixEmailAddress.to,
                          listEmailAddress: controller.listToEmailAddress,
                          imagePaths: controller.imagePaths,
                          maxWidth: constraints.maxWidth,
                          minInputLengthAutocomplete: controller
                            .mailboxDashBoardController
                            .minInputLengthAutocomplete,
                          fromState: controller.fromRecipientState.value,
                          ccState: controller.ccRecipientState.value,
                          bccState: controller.bccRecipientState.value,
                          expandMode: controller.toAddressExpandMode.value,
                          controller: controller.toEmailAddressController,
                          focusNode: controller.toAddressFocusNode,
                          focusNodeKeyboard: controller.toAddressFocusNodeKeyboard,
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
                            imagePaths: controller.imagePaths,
                            maxWidth: constraints.maxWidth,
                            minInputLengthAutocomplete: controller
                              .mailboxDashBoardController
                              .minInputLengthAutocomplete,
                            expandMode: controller.ccAddressExpandMode.value,
                            controller: controller.ccEmailAddressController,
                            focusNode: controller.ccAddressFocusNode,
                            focusNodeKeyboard: controller.ccAddressFocusNodeKeyboard,
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
                            imagePaths: controller.imagePaths,
                            maxWidth: constraints.maxWidth,
                            minInputLengthAutocomplete: controller
                              .mailboxDashBoardController
                              .minInputLengthAutocomplete,
                            expandMode: controller.bccAddressExpandMode.value,
                            controller: controller.bccEmailAddressController,
                            focusNode: controller.bccAddressFocusNode,
                            focusNodeKeyboard: controller.bccAddressFocusNodeKeyboard,
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
                  child: LayoutBuilder(
                    builder: (context, constraintsEditor) {
                      return Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: ComposerStyle.mobileEditorPadding,
                                  child: Obx(() => WebEditorView(
                                    key: controller.responsiveContainerKey,
                                    editorController: controller.richTextWebController!.editorController,
                                    arguments: controller.composerArguments.value,
                                    contentViewState: controller.emailContentsViewState.value,
                                    currentWebContent: controller.textEditorWeb,
                                    onInitial: controller.handleInitHtmlEditorWeb,
                                    onChangeContent: controller.onChangeTextEditorWeb,
                                    onFocus: controller.handleOnFocusHtmlEditorWeb,
                                    onMouseDown: controller.handleOnMouseDownHtmlEditorWeb,
                                    onEditorSettings: controller.richTextWebController!.onEditorSettingsChange,
                                    onEditorTextSizeChanged: controller.richTextWebController!.onEditorTextSizeChanged,
                                    height: constraints.maxHeight,
                                    onDragEnter: controller.handleOnDragEnterHtmlEditorWeb,
                                    onDragOver: controller.handleOnDragOverHtmlEditorWeb,
                                    onPasteImageSuccessAction: (listFileUpload) => controller.handleOnPasteImageSuccessAction(
                                      context: context,
                                      maxWidth: constraintsEditor.maxWidth,
                                      listFileUpload: listFileUpload
                                    ),
                                    onPasteImageFailureAction: (listFileUpload, base64, uploadError) =>
                                      controller.handleOnPasteImageFailureAction(
                                        context: context,
                                        listFileUpload: listFileUpload,
                                        base64: base64,
                                        uploadError: uploadError
                                      ),
                                    onInitialContentLoadComplete: controller.restoreCollapsibleButton,
                                  )),
                                ),
                              ),
                              Obx(() {
                                if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                                  return AttachmentComposerWidget(
                                    listFileUploaded: controller.uploadController.listUploadAttachments,
                                    isCollapsed: controller.isAttachmentCollapsed,
                                    onDeleteAttachmentAction: controller.deleteAttachmentUploaded,
                                    onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              Obx(() {
                                if (controller.richTextWebController!.isFormattingOptionsEnabled) {
                                  return ToolbarRichTextWebBuilder(
                                    richTextWebController: controller.richTextWebController!,
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
                          Obx(() {
                            if (controller.mailboxDashBoardController.isAttachmentDraggableAppActive) {
                              return Positioned.fill(
                                child: PointerInterceptor(
                                  child: AttachmentDropZoneWidget(
                                    imagePaths: controller.imagePaths,
                                    width: constraintsEditor.maxWidth,
                                    height: constraintsEditor.maxHeight,
                                    onAttachmentDropZoneListener: controller.onAttachmentDropZoneListener,
                                  )
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.mailboxDashBoardController.isLocalFileDraggableAppActive) {
                              return Positioned.fill(
                                child: PointerInterceptor(
                                  child: LocalFileDropZoneWidget(
                                    imagePaths: controller.imagePaths,
                                    width: constraintsEditor.maxWidth,
                                    height: constraintsEditor.maxHeight,
                                    onLocalFileDropZoneListener: (details) =>
                                      controller.onLocalFileDropZoneListener(
                                        context: context,
                                        details: details,
                                        maxWidth: constraintsEditor.maxWidth,
                                      ),
                                  )
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                        ],
                      );
                    }
                  ),
                ),
              ]
            ),
          );
        }
      ),
      desktop: Obx(() => DesktopResponsiveContainerView(
        childBuilder: (context, constraints) {
          return GestureDetector(
            onTap: () => controller.clearFocus(context),
            child: Column(children: [
              Obx(() => DesktopAppBarComposerWidget(
                emailSubject: controller.subjectEmail.value ?? '',
                displayMode: controller.screenDisplayMode.value,
                onCloseViewAction: () => controller.handleClickCloseComposer(context),
                onChangeDisplayModeAction: controller.displayScreenTypeComposerAction,
                constraints: constraints,
              )),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(
                    context,
                    constraints,
                    controller.responsiveUtils
                  )
                ),
                child: SingleChildScrollView(
                  controller: controller.scrollControllerEmailAddress,
                  child: Obx(() => Column(
                    children: [
                      if (controller.fromRecipientState.value == PrefixRecipientState.enabled)
                        FromComposerDropDownWidget(
                          items: controller.listFromIdentities,
                          itemSelected: controller.identitySelected.value,
                          dropdownKey: controller.identityDropdownKey,
                          imagePaths: controller.imagePaths,
                          padding: ComposerStyle.desktopRecipientPadding,
                          margin: ComposerStyle.desktopRecipientMargin,
                          onChangeIdentity: controller.onChangeIdentity,
                        ),
                      RecipientComposerWidget(
                        prefix: PrefixEmailAddress.to,
                        listEmailAddress: controller.listToEmailAddress,
                        imagePaths: controller.imagePaths,
                        maxWidth: constraints.maxWidth,
                        minInputLengthAutocomplete: controller
                          .mailboxDashBoardController
                          .minInputLengthAutocomplete,
                        fromState: controller.fromRecipientState.value,
                        ccState: controller.ccRecipientState.value,
                        bccState: controller.bccRecipientState.value,
                        expandMode: controller.toAddressExpandMode.value,
                        controller: controller.toEmailAddressController,
                        focusNode: controller.toAddressFocusNode,
                        focusNodeKeyboard: controller.toAddressFocusNodeKeyboard,
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
                          imagePaths: controller.imagePaths,
                          maxWidth: constraints.maxWidth,
                          minInputLengthAutocomplete: controller
                            .mailboxDashBoardController
                            .minInputLengthAutocomplete,
                          expandMode: controller.ccAddressExpandMode.value,
                          controller: controller.ccEmailAddressController,
                          focusNode: controller.ccAddressFocusNode,
                          focusNodeKeyboard: controller.ccAddressFocusNodeKeyboard,
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
                          imagePaths: controller.imagePaths,
                          maxWidth: constraints.maxWidth,
                          minInputLengthAutocomplete: controller
                            .mailboxDashBoardController
                            .minInputLengthAutocomplete,
                          expandMode: controller.bccAddressExpandMode.value,
                          controller: controller.bccEmailAddressController,
                          focusNode: controller.bccAddressFocusNode,
                          focusNodeKeyboard: controller.bccAddressFocusNodeKeyboard,
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
                child: LayoutBuilder(
                  builder: (context, constraintsEditor) {
                    return Stack(
                      children: [
                        Column(
                          children: [
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
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: ComposerStyle.desktopEditorPadding,
                                        child: Obx(() {
                                          return WebEditorView(
                                            key: controller.responsiveContainerKey,
                                            editorController: controller.richTextWebController!.editorController,
                                            arguments: controller.composerArguments.value,
                                            contentViewState: controller.emailContentsViewState.value,
                                            currentWebContent: controller.textEditorWeb,
                                            onInitial: controller.handleInitHtmlEditorWeb,
                                            onChangeContent: controller.onChangeTextEditorWeb,
                                            onFocus: controller.handleOnFocusHtmlEditorWeb,
                                            onMouseDown: controller.handleOnMouseDownHtmlEditorWeb,
                                            onEditorSettings: controller.richTextWebController?.onEditorSettingsChange,
                                            onEditorTextSizeChanged: controller.richTextWebController?.onEditorTextSizeChanged,
                                            height: constraints.maxHeight,
                                            onDragEnter: controller.handleOnDragEnterHtmlEditorWeb,
                                            onDragOver: controller.handleOnDragOverHtmlEditorWeb,
                                            onPasteImageSuccessAction: (listFileUpload) => controller.handleOnPasteImageSuccessAction(
                                              context: context,
                                              maxWidth: constraintsEditor.maxWidth,
                                              listFileUpload: listFileUpload
                                            ),
                                            onPasteImageFailureAction: (listFileUpload, base64, uploadError) =>
                                              controller.handleOnPasteImageFailureAction(
                                                context: context,
                                                listFileUpload: listFileUpload,
                                                base64: base64,
                                                uploadError: uploadError
                                              ),
                                            onInitialContentLoadComplete: controller.restoreCollapsibleButton,
                                          );
                                        }),
                                      ),
                                    ),
                                    Obx(() {
                                      if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                                        return AttachmentComposerWidget(
                                          listFileUploaded: controller.uploadController.listUploadAttachments,
                                          isCollapsed: controller.isAttachmentCollapsed,
                                          onDeleteAttachmentAction: controller.deleteAttachmentUploaded,
                                          onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }),
                                    Obx(() {
                                      if (controller.richTextWebController!.isFormattingOptionsEnabled) {
                                        return ToolbarRichTextWebBuilder(
                                          richTextWebController: controller.richTextWebController!,
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
                              ),
                            ),
                            Obx(() => BottomBarComposerWidget(
                              imagePaths: controller.imagePaths,
                              isCodeViewEnabled: controller.richTextWebController!.codeViewEnabled,
                              isFormattingOptionsEnabled: controller.richTextWebController!.isFormattingOptionsEnabled,
                              hasReadReceipt: controller.hasRequestReadReceipt.value,
                              openRichToolbarAction: controller.richTextWebController!.toggleFormattingOptions,
                              attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
                              insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                              deleteComposerAction: () => controller.handleClickDeleteComposer(context),
                              saveToDraftAction: () => controller.handleClickSaveAsDraftsButton(context),
                              sendMessageAction: () => controller.handleClickSendButton(context),
                              isEmailChanged: controller.isEmailChanged.isTrue,
                              toggleCodeViewAction: controller.richTextWebController!.toggleCodeView,
                              menuMoreOptionController: controller.menuMoreOptionController!,
                              printDraftAction: () => controller.printDraft(context),
                              toggleRequestReadReceiptAction: () => controller.toggleRequestReadReceipt(context),
                            )),
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
                        Obx(() {
                          if (controller.mailboxDashBoardController.isAttachmentDraggableAppActive) {
                            return Positioned.fill(
                              child: PointerInterceptor(
                                child: AttachmentDropZoneWidget(
                                  imagePaths: controller.imagePaths,
                                  width: constraintsEditor.maxWidth,
                                  height: constraintsEditor.maxHeight,
                                  onAttachmentDropZoneListener: controller.onAttachmentDropZoneListener,
                                )
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        Obx(() {
                          if (controller.mailboxDashBoardController.isLocalFileDraggableAppActive) {
                            return Positioned.fill(
                              child: PointerInterceptor(
                                child: LocalFileDropZoneWidget(
                                  imagePaths: controller.imagePaths,
                                  width: constraintsEditor.maxWidth,
                                  height: constraintsEditor.maxHeight,
                                  onLocalFileDropZoneListener: (details) =>
                                    controller.onLocalFileDropZoneListener(
                                      context: context,
                                      details: details,
                                      maxWidth: constraintsEditor.maxWidth,
                                    ),
                                )
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                      ],
                    );
                  }
                ),
              ),
            ]),
          );
        },
        displayMode: controller.screenDisplayMode.value,
        emailSubject: controller.subjectEmail.value ?? '',
        onCloseViewAction: () => controller.handleClickCloseComposer(context),
        onChangeDisplayModeAction: controller.displayScreenTypeComposerAction,
      )),
      tablet: TabletResponsiveContainerView(
        childBuilder: (context, constraints) {
          return GestureDetector(
            onTap: () => controller.clearFocus(context),
            child: Column(children: [
              Obx(() => DesktopAppBarComposerWidget(
                emailSubject: controller.subjectEmail.value ?? '',
                onCloseViewAction: () => controller.handleClickCloseComposer(context),
                constraints: constraints,
              )),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(
                    context,
                    constraints,
                    controller.responsiveUtils
                  )
                ),
                child: SingleChildScrollView(
                  controller: controller.scrollControllerEmailAddress,
                  child: Obx(() => Column(
                    children: [
                      if (controller.fromRecipientState.value == PrefixRecipientState.enabled)
                        FromComposerDropDownWidget(
                          items: controller.listFromIdentities,
                          itemSelected: controller.identitySelected.value,
                          dropdownKey: controller.identityDropdownKey,
                          imagePaths: controller.imagePaths,
                          padding: ComposerStyle.tabletRecipientPadding,
                          margin: ComposerStyle.tabletRecipientMargin,
                          onChangeIdentity: controller.onChangeIdentity,
                        ),
                      RecipientComposerWidget(
                        prefix: PrefixEmailAddress.to,
                        listEmailAddress: controller.listToEmailAddress,
                        imagePaths: controller.imagePaths,
                        maxWidth: constraints.maxWidth,
                        minInputLengthAutocomplete: controller
                          .mailboxDashBoardController
                          .minInputLengthAutocomplete,
                        fromState: controller.fromRecipientState.value,
                        ccState: controller.ccRecipientState.value,
                        bccState: controller.bccRecipientState.value,
                        expandMode: controller.toAddressExpandMode.value,
                        controller: controller.toEmailAddressController,
                        focusNode: controller.toAddressFocusNode,
                        focusNodeKeyboard: controller.toAddressFocusNodeKeyboard,
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
                          imagePaths: controller.imagePaths,
                          maxWidth: constraints.maxWidth,
                          minInputLengthAutocomplete: controller
                            .mailboxDashBoardController
                            .minInputLengthAutocomplete,
                          expandMode: controller.ccAddressExpandMode.value,
                          controller: controller.ccEmailAddressController,
                          focusNode: controller.ccAddressFocusNode,
                          focusNodeKeyboard: controller.ccAddressFocusNodeKeyboard,
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
                          imagePaths: controller.imagePaths,
                          maxWidth: constraints.maxWidth,
                          minInputLengthAutocomplete: controller
                            .mailboxDashBoardController
                            .minInputLengthAutocomplete,
                          expandMode: controller.bccAddressExpandMode.value,
                          controller: controller.bccEmailAddressController,
                          focusNode: controller.bccAddressFocusNode,
                          focusNodeKeyboard: controller.bccAddressFocusNodeKeyboard,
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
                child: LayoutBuilder(
                  builder: (context, constraintsBody) {
                    return Stack(
                      children: [
                        Column(
                          children: [
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
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: ComposerStyle.tabletEditorPadding,
                                        child: Obx(() => WebEditorView(
                                          key: controller.responsiveContainerKey,
                                          editorController: controller.richTextWebController!.editorController,
                                          arguments: controller.composerArguments.value,
                                          contentViewState: controller.emailContentsViewState.value,
                                          currentWebContent: controller.textEditorWeb,
                                          onInitial: controller.handleInitHtmlEditorWeb,
                                          onChangeContent: controller.onChangeTextEditorWeb,
                                          onFocus: controller.handleOnFocusHtmlEditorWeb,
                                          onMouseDown: controller.handleOnMouseDownHtmlEditorWeb,
                                          onEditorSettings: controller.richTextWebController!.onEditorSettingsChange,
                                          onEditorTextSizeChanged: controller.richTextWebController!.onEditorTextSizeChanged,
                                          height: constraints.maxHeight,
                                          onDragEnter: controller.handleOnDragEnterHtmlEditorWeb,
                                          onDragOver: controller.handleOnDragOverHtmlEditorWeb,
                                          onPasteImageSuccessAction: (listFileUpload) => controller.handleOnPasteImageSuccessAction(
                                            context: context,
                                            maxWidth: constraintsBody.maxWidth,
                                            listFileUpload: listFileUpload
                                          ),
                                          onPasteImageFailureAction: (listFileUpload, base64, uploadError) =>
                                            controller.handleOnPasteImageFailureAction(
                                              context: context,
                                              listFileUpload: listFileUpload,
                                              base64: base64,
                                              uploadError: uploadError
                                            ),
                                          onInitialContentLoadComplete: controller.restoreCollapsibleButton,
                                        )),
                                      ),
                                    ),
                                    Obx(() {
                                      if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                                        return AttachmentComposerWidget(
                                          listFileUploaded: controller.uploadController.listUploadAttachments,
                                          isCollapsed: controller.isAttachmentCollapsed,
                                          onDeleteAttachmentAction: controller.deleteAttachmentUploaded,
                                          onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }),
                                    Obx(() {
                                      if (controller.richTextWebController!.isFormattingOptionsEnabled) {
                                        return ToolbarRichTextWebBuilder(
                                          richTextWebController: controller.richTextWebController!,
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
                              ),
                            ),
                            Obx(() => BottomBarComposerWidget(
                              imagePaths: controller.imagePaths,
                              isCodeViewEnabled: controller.richTextWebController!.codeViewEnabled,
                              isFormattingOptionsEnabled: controller.richTextWebController!.isFormattingOptionsEnabled,
                              hasReadReceipt: controller.hasRequestReadReceipt.value,
                              openRichToolbarAction: controller.richTextWebController!.toggleFormattingOptions,
                              attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
                              insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                              deleteComposerAction: () => controller.handleClickDeleteComposer(context),
                              saveToDraftAction: () => controller.handleClickSaveAsDraftsButton(context),
                              sendMessageAction: () => controller.handleClickSendButton(context),
                              isEmailChanged: controller.isEmailChanged.isTrue,
                              toggleCodeViewAction: controller.richTextWebController!.toggleCodeView,
                              menuMoreOptionController: controller.menuMoreOptionController!,
                              printDraftAction: () => controller.printDraft(context),
                              toggleRequestReadReceiptAction: () => controller.toggleRequestReadReceipt(context),
                            )),
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
                        Obx(() {
                          if (controller.mailboxDashBoardController.isAttachmentDraggableAppActive) {
                            return Positioned.fill(
                              child: PointerInterceptor(
                                child: AttachmentDropZoneWidget(
                                  imagePaths: controller.imagePaths,
                                  width: constraintsBody.maxWidth,
                                  height: constraintsBody.maxHeight,
                                  onAttachmentDropZoneListener: controller.onAttachmentDropZoneListener,
                                )
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        Obx(() {
                          if (controller.mailboxDashBoardController.isLocalFileDraggableAppActive) {
                            return Positioned.fill(
                              child: PointerInterceptor(
                                child: LocalFileDropZoneWidget(
                                  imagePaths: controller.imagePaths,
                                  width: constraintsBody.maxWidth,
                                  height: constraintsBody.maxHeight,
                                  onLocalFileDropZoneListener: (details) =>
                                    controller.onLocalFileDropZoneListener(
                                      context: context,
                                      details: details,
                                      maxWidth: constraintsBody.maxWidth,
                                    ),
                                )
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                      ],
                    );
                  },
                ),
              )
            ]),
          );
        },
      )
    );
  }
}