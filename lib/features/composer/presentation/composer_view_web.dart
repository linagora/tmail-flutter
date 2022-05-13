import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_file_composer_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/email_address_input_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ComposerView extends GetWidget<ComposerController> {

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final appToast = Get.find<AppToast>();
  final keyboardUtils = Get.find<KeyboardUtils>();

  ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: responsiveUtils,
      mobile: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
              color: Colors.white,
              child: LayoutBuilder(builder: (context, constraints) => PointerInterceptor(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => _buildAppBarForMobile(context, controller.isEnableEmailSendButton.value)),
                    const Divider(color: AppColor.colorDividerComposer, height: 1),
                    Obx(() => controller.identitySelected.value != null
                      ? _buildFromEmailAddress(context)
                      : const SizedBox.shrink()),
                    Obx(() => controller.identitySelected.value != null
                        ? const Divider(color: AppColor.colorDividerComposer, height: 1)
                        : const SizedBox.shrink()),
                    _buildEmailAddress(context, constraints),
                    const Divider(color: AppColor.colorDividerComposer, height: 1),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16),  child: _buildSubjectEmail(context)),
                    const Divider(color: AppColor.colorDividerComposer, height: 1),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16),  child: _buildListButton(context)),
                    const Divider(color: AppColor.colorDividerComposer, height: 1),
                    Expanded(child: _buildEditorAndAttachments(context)),
                  ]
              )))
          )
      ),
      desktop: Obx(() {
        return Stack(children: [
          if (controller.screenDisplayMode.value == ScreenDisplayMode.normal)
            Positioned(right: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                child: Container(
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                    width: responsiveUtils.getSizeScreenWidth(context) * 0.5,
                    height: responsiveUtils.getSizeScreenHeight(context) * 0.75,
                    child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(24)),
                        child: LayoutBuilder(builder: (context, constraints) =>
                            PointerInterceptor(child: _buildBodyForDesktop(context, constraints)))
                    )
                )
            )),
          if (controller.screenDisplayMode.value == ScreenDisplayMode.minimize)
            Positioned(right: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Container(
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
                    width: 500,
                    height: 50,
                    child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: PointerInterceptor(child: Row(children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: buildIconWeb(
                                    icon: SvgPicture.asset(imagePaths.icCloseMailbox, fit: BoxFit.fill),
                                    tooltip: AppLocalizations.of(context).close,
                                    onTap: () {
                                      controller.saveEmailAsDrafts(context);
                                      controller.closeComposerWeb();
                                    }
                                )),
                            buildIconWeb(
                                icon: SvgPicture.asset(imagePaths.icFullScreenComposer, fit: BoxFit.fill),
                                tooltip: AppLocalizations.of(context).fullscreen,
                                onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.fullScreen)),
                            buildIconWeb(
                                icon: SvgPicture.asset(imagePaths.icChevronUp, fit: BoxFit.fill),
                                tooltip: AppLocalizations.of(context).show,
                                onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.normal)),
                            Expanded(child: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 80),
                              child: _buildTitleComposer(context),
                            )),
                        ]))
                    )
                )
            )),
          if (controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen)
            Scaffold(
                backgroundColor: Colors.black38,
                body: Align(alignment: Alignment.center, child: Card(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                    child: Container(
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                        width: responsiveUtils.getSizeScreenWidth(context) * 0.85,
                        height: responsiveUtils.getSizeScreenHeight(context) * 0.9,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(24)),
                            child: LayoutBuilder(builder: (context, constraints) =>
                                PointerInterceptor(child: _buildBodyForDesktop(context, constraints)))
                        )
                    )
                )
                )
            )
        ]);
      }),
      tablet: Scaffold(
          backgroundColor: Colors.black38,
          body: Align(alignment: Alignment.center, child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child: LayoutBuilder(builder: (context, constraints) =>
                          PointerInterceptor(child: _buildBodyForDesktop(context, constraints)))
                  )
              )
          ))
      ),
      tabletLarge: Scaffold(
          backgroundColor: Colors.black38,
          body: Align(alignment: Alignment.center, child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child: LayoutBuilder(builder: (context, constraints) =>
                          PointerInterceptor(child: _buildBodyForDesktop(context, constraints)))
                  )
              )
          ))
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        buildIconWeb(
            icon: SvgPicture.asset(imagePaths.icCloseMailbox, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).close,
            onTap: () {
              controller.saveEmailAsDrafts(context);
              controller.closeComposerWeb();
            }),
        if (responsiveUtils.isDesktop(context))
          Obx(() => buildIconWeb(
              icon: SvgPicture.asset(
                  controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen
                      ? imagePaths.icFullScreenExit
                      : imagePaths.icFullScreenComposer,
                  fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).fullscreen,
              onTap: () => controller.displayScreenTypeComposerAction(controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen
                  ? ScreenDisplayMode.normal
                  : ScreenDisplayMode.fullScreen))),
        if (responsiveUtils.isDesktop(context))
          buildIconWeb(
            icon: SvgPicture.asset(imagePaths.icMinimize, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).minimize,
            onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.minimize)),
        Expanded(child: _buildTitleComposer(context)),
        const SizedBox(width: 100),
      ]
    );
  }

  Widget _buildAppBarForMobile(BuildContext context, bool isEnableSendButton) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      color: Colors.white,
      child: Row(
          children: [
            buildIconWeb(
                icon: SvgPicture.asset(imagePaths.icClose, width: 30, height: 30, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).close,
                iconPadding: EdgeInsets.zero,
                onTap: () {
                  controller.saveEmailAsDrafts(context);
                  controller.closeComposerWeb();
                }),
            Expanded(child: _buildTitleComposer(context)),
            buildIconWeb(
                icon: SvgPicture.asset(
                    isEnableSendButton ? imagePaths.icSendMobile : imagePaths.icSendDisable,
                    fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).send,
                onTap: () => controller.sendEmailAction(context)),
          ]
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isEnableSendButton) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: Colors.white,
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTextButton(
                AppLocalizations.of(context).cancel,
                textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: AppColor.lineItemListColor),
                backgroundColor: AppColor.emailAddressChipColor,
                width: 150,
                height: 44,
                radius: 10,
                onTap: () => controller.closeComposerWeb()),
              const SizedBox(width: 12),
              buildTextButton(
                  AppLocalizations.of(context).save_to_drafts,
                  textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: AppColor.colorTextButton),
                  backgroundColor: AppColor.emailAddressChipColor,
                  width: 150,
                  height: 44,
                  radius: 10,
                  onTap: () {
                    controller.saveEmailAsDrafts(context);
                    controller.closeComposerWeb();
                  }),
              const SizedBox(width: 12),
              buildTextButton(
                  AppLocalizations.of(context).send,
                  width: 150,
                  height: 44,
                  radius: 10,
                  onTap: () => controller.sendEmailAction(context)),
            ]
        ),
      );
  }

  Widget _buildBodyForDesktop(BuildContext context, BoxConstraints constraints) {
    return Column(children: [
        Padding(padding: const EdgeInsets.only(left: 20, right: 20, top: 8), child: _buildAppBar(context)),
        const Padding(padding: EdgeInsets.only(top: 8), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
        Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 20),
                  child: (AvatarBuilder()
                      ..text(controller.mailboxDashBoardController.userProfile.value?.getAvatarText() ?? '')
                      ..size(56)
                      ..addTextStyle(const TextStyle(fontWeight: FontWeight.w600, fontSize: 28, color: Colors.white))
                      ..backgroundColor(AppColor.colorAvatar))
                    .build()),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(children: [
                  Obx(() => controller.identitySelected.value != null
                      ? _buildFromEmailAddress(context)
                      : const SizedBox.shrink()),
                  Obx(() => controller.identitySelected.value != null
                      ? const Divider(color: AppColor.colorDividerComposer, height: 1)
                      : const SizedBox.shrink()),
                  _buildEmailAddress(context, constraints),
                  const Divider(color: AppColor.colorDividerComposer, height: 1),
                  Padding(padding: const EdgeInsets.only(right: 16), child: _buildSubjectEmail(context)),
                  const Divider(color: AppColor.colorDividerComposer, height: 1),
                  _buildListButton(context),
                ]),
              ))
            ])),
        const Divider(color: AppColor.colorDividerComposer, height: 1),
        Expanded(child: Padding(
            padding: EdgeInsets.only(left: responsiveUtils.isMobile(context) ? 16 : 60, right: responsiveUtils.isMobile(context) ? 16 : 25),
            child: _buildEditorAndAttachments(context))),
        const Divider(color: AppColor.colorDividerComposer, height: 1),
        Obx(() => _buildBottomBar(context, controller.isEnableEmailSendButton.value)),
    ]);
  }

  Widget _buildTitleComposer(BuildContext context) {
    return Obx(() => Text(
      controller.subjectEmail.isNotEmpty == true
          ? controller.subjectEmail.value ?? ''
          : AppLocalizations.of(context).new_message.capitalizeFirstEach,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    ));
  }

  Widget _buildFromEmailAddress(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: responsiveUtils.isMobile(context) ? 16 : 0,
          top: 12,
          bottom: 12),
      child: Row(children: [
        Text('${AppLocalizations.of(context).from_email_address_prefix}:',
            style: const TextStyle(fontSize: 15, color: AppColor.colorHintEmailAddressInput)),
        const SizedBox(width: 12),
        DropdownButtonHideUnderline(
          child: DropdownButton2<Identity>(
            isExpanded: true,
            customButton: SvgPicture.asset(imagePaths.icEditIdentity),
            items: controller.listIdentities.map((item) => DropdownMenuItem<Identity>(
              value: item,
              child: PointerInterceptor(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: item == controller.identitySelected.value ? AppColor.colorBgMenuItemDropDownSelected : Colors.transparent),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.email ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.colorHintSearchBar),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ]
                  ),
                ),
              ),
            )).toList(),
            onChanged: (newIdentity) => controller.selectIdentity(newIdentity),
            itemPadding: const EdgeInsets.symmetric(horizontal: 8),
            customItemsHeight: 55,
            dropdownMaxHeight: 240,
            dropdownWidth: 370,
            dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white),
            dropdownElevation: 4,
            scrollbarRadius: const Radius.circular(40),
            scrollbarThickness: 6,
          ),
        ),
        Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8, left: 12),
            child: Text(
              controller.identitySelected.value?.email ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: AppColor.colorEmailAddressPrefix),
            ))),
      ]),
    );
  }

  Widget _buildEmailAddress(BuildContext context, BoxConstraints constraints) {
    log('ComposerView::_buildEmailAddress(): height: ${constraints.maxHeight}');
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: _getMaxHeightEmailAddressWidget(context, constraints)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => Padding(
                  padding: EdgeInsets.only(left: responsiveUtils.isMobile(context) ? 16 : 0),
                  child: (EmailAddressInputBuilder(context, imagePaths,
                          PrefixEmailAddress.to,
                          controller.listToEmailAddress,
                          controller.listEmailAddressType,
                          expandMode: controller.toAddressExpandMode.value,
                          controller: controller.toEmailAddressController,
                          isInitial: controller.isInitialRecipient.value)
                      ..addOnFocusEmailAddressChangeAction((prefixEmailAddress, focus) => controller.onEmailAddressFocusChange(prefixEmailAddress, focus))
                      ..addOnShowFullListEmailAddressAction((prefixEmailAddress) => controller.showFullEmailAddress(prefixEmailAddress))
                      ..addOnAddEmailAddressTypeAction((prefixEmailAddress) => controller.addEmailAddressType(prefixEmailAddress))
                      ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
                      ..addOnOpenSuggestionBoxEmailAddress(() => controller.getAutoCompleteSuggestion(word: ''))
                      ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word: word)))
                    .build()
              )),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true
                  ? const Divider(color: AppColor.colorDividerComposer, height: 1)
                  : const SizedBox.shrink()),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true
                  ? Padding(
                  padding: EdgeInsets.only(left: responsiveUtils.isMobile(context) ? 16 : 0),
                  child: (EmailAddressInputBuilder(context, imagePaths,
                            PrefixEmailAddress.cc,
                            controller.listCcEmailAddress,
                            controller.listEmailAddressType,
                            expandMode: controller.ccAddressExpandMode.value,
                            controller: controller.ccEmailAddressController,
                            isInitial: controller.isInitialRecipient.value,)
                        ..addOnFocusEmailAddressChangeAction((prefixEmailAddress, focus) => controller.onEmailAddressFocusChange(prefixEmailAddress, focus))
                        ..addOnShowFullListEmailAddressAction((prefixEmailAddress) => controller.showFullEmailAddress(prefixEmailAddress))
                        ..addOnDeleteEmailAddressTypeAction((prefixEmailAddress) => controller.deleteEmailAddressType(prefixEmailAddress))
                        ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
                        ..addOnOpenSuggestionBoxEmailAddress(() => controller.getAutoCompleteSuggestion(word: ''))
                        ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word: word)))
                      .build())
                  : const SizedBox.shrink()
              ),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true
                  ? const Divider(color: AppColor.colorDividerComposer, height: 1)
                  : const SizedBox.shrink()),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true
                  ? Padding(
                      padding: EdgeInsets.only(left: responsiveUtils.isMobile(context) ? 16 : 0),
                      child: (EmailAddressInputBuilder(context, imagePaths,
                            PrefixEmailAddress.bcc,
                            controller.listBccEmailAddress,
                            controller.listEmailAddressType,
                            expandMode: controller.bccAddressExpandMode.value,
                            controller: controller.bccEmailAddressController,
                            isInitial: controller.isInitialRecipient.value,)
                        ..addOnFocusEmailAddressChangeAction((prefixEmailAddress, focus) => controller.onEmailAddressFocusChange(prefixEmailAddress, focus))
                        ..addOnShowFullListEmailAddressAction((prefixEmailAddress) => controller.showFullEmailAddress(prefixEmailAddress))
                        ..addOnDeleteEmailAddressTypeAction((prefixEmailAddress) => controller.deleteEmailAddressType(prefixEmailAddress))
                        ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
                        ..addOnOpenSuggestionBoxEmailAddress(() => controller.getAutoCompleteSuggestion(word: ''))
                        ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word: word)))
                      .build())
                  : const SizedBox.shrink()
              ),
            ],
          ),
        )
    );
  }

  Widget _buildSubjectEmail(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 8, top: 16),
              child: Text(
                '${AppLocalizations.of(context).subject_email}:',
                style: const TextStyle(fontSize: 15, color: AppColor.colorHintEmailAddressInput))),
          Expanded(
              child: FocusScope(child: Focus(
                onFocusChange: (focus) => controller.onSubjectEmailFocusChange(focus),
                child: (TextFieldBuilder()
                    ..key(const Key('subject_email_input'))
                    ..cursorColor(AppColor.colorTextButton)
                    ..onChange((value) => controller.setSubjectEmail(value))
                    ..textStyle(const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal))
                    ..textDecoration(const InputDecoration(contentPadding: EdgeInsets.zero, border: InputBorder.none))
                    ..addController(controller.subjectEmailInputController))
                  .build(),
              ))
          )
        ]
    );
  }

  Widget _buildListButton(BuildContext context) {
    return  Transform(
        transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              buildIconWeb(
                  icon: SvgPicture.asset(imagePaths.icAttachmentsComposer, color: AppColor.colorTextButton, fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).attach_file,
                  onTap: () => controller.openFilePickerByType(context, FileType.any)),
            ])
        )
    );
  }

  Widget _buildEditorAndAttachments(BuildContext context) {
    return Column(
      children: [
        Obx(() => controller.attachments.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: responsiveUtils.isMobile(context) ? 16 : 20, right: responsiveUtils.isMobile(context) ? 16: 0),
                child: _buildAttachmentsTitle(context, controller.attachments, controller.expandModeAttachments.value))
            : const SizedBox.shrink()),
        Obx(() => controller.attachments.isEmpty
            ? _buildAttachmentsLoadingView()
            : const SizedBox.shrink()),
        Obx(() => controller.attachments.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: 8, left: responsiveUtils.isMobile(context) ? 16 : 10, right: responsiveUtils.isMobile(context) ? 16 : 10),
                child: _buildAttachmentsList(context, controller.attachments, controller.expandModeAttachments.value))
            : const SizedBox.shrink()),
        Obx(() {
          if (controller.composerArguments.value != null) {
            if (controller.composerArguments.value?.emailActionType == EmailActionType.compose) {
              final initContent = controller.textEditorWeb ?? '<p><br><br><br></p>';
              return Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsiveUtils.isMobile(context) ? 8 : 10),
                  child: _buildEditor(context, initContent)));
            } else if (controller.composerArguments.value?.emailActionType == EmailActionType.edit) {
              final initContent = controller.textEditorWeb ?? controller.getEmailContentDraftsAsHtml();
              if (initContent != null) {
                return Expanded(child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsiveUtils.isMobile(context) ? 8 : 10),
                    child: _buildEditor(context, initContent)));
              } else {
                return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CupertinoActivityIndicator(color: AppColor.colorLoading)));
              }
            } else {
              final initContent = controller.textEditorWeb ?? controller.getEmailContentQuotedAsHtml(context, controller.composerArguments.value!);
              return Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsiveUtils.isMobile(context) ? 8 : 10),
                  child: _buildEditor(context, initContent)));
            }
          } else {
            return const SizedBox.shrink();
          }
        }),
      ]
    );
  }

  Widget _buildEditor(BuildContext context, String initContent) {
    log('ComposerView::_buildEditor(): initContent: $initContent');

    return html_editor_browser.HtmlEditor(
      key: const Key('composer_editor_web'),
      controller: controller.htmlControllerBrowser,
      htmlEditorOptions: const html_editor_browser.HtmlEditorOptions(
        hint: '',
        darkMode: false,
      ),
      blockQuotedContent: initContent,
      htmlToolbarOptions: const html_editor_browser.HtmlToolbarOptions(
        toolbarPosition: html_editor_browser.ToolbarPosition.custom
      ),
      otherOptions: const html_editor_browser.OtherOptions(height: 550),
      callbacks: html_editor_browser.Callbacks(
          onBeforeCommand: (String? currentHtml) {
            log('ComposerView::_buildComposerEditor(): onBeforeCommand : $currentHtml');
            controller.setTextEditorWeb(currentHtml);
          }, onChangeContent: (String? changed) {
            log('ComposerView::_buildComposerEditor(): onChangeContent : $changed');
            controller.setTextEditorWeb(changed);
          }, onInit: () {
            log('ComposerView::_buildComposerEditor(): onInit');
            controller.setFullScreenEditor();
          }, onFocus: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(const Duration(milliseconds: 500), () {
              controller.htmlControllerBrowser.setFocus();
            });
          }, onBlur: () {
            controller.onEditorFocusChange(false);
          }, onMouseDown: () {
            controller.onEditorFocusChange(true);
          }
      ),
    );
  }

  Widget _buildAttachmentsLoadingView({EdgeInsets? padding, double? size}) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is UploadingAttachmentState
        ? Center(child: Padding(
            padding: padding ?? const EdgeInsets.all(10),
            child: SizedBox(
                width: size ?? 20,
                height: size ??  20,
                child: const CupertinoActivityIndicator(color: AppColor.colorTextButton))))
        : const SizedBox.shrink()));
  }

  Widget _buildAttachmentsTitle(BuildContext context, List<Attachment> attachments, ExpandMode expandModeAttachment) {
    return Row(
      children: [
        Text(
            '${AppLocalizations.of(context).attachments} (${filesize(attachments.totalSize(), 0)}):',
            style: const TextStyle(fontSize: 12, color: AppColor.colorHintEmailAddressInput, fontWeight: FontWeight.normal)),
        _buildAttachmentsLoadingView(padding: const EdgeInsets.only(left: 16), size: 16),
        const Spacer(),
        Material(
            type: MaterialType.circle,
            color: Colors.transparent,
            child: TextButton(
                child: Text(
                    expandModeAttachment == ExpandMode.EXPAND
                        ? AppLocalizations.of(context).hide
                        : '${AppLocalizations.of(context).show_all} (${attachments.length})',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColor.colorTextButton)),
                onPressed: () => controller.toggleDisplayAttachments()
            )
        )
      ],
    );
  }

  Widget _buildAttachmentsList(BuildContext context, List<Attachment> attachments, ExpandMode expandMode) {
    if (expandMode == ExpandMode.COLLAPSE) {
      return const SizedBox.shrink();
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              key: const Key('list_attachment_minimize'),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) =>
                  (AttachmentFileComposerBuilder(context, imagePaths, attachments[index],
                      itemMargin: const EdgeInsets.only(right: 8),
                      maxWidth: _getMaxWidthItemListAttachment(context, constraints),
                      maxHeight: 60)
                  ..addOnDeleteAttachmentAction((attachment) => controller.removeAttachmentAction(attachment)))
                .build()
            )
          )
        );
      });
    }
  }

  int _getMaxItemRowListAttachment(BuildContext context, BoxConstraints constraints) {
    if (constraints.maxWidth < responsiveUtils.minTabletWidth) {
      return 2;
    } else if (constraints.maxWidth < responsiveUtils.minTabletLargeWidth) {
      return 3;
    } else {
      return 4;
    }
  }

  double _getMaxWidthItemListAttachment(BuildContext context, BoxConstraints constraints) {
    final currentWidth = constraints.maxWidth - 40;
    return currentWidth / _getMaxItemRowListAttachment(context, constraints);
  }

  double _getMaxHeightEmailAddressWidget(BuildContext context, BoxConstraints constraints) {
    if (responsiveUtils.isDesktop(context)) {
      return constraints.maxHeight > 0 ? constraints.maxHeight * 0.3 : 150.0;
    } else {
      return constraints.maxHeight > 0 ? constraints.maxHeight * 0.4 : 150.0;
    }
  }
}