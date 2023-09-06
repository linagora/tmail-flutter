import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/base_composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/desktop_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/tablet_container_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/bottom_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ComposerView extends BaseComposerView {

  ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: responsiveUtils,
      mobile: MobileContainerView(
        childBuilder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => MobileAppBarComposerWidget(
                isCodeViewEnabled: controller.richTextWebController.codeViewEnabled,
                isFormattingOptionsEnabled: controller.richTextWebController.isFormattingOptionsEnabled,
                openRichToolbarAction: controller.richTextWebController.toggleFormattingOptions,
                isSendButtonEnabled: controller.isEnableEmailSendButton.value,
                onCloseViewAction: () => controller.saveToDraftAndClose(context),
                attachFileAction: () => controller.openFilePickerByType(context, FileType.any),
                insertImageAction: () => controller.insertImage(context, constraints.maxWidth),
                sendMessageAction: () => controller.sendEmailAction(context),
                openContextMenuAction: () => {},
              )),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(
                    context,
                    constraints,
                    responsiveUtils
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
                  child: Stack(
                    children: [
                      Obx(() => Padding(
                        padding: ComposerStyle.mobileEditorPadding,
                        child: WebEditorView(
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
                        ),
                      )),
                      Obx(() {
                        if (controller.richTextWebController.isFormattingOptionsEnabled) {
                          return Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: ToolbarRichTextWebBuilder(
                              richTextWebController: controller.richTextWebController,
                              padding: ComposerStyle.richToolbarPadding,
                              decoration: const BoxDecoration(
                                color: ComposerStyle.richToolbarColor,
                                boxShadow: ComposerStyle.richToolbarShadow
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      })
                    ],
                  ),
                )
              ),
            ]
          );
        }
      ),
      desktop: Obx(() => DesktopContainerView(
        childBuilder: (context, constraints) {
          return Column(children: [
            Obx(() => AppBarComposerWidget(
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
                  responsiveUtils
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
                child: Stack(
                  children: [
                    Obx(() => Padding(
                      padding: ComposerStyle.desktopEditorPadding,
                      child: WebEditorView(
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
                      ),
                    )),
                    Obx(() {
                      if (controller.richTextWebController.isFormattingOptionsEnabled) {
                        return Align(
                          alignment: AlignmentDirectional.bottomCenter,
                          child: ToolbarRichTextWebBuilder(
                            richTextWebController: controller.richTextWebController,
                            padding: ComposerStyle.richToolbarPadding,
                            decoration: const BoxDecoration(
                              color: ComposerStyle.richToolbarColor,
                              boxShadow: ComposerStyle.richToolbarShadow
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    })
                  ],
                ),
              )
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
            )),
          ]);
        },
        displayMode: controller.screenDisplayMode.value,
        emailSubject: controller.subjectEmail.value ?? '',
        onCloseViewAction: () => controller.saveToDraftAndClose(context),
        onChangeDisplayModeAction: controller.displayScreenTypeComposerAction,
      )),
      tablet: TabletContainerView(
        childBuilder: (context, constraints) {
          return Column(children: [
            Obx(() => AppBarComposerWidget(
              emailSubject: controller.subjectEmail.value ?? '',
              onCloseViewAction: () => controller.saveToDraftAndClose(context),
              constraints: constraints,
            )),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(
                  context,
                  constraints,
                  responsiveUtils
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
                  child: Stack(
                    children: [
                      Obx(() => Padding(
                        padding: ComposerStyle.tabletEditorPadding,
                        child: WebEditorView(
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
                        ),
                      )),
                      Obx(() {
                        if (controller.richTextWebController.isFormattingOptionsEnabled) {
                          return Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: ToolbarRichTextWebBuilder(
                              richTextWebController: controller.richTextWebController,
                              padding: ComposerStyle.richToolbarPadding,
                              decoration: const BoxDecoration(
                                color: ComposerStyle.richToolbarColor,
                                boxShadow: ComposerStyle.richToolbarShadow
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      })
                    ],
                  ),
                )
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
            )),
          ]);
        },
      )
    );
  }

  @override
  List<PopupMenuEntry> popUpMoreActionMenu(BuildContext context) {
    return [
      PopupMenuItem(
        padding: const EdgeInsets.symmetric(horizontal: 8), 
        child: PointerInterceptor(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Obx(() => buildIconWeb(
                  icon: Icon(controller.hasRequestReadReceipt.value ? Icons.done : null, color: Colors.black))), 
                Expanded(
                  child: InkResponse(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).requestReadReceipt,
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                          )
                      ),
                    ),
                  ),
                ),
              ]),
          ),
        ),
        onTap: () {
          controller.toggleRequestReadReceipt();
        },
      )
    ];
  }
}