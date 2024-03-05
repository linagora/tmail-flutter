import 'package:core/presentation/views/context_menu/simple_context_menu_action_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/tablet_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/insert_image_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_mobile_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/landscape_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/mobile_attachment_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/tablet_bottom_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/desktop_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/from_composer_drop_down_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ComposerView extends GetWidget<ComposerController> {

  const ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: controller.responsiveUtils,
      mobile: MobileContainerView(
        keyboardRichTextController: controller.keyboardRichTextController,
        onCloseViewAction: () => controller.handleClickCloseComposer(context),
        onClearFocusAction: () => controller.clearFocus(context),
        onAttachFileAction: () => controller.isNetworkConnectionAvailable
          ? controller.openPickAttachmentMenu(
              context,
              _pickAttachmentsActionTiles(context)
            )
          : null,
        onInsertImageAction: (constraints) => controller.isNetworkConnectionAvailable
          ? controller.insertImage(context, constraints.maxWidth)
          : null,
        backgroundColor: MobileAppBarComposerWidgetStyle.backgroundColor,
        childBuilder: (context) => SafeArea(
          left: !controller.responsiveUtils.isLandscapeMobile(context),
          right: !controller.responsiveUtils.isLandscapeMobile(context),
          child: Container(
            color: ComposerStyle.mobileBackgroundColor,
            child: Column(
              children: [
                if (controller.responsiveUtils.isLandscapeMobile(context))
                  Obx(() => LandscapeAppBarComposerWidget(
                    isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                    onCloseViewAction: () => controller.handleClickCloseComposer(context),
                    sendMessageAction: () => controller.handleClickSendButton(context),
                    openContextMenuAction: (position) {
                      controller.openPopupMenuAction(
                        context,
                        position,
                        _createMoreOptionPopupItems(context),
                        radius: ComposerStyle.popupMenuRadius
                      );
                    },
                  ))
                else
                  Obx(() => AppBarComposerWidget(
                    isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                    onCloseViewAction: () => controller.handleClickCloseComposer(context),
                    sendMessageAction: () => controller.handleClickSendButton(context),
                    openContextMenuAction: (position) {
                      controller.openPopupMenuAction(
                        context,
                        position,
                        _createMoreOptionPopupItems(context),
                        radius: ComposerStyle.popupMenuRadius
                      );
                    },
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
                          Obx(() {
                            if (controller.fromRecipientState.value == PrefixRecipientState.enabled) {
                              return  FromComposerMobileWidget(
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
                          Obx(() => RecipientComposerWidget(
                            prefix: PrefixEmailAddress.to,
                            listEmailAddress: controller.listToEmailAddress,
                            fromState: controller.fromRecipientState.value,
                            ccState: controller.ccRecipientState.value,
                            bccState: controller.bccRecipientState.value,
                            expandMode: controller.toAddressExpandMode.value,
                            controller: controller.toEmailAddressController,
                            focusNode: controller.toAddressFocusNode,
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
                          )),
                          Obx(() {
                            if (controller.ccRecipientState.value == PrefixRecipientState.enabled) {
                              return RecipientComposerWidget(
                                prefix: PrefixEmailAddress.cc,
                                listEmailAddress: controller.listCcEmailAddress,
                                expandMode: controller.ccAddressExpandMode.value,
                                controller: controller.ccEmailAddressController,
                                focusNode: controller.ccAddressFocusNode,
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
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                          Obx(() {
                            if (controller.bccRecipientState.value == PrefixRecipientState.enabled) {
                              return RecipientComposerWidget(
                                prefix: PrefixEmailAddress.bcc,
                                listEmailAddress: controller.listBccEmailAddress,
                                expandMode: controller.bccAddressExpandMode.value,
                                controller: controller.bccEmailAddressController,
                                focusNode: controller.bccAddressFocusNode,
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
                            onTapOutside: controller.onTapOutsideSubject,
                          ),
                          Obx(() => Center(
                            child: InsertImageLoadingBarWidget(
                              uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                              viewState: controller.viewState.value,
                              padding: ComposerStyle.insertImageLoadingBarPadding,
                            ),
                          )),
                          Obx(() => Padding(
                            padding: ComposerStyle.mobileEditorPadding,
                            child: MobileEditorView(
                              arguments: controller.composerArguments.value,
                              contentViewState: controller.emailContentsViewState.value,
                              onCreatedEditorAction: controller.onCreatedMobileEditorAction,
                              onLoadCompletedEditorAction: controller.onLoadCompletedMobileEditorAction,
                            ),
                          )),
                          Obx(() {
                            if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                              return MobileAttachmentComposerWidget(
                                listFileUploaded: controller.uploadController.listUploadAttachments,
                                onDeleteAttachmentAction: (fileState) => controller.deleteAttachmentUploaded(fileState.uploadTaskId),
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
        onCloseViewAction: () => controller.handleClickCloseComposer(context),
        onClearFocusAction: () => controller.clearFocus(context),
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
                onCloseViewAction: () => controller.handleClickCloseComposer(context),
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
                          RecipientComposerWidget(
                            prefix: PrefixEmailAddress.to,
                            listEmailAddress: controller.listToEmailAddress,
                            fromState: controller.fromRecipientState.value,
                            ccState: controller.ccRecipientState.value,
                            bccState: controller.bccRecipientState.value,
                            expandMode: controller.toAddressExpandMode.value,
                            controller: controller.toEmailAddressController,
                            focusNode: controller.toAddressFocusNode,
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
                        onTapOutside: controller.onTapOutsideSubject,
                      ),
                      Obx(() => Center(
                        child: InsertImageLoadingBarWidget(
                          uploadInlineViewState: controller.uploadController.uploadInlineViewState.value,
                          viewState: controller.viewState.value,
                          padding: ComposerStyle.insertImageLoadingBarPadding,
                        ),
                      )),
                      Obx(() => Padding(
                        padding: ComposerStyle.mobileEditorPadding,
                        child: MobileEditorView(
                          arguments: controller.composerArguments.value,
                          contentViewState: controller.emailContentsViewState.value,
                          onCreatedEditorAction: controller.onCreatedMobileEditorAction,
                          onLoadCompletedEditorAction: controller.onLoadCompletedMobileEditorAction,
                        ),
                      )),
                      Obx(() {
                        if (controller.uploadController.listUploadAttachments.isNotEmpty) {
                          return MobileAttachmentComposerWidget(
                            listFileUploaded: controller.uploadController.listUploadAttachments,
                            onDeleteAttachmentAction: (fileState) => controller.deleteAttachmentUploaded(fileState.uploadTaskId),
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
                deleteComposerAction: () => controller.handleClickDeleteComposer(context),
                saveToDraftAction: () => controller.handleClickSaveAsDraftsButton(context),
                sendMessageAction: () => controller.handleClickSendButton(context),
                requestReadReceiptAction: (position) {
                  controller.openPopupMenuAction(
                    context,
                    position,
                    _createReadReceiptPopupItems(context),
                    radius: ComposerStyle.popupMenuRadius
                  );
                },
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

  List<PopupMenuEntry> _createReadReceiptPopupItems(BuildContext context) {
    return [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          controller.imagePaths.icReadReceipt,
          AppLocalizations.of(context).requestReadReceipt,
          styleName: ComposerStyle.popupItemTextStyle,
          padding: ComposerStyle.popupItemPadding,
          selectedIcon: controller.imagePaths.icFilterSelected,
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
          controller.imagePaths.icReadReceipt,
          AppLocalizations.of(context).requestReadReceipt,
          styleName: ComposerStyle.popupItemTextStyle,
          padding: ComposerStyle.popupItemPadding,
          colorIcon: ComposerStyle.popupItemIconColor,
          selectedIcon: controller.imagePaths.icFilterSelected,
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
          controller.imagePaths.icSaveToDraft,
          AppLocalizations.of(context).saveAsDraft,
          colorIcon: ComposerStyle.popupItemIconColor,
          styleName: ComposerStyle.popupItemTextStyle,
          padding: ComposerStyle.popupItemPadding,
          onCallbackAction: () {
            popBack();
            controller.handleClickSaveAsDraftsButton(context);
          }
        )
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          controller.imagePaths.icDeleteMailbox,
          AppLocalizations.of(context).delete,
          styleName: ComposerStyle.popupItemTextStyle,
          padding: ComposerStyle.popupItemPadding,
          onCallbackAction: () {
            popBack();
            controller.handleClickDeleteComposer(context);
          },
        )
      ),
    ];
  }
}