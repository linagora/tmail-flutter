import 'package:core/presentation/views/context_menu/simple_context_menu_action_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/ai_scribe/handle_ai_scribe_in_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_content_height_exceeded_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_edit_recipient_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_open_context_menu_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_recipients_collapsed_extensions.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/mark_as_important_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/remove_draggable_email_address_between_recipient_fields_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/tablet_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/ai_scribe/composer_ai_scribe_selection_overlay.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/insert_image_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/list_recipients_collapsed_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_mobile_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/landscape_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/mobile_attachment_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/tablet_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/tablet_bottom_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/from_composer_drop_down_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/view_entire_message_with_message_clipped_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ComposerView extends GetWidget<ComposerController> {

  const ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: controller.responsiveUtils,
      mobile: MobileContainerView(
        onCloseViewAction: () => controller.handleClickCloseComposer(context),
        onClearFocusAction: controller.clearFocus,
        backgroundColor: MobileAppBarComposerWidgetStyle.backgroundColor,
        childBuilder: (_, constraints) => SafeArea(
          left: !controller.responsiveUtils.isLandscapeMobile(context),
          right: !controller.responsiveUtils.isLandscapeMobile(context),
          child: Container(
            color: ComposerStyle.mobileBackgroundColor,
            child: Column(
              children: [
                if (controller.responsiveUtils.isLandscapeMobile(context))
                  Obx(() => LandscapeAppBarComposerWidget(
                    imagePaths: controller.imagePaths,
                    isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                    onCloseViewAction: () => controller.handleClickCloseComposer(context),
                    sendMessageAction: () => controller.handleClickSendButton(context),
                    openContextMenuAction: (position) {
                      controller.handleOpenContextMenu(context, position);
                    },
                    isNetworkConnectionAvailable: controller.isNetworkConnectionAvailable,
                    onOpenAiAssistantModal: controller.isAIScribeAvailable
                      ? controller.openAIAssistantModal
                      : null,
                    attachFileAction: () => controller.openPickAttachmentMenu(
                      context,
                      _pickAttachmentsActionTiles(context)
                    ),
                    insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                    openRichToolbarAction: () =>
                      controller.richTextMobileTabletController?.showFormatStyleBottomSheet(
                        context: context,
                        richTextController: controller.richTextMobileTabletController?.richTextController
                      ),
                  ))
                else
                  Obx(() => AppBarComposerWidget(
                    imagePaths: controller.imagePaths,
                    isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                    onCloseViewAction: () => controller.handleClickCloseComposer(context),
                    sendMessageAction: () => controller.handleClickSendButton(context),
                    openContextMenuAction: (position) {
                      controller.handleOpenContextMenu(context, position);
                    },
                    isNetworkConnectionAvailable: controller.isNetworkConnectionAvailable,
                    onOpenAiAssistantModal: controller.isAIScribeAvailable
                      ? controller.openAIAssistantModal
                      : null,
                    attachFileAction: () => controller.openPickAttachmentMenu(
                      context,
                      _pickAttachmentsActionTiles(context)
                    ),
                    insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                    openRichToolbarAction: () =>
                      controller.richTextMobileTabletController?.showFormatStyleBottomSheet(
                        context: context,
                        richTextController: controller.richTextMobileTabletController?.richTextController
                      ),
                  )),
                Expanded(
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            key: controller.headerEditorMobileWidgetKey,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() {
                                if (controller.fromRecipientState.value == PrefixRecipientState.enabled) {
                                  return FromComposerMobileWidget(
                                      selectedIdentity: controller.identitySelected.value,
                                      imagePaths: controller.imagePaths,
                                      responsiveUtils: controller.responsiveUtils,
                                      margin: ComposerStyle.mobileRecipientMargin,
                                      padding: ComposerStyle.mobileRecipientPadding,
                                      onTap: () => controller.openSelectIdentityBottomSheet(context)
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              Obx(() {
                                if (controller.recipientsCollapsedState.value == PrefixRecipientState.enabled) {
                                  return RecipientsCollapsedComposerWidget(
                                    listEmailAddress: controller.allListEmailAddressWithoutReplyTo,
                                    margin: ComposerStyle.mobileRecipientMargin,
                                    onShowAllRecipientsAction: controller.showFullRecipients,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              Obx(() {
                                if (controller.toRecipientState.value == PrefixRecipientState.enabled) {
                                  return _buildRecipientComposerWidget(
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
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              Obx(() {
                                if (controller.ccRecipientState.value == PrefixRecipientState.enabled) {
                                  return _buildRecipientComposerWidget(
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
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              Obx(() {
                                if (controller.bccRecipientState.value == PrefixRecipientState.enabled) {
                                  return _buildRecipientComposerWidget(
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
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              Obx(() {
                                if (controller.replyToRecipientState.value == PrefixRecipientState.enabled) {
                                  return _buildRecipientComposerWidget(
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
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              SubjectComposerWidget(
                                focusNode: controller.subjectEmailInputFocusNode,
                                textController: controller.subjectEmailInputController,
                                onTextChange: controller.setSubjectEmail,
                                padding: ComposerStyle.mobileSubjectPadding,
                                margin: ComposerStyle.mobileSubjectMargin,
                              ),
                              Obx(() {
                                if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                                  return MobileAttachmentComposerWidget(
                                    listFileUploaded: controller.uploadController.listUploadAttachments,
                                    onDeleteAttachmentAction: controller.deleteAttachmentUploaded,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              Obx(() => Center(
                                child: InsertImageLoadingBarWidget(
                                  uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                                  viewState: controller.viewState.value,
                                  margin: ComposerStyle.insertImageLoadingBarMargin,
                                ),
                              ))
                            ],
                          ),
                          Stack(
                            children: [
                              Column(
                                children: [
                                  Obx(() => Padding(
                                    padding: ComposerStyle.mobileEditorPadding,
                                    child: MobileEditorView(
                                      arguments: controller.composerArguments.value,
                                      contentViewState: controller.emailContentsViewState.value,
                                      onCreatedEditorAction: controller.onCreatedMobileEditorAction,
                                      onLoadCompletedEditorAction: controller.onLoadCompletedMobileEditorAction,
                                      onEditorContentHeightChanged: controller.onEditorContentHeightChangedOnIOS,
                                      onTextSelectionChanged: controller.textSelectionHandler,
                                    ),
                                  )),
                                  Obx(() {
                                    if (controller.isContentHeightExceeded.isTrue && PlatformInfo.isIOS) {
                                      return ViewEntireMessageWithMessageClippedWidget(
                                        buttonActionName: AppLocalizations.of(context).viewEntireMessage.toUpperCase(),
                                        onViewEntireMessageAction: controller.viewEntireContent,
                                        topPadding: 12,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                                  SizedBox(height: MediaQuery.viewInsetsOf(context).bottom + 64),
                                ],
                              ),
                              ComposerAiScribeSelectionOverlay(controller: controller),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                )
              ])
          ),
        ),
      ),
      tablet: TabletContainerView(
        keyboardRichTextController: controller.richTextMobileTabletController!.richTextController,
        onCloseViewAction: () => controller.handleClickCloseComposer(context),
        onClearFocusAction: controller.clearFocus,
        childBuilder: (_, constraints) => ColoredBox(
          color: ComposerStyle.mobileBackgroundColor,
          child: Column(
            children: [
              Obx(() => TabletAppBarComposerWidget(
                imagePaths: controller.imagePaths,
                emailSubject: controller.subjectEmail.value ?? '',
                onCloseViewAction: () => controller.handleClickCloseComposer(context),
                constraints: constraints,
                isNetworkConnectionAvailable: controller.isNetworkConnectionAvailable,
                attachFileAction: () => controller.openPickAttachmentMenu(
                  context,
                  _pickAttachmentsActionTiles(context)
                ),
                insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
              )),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Column(
                        children: [
                          if (controller.fromRecipientState.value == PrefixRecipientState.enabled)
                            FromComposerDropDownWidget(
                              items: controller.listFromIdentities,
                              itemSelected: controller.identitySelected.value,
                              dropdownKey: controller.identityDropdownKey,
                              imagePaths: controller.imagePaths,
                              padding: ComposerStyle.mobileRecipientPadding,
                              margin: ComposerStyle.mobileRecipientMargin,
                              onChangeIdentity: controller.onChangeIdentity,
                            ),
                          Obx(() {
                            if (controller.recipientsCollapsedState.value == PrefixRecipientState.enabled) {
                              return RecipientsCollapsedComposerWidget(
                                listEmailAddress: controller.allListEmailAddressWithoutReplyTo,
                                margin: ComposerStyle.mobileRecipientMargin,
                                onShowAllRecipientsAction: controller.showFullRecipients,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.toRecipientState.value == PrefixRecipientState.enabled) {
                              return _buildRecipientComposerWidget(
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
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.ccRecipientState.value == PrefixRecipientState.enabled) {
                              return _buildRecipientComposerWidget(
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
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.bccRecipientState.value == PrefixRecipientState.enabled) {
                              return _buildRecipientComposerWidget(
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
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.replyToRecipientState.value == PrefixRecipientState.enabled) {
                              return _buildRecipientComposerWidget(
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
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                        ],
                      )),
                      SubjectComposerWidget(
                        focusNode: controller.subjectEmailInputFocusNode,
                        textController: controller.subjectEmailInputController,
                        onTextChange: controller.setSubjectEmail,
                        padding: ComposerStyle.mobileSubjectPadding,
                        margin: ComposerStyle.mobileSubjectMargin,
                      ),
                      Obx(() {
                        if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                          return MobileAttachmentComposerWidget(
                            listFileUploaded: controller.uploadController.listUploadAttachments,
                            onDeleteAttachmentAction: controller.deleteAttachmentUploaded,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                      Obx(() => Center(
                        child: InsertImageLoadingBarWidget(
                          uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                          viewState: controller.viewState.value,
                          margin: ComposerStyle.insertImageLoadingBarMargin,
                        ),
                      )),
                      Stack(
                        children: [
                          Column(
                            children: [
                              Obx(() => Padding(
                                padding: ComposerStyle.mobileEditorPadding,
                                child: MobileEditorView(
                                  arguments: controller.composerArguments.value,
                                  contentViewState: controller.emailContentsViewState.value,
                                  onCreatedEditorAction: controller.onCreatedMobileEditorAction,
                                  onLoadCompletedEditorAction: controller.onLoadCompletedMobileEditorAction,
                                  onEditorContentHeightChanged: controller.onEditorContentHeightChangedOnIOS,
                                  onTextSelectionChanged: controller.textSelectionHandler,
                                ),
                              )),
                              Obx(() {
                                if (controller.isContentHeightExceeded.isTrue && PlatformInfo.isIOS) {
                                  return ViewEntireMessageWithMessageClippedWidget(
                                    buttonActionName: AppLocalizations.of(context).viewEntireMessage.toUpperCase(),
                                    onViewEntireMessageAction: controller.viewEntireContent,
                                    topPadding: 12,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              SizedBox(height: MediaQuery.viewInsetsOf(context).bottom + 64),
                            ],
                          ),
                          ComposerAiScribeSelectionOverlay(controller: controller),
                        ],
                      ),
                    ],
                  ),
                )
              ),
              Obx(() => TabletBottomBarComposerWidget(
                imagePaths: controller.imagePaths,
                hasReadReceipt: controller.hasRequestReadReceipt.value,
                isMarkAsImportant: controller.isMarkAsImportant.value,
                deleteComposerAction: controller.handleClickDeleteComposer,
                saveToDraftAction: () => controller.handleClickSaveAsDraftsButton(context),
                sendMessageAction: () => controller.handleClickSendButton(context),
                requestReadReceiptAction: () => controller.toggleRequestReadReceipt(context),
                toggleMarkAsImportantAction: () => controller.toggleMarkAsImportant(context),
                onOpenAiAssistantModal: controller.isAIScribeAvailable
                    ? controller.openAIAssistantModal
                    : null,
              )),
            ]
          )
        ),
      ),
    );
  }

  List<Widget> _pickAttachmentsActionTiles(BuildContext context) {
    return [
      _pickPhotoAndVideoAction(context),
      _browseFileAction(context),
      const SizedBox(height: kIsWeb ? 16 : 30),
    ];
  }

  Widget _pickPhotoAndVideoAction(BuildContext context) {
    return (SimpleContextMenuActionBuilder(
            const Key('pick_photo_and_video_context_menu_action'),
            SvgPicture.asset(controller.imagePaths.icPhotoLibrary, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).photos_and_videos)
        ..onActionClick((_) => controller.openFilePickerByType(context, FileType.media)))
      .build();
  }

  Widget _browseFileAction(BuildContext context) {
    return (SimpleContextMenuActionBuilder(
            const Key('browse_file_context_menu_action'),
            SvgPicture.asset(controller.imagePaths.icMore, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).browse)
        ..onActionClick((_) => controller.openFilePickerByType(context, FileType.any)))
      .build();
  }

  Widget _buildRecipientComposerWidget({
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
      onEnableAllRecipientsInputAction: controller.handleEnableRecipientsInputOnMobileAction,
    ));
  }
}