import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/context_menu/simple_context_menu_action_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/tablet_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/mobile_attachment_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/landscape_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/tablet_bottom_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/desktop_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ComposerView extends GetWidget<ComposerController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: _responsiveUtils,
      mobile: MobileContainerView(
        keyboardRichTextController: controller.keyboardRichTextController,
        onCloseViewAction: () => controller.saveToDraftAndClose(context, canPop: false),
        onClearFocusAction: () => controller.clearFocusEditor(context),
        onAttachFileAction: () => controller.isNetworkConnectionAvailable
          ? controller.openPickAttachmentMenu(
              context,
              _pickAttachmentsActionTiles(context)
            )
          : null,
        onInsertImageAction: (constraints) => controller.isNetworkConnectionAvailable
          ? controller.insertImage(context, constraints.maxWidth)
          : null,
        childBuilder: (context) => SafeArea(
          left: !_responsiveUtils.isLandscapeMobile(context),
          right: !_responsiveUtils.isLandscapeMobile(context),
          child: Container(
            color: ComposerStyle.mobileBackgroundColor,
            child: Column(
              children: [
                if (_responsiveUtils.isLandscapeMobile(context))
                  Obx(() => LandscapeAppBarComposerWidget(
                    isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                    onCloseViewAction: () => controller.saveToDraftAndClose(context),
                    sendMessageAction: () => controller.sendEmailAction(context),
                    openContextMenuAction: () => {},
                  ))
                else
                  Obx(() => AppBarComposerWidget(
                    isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                    onCloseViewAction: () => controller.saveToDraftAndClose(context),
                    sendMessageAction: () => controller.sendEmailAction(context),
                    openContextMenuAction: () => {},
                  )),
                Expanded(
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          Obx(() => Column(
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
                                ),
                            ],
                          )),
                          SubjectComposerWidget(
                            focusNode: controller.subjectEmailInputFocusNode,
                            textController: controller.subjectEmailInputController,
                            onTextChange: controller.setSubjectEmail,
                            padding: ComposerStyle.mobileSubjectPadding,
                            margin: ComposerStyle.mobileSubjectMargin,
                          ),
                          Obx(() => GestureDetector(
                            onTapDown: (_) {
                              controller.removeFocusAllInputEditorHeader();
                            },
                            child: Padding(
                              padding: ComposerStyle.mobileEditorPadding,
                              child: MobileEditorView(
                                arguments: controller.composerArguments.value,
                                contentViewState: controller.emailContentsViewState.value,
                                onCreatedEditorAction: controller.onCreatedMobileEditorAction,
                              ),
                            ),
                          )),
                          Obx(() {
                            if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                              return MobileAttachmentComposerWidget(
                                listFileUploaded: controller.uploadController.listUploadAttachments,
                                isShowMore: controller.isAttachmentCollapsed,
                                onDeleteAttachmentAction: (fileState) => controller.deleteAttachmentUploaded(fileState.uploadTaskId),
                                onShowMoreAttachmentAction: (isShowMore) => controller.isAttachmentCollapsed = !isShowMore,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          const SizedBox(height: ComposerStyle.keyboardMaxHeight),
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
        keyboardRichTextController: controller.keyboardRichTextController,
        onCloseViewAction: () => controller.saveToDraftAndClose(context, canPop: false),
        onClearFocusAction: () => controller.clearFocusEditor(context),
        onAttachFileAction: () => controller.isNetworkConnectionAvailable
          ? controller.openPickAttachmentMenu(
              context,
              _pickAttachmentsActionTiles(context)
            )
          : null,
        onInsertImageAction: (constraints) => controller.isNetworkConnectionAvailable
          ? controller.insertImage(context, constraints.maxWidth)
          : null,
        childBuilder: (context, constraints) => Container(
          color: ComposerStyle.mobileBackgroundColor,
          child: Column(
            children: [
              Obx(() => DesktopAppBarComposerWidget(
                emailSubject: controller.subjectEmail.value ?? '',
                onCloseViewAction: () => controller.saveToDraftAndClose(context),
                constraints: constraints,
              )),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Obx(() => Column(
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
                            ),
                        ],
                      )),
                      SubjectComposerWidget(
                        focusNode: controller.subjectEmailInputFocusNode,
                        textController: controller.subjectEmailInputController,
                        onTextChange: controller.setSubjectEmail,
                        padding: ComposerStyle.mobileSubjectPadding,
                        margin: ComposerStyle.mobileSubjectMargin,
                      ),
                      Obx(() => GestureDetector(
                        onTapDown: (_) {
                          controller.removeFocusAllInputEditorHeader();
                        },
                        child: Padding(
                          padding: ComposerStyle.mobileEditorPadding,
                          child: MobileEditorView(
                            arguments: controller.composerArguments.value,
                            contentViewState: controller.emailContentsViewState.value,
                            onCreatedEditorAction: controller.onCreatedMobileEditorAction,
                          ),
                        ),
                      )),
                      Obx(() {
                        if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                          return MobileAttachmentComposerWidget(
                            listFileUploaded: controller.uploadController.listUploadAttachments,
                            isShowMore: controller.isAttachmentCollapsed,
                            onDeleteAttachmentAction: (fileState) => controller.deleteAttachmentUploaded(fileState.uploadTaskId),
                            onShowMoreAttachmentAction: (isShowMore) => controller.isAttachmentCollapsed = !isShowMore,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      })
                    ],
                  ),
                )
              ),
              TabletBottomBarComposerWidget(
                deleteComposerAction: () => controller.closeComposer(context),
                saveToDraftAction: () => controller.saveToDraftAction(context),
                sendMessageAction: () => controller.sendEmailAction(context),
              ),
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
            SvgPicture.asset(_imagePaths.icPhotoLibrary, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).photos_and_videos)
        ..onActionClick((_) => controller.openFilePickerByType(context, FileType.media)))
      .build();
  }

  Widget _browseFileAction(BuildContext context) {
    return (SimpleContextMenuActionBuilder(
            const Key('browse_file_context_menu_action'),
            SvgPicture.asset(_imagePaths.icMore, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).browse)
        ..onActionClick((_) => controller.openFilePickerByType(context, FileType.any)))
      .build();
  }
}