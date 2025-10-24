import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/base/widget/dialog_picker/color_dialog_picker.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/composer_print_draft_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_edit_recipient_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_recipients_collapsed_extensions.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/mark_as_important_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/preview_composer_attachment_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/remove_draggable_email_address_between_recipient_fields_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/desktop_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/mobile_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/tablet_responsive_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/web_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/insert_image_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/list_recipients_collapsed_widget.dart';
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
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/toolbar_rich_text_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/verify_display_overlay_view_on_iframe_extension.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';

class ComposerView extends GetWidget<ComposerController> {

  final String? composerId;

  const ComposerView({super.key, this.composerId});

  @override
  ComposerController get controller => Get.find<ComposerController>(tag: composerId);

  @override
  Widget build(BuildContext context) {
    final iframeOverlay = Obx(() {
      bool isOverlayEnabled = controller.mailboxDashBoardController.isDisplayedOverlayViewOnIFrame ||
          MessageDialogActionManager().isDialogOpened ||
          ColorDialogPicker().isOpened.isTrue ||
          DialogRouter.isRuleFilterDialogOpened.isTrue ||
          DialogRouter.isDialogOpened;

      if (isOverlayEnabled) {
        return Positioned.fill(
          key: const ValueKey('tap-to-close'),
          child: PointerInterceptor(
            child: const SizedBox.expand(),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });

    return ResponsiveWidget(
      responsiveUtils: controller.responsiveUtils,
      mobile: MobileResponsiveContainerView(
        childBuilder: (_, constraints) {
          return GestureDetector(
            onTap: () => controller.clickOutsideComposer(context),
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
                  isMarkAsImportant: controller.isMarkAsImportant.value,
                  isEmailChanged: controller.isEmailChanged.value,
                  menuMoreOptionController: controller.menuMoreOptionController!,
                  onCloseViewAction: () => controller.handleClickCloseComposer(context),
                  attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
                  insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                  sendMessageAction: () => controller.handleClickSendButton(context),
                  toggleCodeViewAction: controller.richTextWebController!.toggleCodeView,
                  printDraftAction: () => controller.printDraft(context),
                  toggleRequestReadReceiptAction: () => controller.toggleRequestReadReceipt(context),
                  toggleMarkAsImportantAction: () => controller.toggleMarkAsImportant(context),
                  saveToDraftsAction: () => controller.handleClickSaveAsDraftsButton(context),
                  saveToTemplateAction: () => controller.handleClickSaveAsTemplateButton(context),
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
                        if (controller.recipientsCollapsedState.value == PrefixRecipientState.enabled)
                          RecipientsCollapsedComposerWidget(
                            listEmailAddress: controller.allListEmailAddressWithoutReplyTo,
                            margin: ComposerStyle.mobileRecipientMargin,
                            onShowAllRecipientsAction: controller.showFullRecipients,
                          ),
                        if (controller.toRecipientState.value == PrefixRecipientState.enabled)
                          _buildRecipientComposerWidget(
                            composerId: composerId,
                            prefix: PrefixEmailAddress.to,
                            controller: controller,
                            maxWidth: constraints.maxWidth,
                            listEmailAddress: controller.listToEmailAddress,
                            textController: controller.toEmailAddressController,
                            focusNode: controller.toAddressFocusNode,
                            focusNodeKeyboard: controller.toAddressFocusNodeKeyboard,
                            keyTagEditor: controller.keyToEmailTagEditor,
                            nextFocusNode: controller.getNextFocusOfToEmailAddress(),
                            isMobile: true,
                          ),
                        if (controller.ccRecipientState.value == PrefixRecipientState.enabled)
                          _buildRecipientComposerWidget(
                            composerId: composerId,
                            prefix: PrefixEmailAddress.cc,
                            controller: controller,
                            maxWidth: constraints.maxWidth,
                            listEmailAddress: controller.listCcEmailAddress,
                            textController: controller.ccEmailAddressController,
                            focusNode: controller.ccAddressFocusNode,
                            focusNodeKeyboard: controller.ccAddressFocusNodeKeyboard,
                            keyTagEditor: controller.keyCcEmailTagEditor,
                            nextFocusNode: controller.getNextFocusOfCcEmailAddress(),
                            isMobile: true,
                          ),
                        if (controller.bccRecipientState.value == PrefixRecipientState.enabled)
                          _buildRecipientComposerWidget(
                            composerId: composerId,
                            prefix: PrefixEmailAddress.bcc,
                            controller: controller,
                            maxWidth: constraints.maxWidth,
                            listEmailAddress: controller.listBccEmailAddress,
                            textController: controller.bccEmailAddressController,
                            focusNode: controller.bccAddressFocusNode,
                            focusNodeKeyboard: controller.bccAddressFocusNodeKeyboard,
                            keyTagEditor: controller.keyBccEmailTagEditor,
                            nextFocusNode: controller.getNextFocusOfBccEmailAddress(),
                            isMobile: true,
                          ),
                        if (controller.replyToRecipientState.value == PrefixRecipientState.enabled)
                          _buildRecipientComposerWidget(
                            composerId: composerId,
                            prefix: PrefixEmailAddress.replyTo,
                            controller: controller,
                            maxWidth: constraints.maxWidth,
                            listEmailAddress: controller.listReplyToEmailAddress,
                            textController: controller.replyToEmailAddressController,
                            focusNode: controller.replyToAddressFocusNode,
                            focusNodeKeyboard: controller.replyToAddressFocusNodeKeyboard,
                            keyTagEditor: controller.keyReplyToEmailTagEditor,
                            nextFocusNode: controller.subjectEmailInputFocusNode,
                            isMobile: true,
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
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (_, constraintsEditor) {
                                return Obx(() => WebEditorView(
                                  key: controller.responsiveContainerKey,
                                  editorController: controller.richTextWebController!.editorController,
                                  arguments: controller.composerArguments.value,
                                  contentViewState: controller.emailContentsViewState.value,
                                  currentWebContent: controller.textEditorWeb,
                                  onInitial: controller.handleInitHtmlEditorWeb,
                                  onChangeContent: controller.onChangeTextEditorWeb,
                                  onFocus: controller.handleOnFocusHtmlEditorWeb,
                                  onEditorSettings: controller.richTextWebController!.onEditorSettingsChange,
                                  onEditorTextSizeChanged: controller.richTextWebController!.onEditorTextSizeChanged,
                                  height: constraintsEditor.maxHeight,
                                  horizontalPadding: ComposerStyle.mobileEditorHorizontalPadding,
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
                                  onInitialContentLoadComplete: controller.onInitialContentLoadCompleteWeb,
                                ));
                              }
                            ),
                          ),
                          Obx(() {
                            if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                              return AttachmentComposerWidget(
                                listFileUploaded: controller.uploadController.listUploadAttachments,
                                isCollapsed: controller.isAttachmentCollapsed,
                                onDeleteAttachmentAction: controller.deleteAttachmentUploaded,
                                onPreviewAttachmentAction: (id) =>
                                    controller.previewAttachment(context, id),
                                onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.richTextWebController!.isFormattingOptionsEnabled) {
                              return ToolbarRichTextWidget(
                                richTextController: controller.richTextWebController!,
                                imagePaths: controller.imagePaths,
                                padding: ComposerStyle.richToolbarPadding,
                                decoration: const BoxDecoration(
                                  color: ComposerStyle.richToolbarColor,
                                  boxShadow: ComposerStyle.richToolbarShadow,
                                ),
                                isMobile: controller.responsiveUtils.isMobile(context),
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
                          margin: ComposerStyle.insertImageLoadingBarMargin,
                        )),
                      ),
                      iframeOverlay,
                      Obx(() {
                        if (controller.mailboxDashBoardController.isAttachmentDraggableAppActive) {
                          return Positioned.fill(
                            child: PointerInterceptor(
                              child: AttachmentDropZoneWidget(
                                imagePaths: controller.imagePaths,
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
                                onLocalFileDropZoneListener: (details) =>
                                  controller.onLocalFileDropZoneListener(
                                    context: context,
                                    details: details,
                                    maxWidth: constraints.maxWidth,
                                  ),
                              )
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ],
                  ),
                ),
              ]
            ),
          );
        }
      ),
      desktop: Obx(() => DesktopResponsiveContainerView(
        childBuilder: (_, constraints) {
          return GestureDetector(
            onTap: () => controller.clickOutsideComposer(context),
            child: Column(children: [
              Obx(() => DesktopAppBarComposerWidget(
                imagePaths: controller.imagePaths,
                emailSubject: controller.subjectEmail.value ?? '',
                displayMode: controller.screenDisplayMode.value,
                onCloseViewAction: () => controller.handleClickCloseComposer(context),
                onChangeDisplayModeAction: controller.displayScreenTypeComposerAction,
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
                      if (controller.recipientsCollapsedState.value == PrefixRecipientState.enabled)
                        RecipientsCollapsedComposerWidget(
                          listEmailAddress: controller.allListEmailAddressWithoutReplyTo,
                          margin: ComposerStyle.desktopRecipientMargin,
                          onShowAllRecipientsAction: controller.showFullRecipients,
                        ),
                      if (controller.toRecipientState.value == PrefixRecipientState.enabled)
                        _buildRecipientComposerWidget(
                          composerId: composerId,
                          prefix: PrefixEmailAddress.to,
                          controller: controller,
                          maxWidth: constraints.maxWidth,
                          listEmailAddress: controller.listToEmailAddress,
                          textController: controller.toEmailAddressController,
                          focusNode: controller.toAddressFocusNode,
                          focusNodeKeyboard: controller.toAddressFocusNodeKeyboard,
                          keyTagEditor: controller.keyToEmailTagEditor,
                          nextFocusNode: controller.getNextFocusOfToEmailAddress(),
                        ),
                      if (controller.ccRecipientState.value == PrefixRecipientState.enabled)
                        _buildRecipientComposerWidget(
                          composerId: composerId,
                          prefix: PrefixEmailAddress.cc,
                          controller: controller,
                          maxWidth: constraints.maxWidth,
                          listEmailAddress: controller.listCcEmailAddress,
                          textController: controller.ccEmailAddressController,
                          focusNode: controller.ccAddressFocusNode,
                          focusNodeKeyboard: controller.ccAddressFocusNodeKeyboard,
                          keyTagEditor: controller.keyCcEmailTagEditor,
                          nextFocusNode: controller.getNextFocusOfCcEmailAddress(),
                        ),
                      if (controller.bccRecipientState.value == PrefixRecipientState.enabled)
                        _buildRecipientComposerWidget(
                          composerId: composerId,
                          prefix: PrefixEmailAddress.bcc,
                          controller: controller,
                          maxWidth: constraints.maxWidth,
                          listEmailAddress: controller.listBccEmailAddress,
                          textController: controller.bccEmailAddressController,
                          focusNode: controller.bccAddressFocusNode,
                          focusNodeKeyboard: controller.bccAddressFocusNodeKeyboard,
                          keyTagEditor: controller.keyBccEmailTagEditor,
                          nextFocusNode: controller.getNextFocusOfBccEmailAddress(),
                        ),
                      if (controller.replyToRecipientState.value == PrefixRecipientState.enabled)
                        _buildRecipientComposerWidget(
                          composerId: composerId,
                          prefix: PrefixEmailAddress.replyTo,
                          controller: controller,
                          maxWidth: constraints.maxWidth,
                          listEmailAddress: controller.listReplyToEmailAddress,
                          textController: controller.replyToEmailAddressController,
                          focusNode: controller.replyToAddressFocusNode,
                          focusNodeKeyboard: controller.replyToAddressFocusNodeKeyboard,
                          keyTagEditor: controller.keyReplyToEmailTagEditor,
                          nextFocusNode: controller.subjectEmailInputFocusNode,
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
                child: Stack(
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
                                  child: LayoutBuilder(
                                    builder: (_, constraintsEditor) {
                                      return Obx(() {
                                        return WebEditorView(
                                          key: controller.responsiveContainerKey,
                                          editorController: controller.richTextWebController!.editorController,
                                          arguments: controller.composerArguments.value,
                                          contentViewState: controller.emailContentsViewState.value,
                                          currentWebContent: controller.textEditorWeb,
                                          onInitial: controller.handleInitHtmlEditorWeb,
                                          onChangeContent: controller.onChangeTextEditorWeb,
                                          onFocus: controller.handleOnFocusHtmlEditorWeb,
                                          onEditorSettings: controller.richTextWebController?.onEditorSettingsChange,
                                          onEditorTextSizeChanged: controller.richTextWebController?.onEditorTextSizeChanged,
                                          height: constraintsEditor.maxHeight,
                                          horizontalPadding: ComposerStyle.desktopEditorHorizontalPadding,
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
                                          onInitialContentLoadComplete: controller.onInitialContentLoadCompleteWeb,
                                        );
                                      });
                                    }
                                  ),
                                ),
                                Obx(() {
                                  if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                                    return AttachmentComposerWidget(
                                      listFileUploaded: controller.uploadController.listUploadAttachments,
                                      isCollapsed: controller.isAttachmentCollapsed,
                                      onDeleteAttachmentAction: controller.deleteAttachmentUploaded,
                                      onPreviewAttachmentAction: (id) =>
                                          controller.previewAttachment(context, id),
                                      onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }),
                                Obx(() {
                                  if (controller.richTextWebController!.isFormattingOptionsEnabled) {
                                    return ToolbarRichTextWidget(
                                      richTextController: controller.richTextWebController!,
                                      imagePaths: controller.imagePaths,
                                      padding: ComposerStyle.richToolbarPadding,
                                      decoration: const BoxDecoration(
                                        color: ComposerStyle.richToolbarColor,
                                        boxShadow: ComposerStyle.richToolbarShadow,
                                      ),
                                      isMobile: controller.responsiveUtils.isMobile(context),
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
                          isMarkAsImportant: controller.isMarkAsImportant.value,
                          openRichToolbarAction: controller.richTextWebController!.toggleFormattingOptions,
                          attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
                          insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                          deleteComposerAction: () => controller.handleClickDeleteComposer(context),
                          saveToDraftAction: () => controller.handleClickSaveAsDraftsButton(context),
                          sendMessageAction: () => controller.handleClickSendButton(context),
                          isEmailChanged: controller.isEmailChanged.isTrue,
                          toggleCodeViewAction: controller.richTextWebController!.toggleCodeView,
                          menuMoreOptionController: controller.menuMoreOptionController!,
                          onPopupMenuChanged: controller.onPopupMenuChanged,
                          printDraftAction: () => controller.printDraft(context),
                          toggleRequestReadReceiptAction: () => controller.toggleRequestReadReceipt(context),
                          toggleMarkAsImportantAction: () => controller.toggleMarkAsImportant(context),
                          saveAsTemplateAction: () => controller.handleClickSaveAsTemplateButton(context),
                        )),
                      ],
                    ),
                    Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Obx(() => InsertImageLoadingBarWidget(
                        uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                        viewState: controller.viewState.value,
                        margin: ComposerStyle.insertImageLoadingBarMargin,
                      )),
                    ),
                    iframeOverlay,
                    Obx(() {
                      if (controller.mailboxDashBoardController.isAttachmentDraggableAppActive) {
                        return Positioned.fill(
                          child: PointerInterceptor(
                            child: AttachmentDropZoneWidget(
                              imagePaths: controller.imagePaths,
                              onAttachmentDropZoneListener:
                                  controller.onAttachmentDropZoneListener,
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
                              onLocalFileDropZoneListener: (details) =>
                                controller.onLocalFileDropZoneListener(
                                  context: context,
                                  details: details,
                                  maxWidth: constraints.maxWidth,
                                ),
                            )
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ]),
          );
        },
        composerManager: controller.mailboxDashBoardController.composerManager,
        responsiveUtils: controller.responsiveUtils,
        imagePaths: controller.imagePaths,
        displayMode: controller.screenDisplayMode.value,
        emailSubject: controller.subjectEmail.value ?? '',
        onCloseViewAction: () => controller.handleClickCloseComposer(context),
        onChangeDisplayModeAction: controller.displayScreenTypeComposerAction,
      )),
      tablet: TabletResponsiveContainerView(
        childBuilder: (_, constraints) {
          return GestureDetector(
            onTap: () => controller.clickOutsideComposer(context),
            child: Column(children: [
              Obx(() => DesktopAppBarComposerWidget(
                imagePaths: controller.imagePaths,
                emailSubject: controller.subjectEmail.value ?? '',
                onCloseViewAction: () => controller.handleClickCloseComposer(context),
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
                      if (controller.recipientsCollapsedState.value == PrefixRecipientState.enabled)
                        RecipientsCollapsedComposerWidget(
                          listEmailAddress: controller.allListEmailAddressWithoutReplyTo,
                          margin: ComposerStyle.desktopRecipientMargin,
                          onShowAllRecipientsAction: controller.showFullRecipients,
                        ),
                      if (controller.toRecipientState.value == PrefixRecipientState.enabled)
                        _buildRecipientComposerWidget(
                          composerId: composerId,
                          prefix: PrefixEmailAddress.to,
                          controller: controller,
                          maxWidth: constraints.maxWidth,
                          listEmailAddress: controller.listToEmailAddress,
                          textController: controller.toEmailAddressController,
                          focusNode: controller.toAddressFocusNode,
                          focusNodeKeyboard: controller.toAddressFocusNodeKeyboard,
                          keyTagEditor: controller.keyToEmailTagEditor,
                          nextFocusNode: controller.getNextFocusOfToEmailAddress(),
                        ),
                      if (controller.ccRecipientState.value == PrefixRecipientState.enabled)
                        _buildRecipientComposerWidget(
                          composerId: composerId,
                          prefix: PrefixEmailAddress.cc,
                          controller: controller,
                          maxWidth: constraints.maxWidth,
                          listEmailAddress: controller.listCcEmailAddress,
                          textController: controller.ccEmailAddressController,
                          focusNode: controller.ccAddressFocusNode,
                          focusNodeKeyboard: controller.ccAddressFocusNodeKeyboard,
                          keyTagEditor: controller.keyCcEmailTagEditor,
                          nextFocusNode: controller.getNextFocusOfCcEmailAddress(),
                        ),
                      if (controller.bccRecipientState.value == PrefixRecipientState.enabled)
                        _buildRecipientComposerWidget(
                          composerId: composerId,
                          prefix: PrefixEmailAddress.bcc,
                          controller: controller,
                          maxWidth: constraints.maxWidth,
                          listEmailAddress: controller.listBccEmailAddress,
                          textController: controller.bccEmailAddressController,
                          focusNode: controller.bccAddressFocusNode,
                          focusNodeKeyboard: controller.bccAddressFocusNodeKeyboard,
                          keyTagEditor: controller.keyBccEmailTagEditor,
                          nextFocusNode: controller.getNextFocusOfBccEmailAddress(),
                        ),
                      if (controller.replyToRecipientState.value == PrefixRecipientState.enabled)
                        _buildRecipientComposerWidget(
                          composerId: composerId,
                          prefix: PrefixEmailAddress.replyTo,
                          controller: controller,
                          maxWidth: constraints.maxWidth,
                          listEmailAddress: controller.listReplyToEmailAddress,
                          textController: controller.replyToEmailAddressController,
                          focusNode: controller.replyToAddressFocusNode,
                          focusNodeKeyboard: controller.replyToAddressFocusNodeKeyboard,
                          keyTagEditor: controller.keyReplyToEmailTagEditor,
                          nextFocusNode: controller.subjectEmailInputFocusNode,
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
                child: Stack(
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
                                  child: LayoutBuilder(
                                    builder: (_, constraintsBody) {
                                      return Obx(() => WebEditorView(
                                        key: controller.responsiveContainerKey,
                                        editorController: controller.richTextWebController!.editorController,
                                        arguments: controller.composerArguments.value,
                                        contentViewState: controller.emailContentsViewState.value,
                                        currentWebContent: controller.textEditorWeb,
                                        onInitial: controller.handleInitHtmlEditorWeb,
                                        onChangeContent: controller.onChangeTextEditorWeb,
                                        onFocus: controller.handleOnFocusHtmlEditorWeb,
                                        onEditorSettings: controller.richTextWebController!.onEditorSettingsChange,
                                        onEditorTextSizeChanged: controller.richTextWebController!.onEditorTextSizeChanged,
                                        height: constraintsBody.maxHeight,
                                        horizontalPadding: ComposerStyle.desktopEditorHorizontalPadding,
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
                                        onInitialContentLoadComplete: controller.onInitialContentLoadCompleteWeb,
                                      ));
                                    }
                                  ),
                                ),
                                Obx(() {
                                  if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                                    return AttachmentComposerWidget(
                                      listFileUploaded: controller.uploadController.listUploadAttachments,
                                      isCollapsed: controller.isAttachmentCollapsed,
                                      onDeleteAttachmentAction: controller.deleteAttachmentUploaded,
                                      onPreviewAttachmentAction: (id) =>
                                          controller.previewAttachment(context, id),
                                      onToggleExpandAttachmentAction: (isCollapsed) => controller.isAttachmentCollapsed = isCollapsed,
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }),
                                Obx(() {
                                  if (controller.richTextWebController!.isFormattingOptionsEnabled) {
                                    return ToolbarRichTextWidget(
                                      richTextController: controller.richTextWebController!,
                                      imagePaths: controller.imagePaths,
                                      padding: ComposerStyle.richToolbarPadding,
                                      decoration: const BoxDecoration(
                                        color: ComposerStyle.richToolbarColor,
                                        boxShadow: ComposerStyle.richToolbarShadow,
                                      ),
                                      isMobile: controller.responsiveUtils.isMobile(context),
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
                          isMarkAsImportant: controller.isMarkAsImportant.value,
                          openRichToolbarAction: controller.richTextWebController!.toggleFormattingOptions,
                          attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
                          insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                          deleteComposerAction: () => controller.handleClickDeleteComposer(context),
                          saveToDraftAction: () => controller.handleClickSaveAsDraftsButton(context),
                          sendMessageAction: () => controller.handleClickSendButton(context),
                          isEmailChanged: controller.isEmailChanged.isTrue,
                          toggleCodeViewAction: controller.richTextWebController!.toggleCodeView,
                          menuMoreOptionController: controller.menuMoreOptionController!,
                          onPopupMenuChanged: controller.onPopupMenuChanged,
                          printDraftAction: () => controller.printDraft(context),
                          toggleRequestReadReceiptAction: () => controller.toggleRequestReadReceipt(context),
                          toggleMarkAsImportantAction: () => controller.toggleMarkAsImportant(context),
                          saveAsTemplateAction: () => controller.handleClickSaveAsTemplateButton(context),
                        )),
                      ],
                    ),
                    Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Obx(() => InsertImageLoadingBarWidget(
                        uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                        viewState: controller.viewState.value,
                        margin: ComposerStyle.insertImageLoadingBarMargin,
                      )),
                    ),
                    iframeOverlay,
                    Obx(() {
                      if (controller.mailboxDashBoardController.isAttachmentDraggableAppActive) {
                        return Positioned.fill(
                          child: PointerInterceptor(
                            child: AttachmentDropZoneWidget(
                              imagePaths: controller.imagePaths,
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
                              onLocalFileDropZoneListener: (details) =>
                                controller.onLocalFileDropZoneListener(
                                  context: context,
                                  details: details,
                                  maxWidth: constraints.maxWidth,
                                ),
                            )
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              )
            ]),
          );
        },
      )
    );
  }

  Widget _buildRecipientComposerWidget({
    required String? composerId,
    required PrefixEmailAddress prefix,
    required ComposerController controller,
    required double maxWidth,
    required List<EmailAddress> listEmailAddress,
    required TextEditingController textController,
    required FocusNode? focusNode,
    required FocusNode? focusNodeKeyboard,
    required GlobalKey keyTagEditor,
    required FocusNode? nextFocusNode,
    bool isMobile = false,
  }) {
    return Obx(() => RecipientComposerWidget(
      composerId: composerId,
      prefix: prefix,
      prefixRootState: controller.prefixRootState.value,
      fromState: controller.fromRecipientState.value,
      toState: controller.toRecipientState.value,
      ccState: controller.ccRecipientState.value,
      bccState: controller.bccRecipientState.value,
      replyToState: controller.replyToRecipientState.value,
      listEmailAddress: listEmailAddress,
      imagePaths: controller.imagePaths,
      maxWidth: maxWidth,
      minInputLengthAutocomplete: controller.minInputLengthAutocomplete,
      controller: textController,
      focusNode: focusNode,
      focusNodeKeyboard: focusNodeKeyboard,
      keyTagEditor: keyTagEditor,
      isInitial: controller.isInitialRecipient.value,
      nextFocusNode: nextFocusNode,
      padding: isMobile
          ? ComposerStyle.mobileRecipientPadding
          : ComposerStyle.desktopRecipientPadding,
      margin: isMobile
          ? ComposerStyle.mobileRecipientMargin
          : ComposerStyle.desktopRecipientMargin,
      onFocusEmailAddressChangeAction: controller.onEmailAddressFocusChange,
      onUpdateListEmailAddressAction: controller.updateListEmailAddress,
      onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
      onFocusNextAddressAction: controller.handleFocusNextAddressAction,
      onRemoveDraggableEmailAddressAction: controller.removeDraggableEmailAddress,
      onEditRecipientAction: controller.onEditRecipient,
      onClearFocusAction: controller.onClearFocusAction,
      onAddEmailAddressTypeAction: controller.addEmailAddressType,
      onDeleteEmailAddressTypeAction: controller.deleteEmailAddressType,
      onEnableAllRecipientsInputAction: controller.handleEnableRecipientsInputAction,
    ));
  }
}