import 'package:core/core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as HtmlEditorBrowser;
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
                    Divider(color: AppColor.colorDividerComposer, height: 1),
                    _buildEmailAddress(context, constraints),
                    Divider(color: AppColor.colorDividerComposer, height: 1),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16),  child: _buildSubjectEmail(context)),
                    Divider(color: AppColor.colorDividerComposer, height: 1),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16),  child: _buildListButton(context)),
                    Divider(color: AppColor.colorDividerComposer, height: 1),
                    Expanded(child: _buildEditorAndAttachments(context)),
                  ]
              )))
          )
      ),
      desktop: Obx(() {
        return Stack(children: [
          if (controller.screenDisplayMode == ScreenDisplayMode.normal)
            Positioned(right: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                    width: responsiveUtils.getSizeScreenWidth(context) * 0.5,
                    height: responsiveUtils.getSizeScreenHeight(context) * 0.75,
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        child: LayoutBuilder(builder: (context, constraints) =>
                            PointerInterceptor(child: _buildBodyForDesktop(context, constraints)))
                    )
                )
            )),
          if (controller.screenDisplayMode == ScreenDisplayMode.minimize)
            Positioned(right: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
                    width: 500,
                    height: 50,
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        child: PointerInterceptor(child: Row(children: [
                            Padding(
                                padding: EdgeInsets.only(left: 10),
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
                              padding: EdgeInsets.only(left: 16, right: 80),
                              child: _buildTitleComposer(context),
                            )),
                        ]))
                    )
                )
            )),
          if (controller.screenDisplayMode == ScreenDisplayMode.fullScreen)
            Scaffold(
                backgroundColor: Colors.black38,
                body: Align(alignment: Alignment.center, child: Card(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                    child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                        width: responsiveUtils.getSizeScreenWidth(context) * 0.85,
                        height: responsiveUtils.getSizeScreenHeight(context) * 0.9,
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
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
                  controller.screenDisplayMode == ScreenDisplayMode.fullScreen
                      ? imagePaths.icFullScreenExit
                      : imagePaths.icFullScreenComposer,
                  fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).fullscreen,
              onTap: () => controller.displayScreenTypeComposerAction(controller.screenDisplayMode == ScreenDisplayMode.fullScreen
                  ? ScreenDisplayMode.normal
                  : ScreenDisplayMode.fullScreen))),
        if (responsiveUtils.isDesktop(context))
          buildIconWeb(
            icon: SvgPicture.asset(imagePaths.icMinimize, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).minimize,
            onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.minimize)),
        Expanded(child: _buildTitleComposer(context)),
        SizedBox(width: 100),
      ]
    );
  }

  Widget _buildAppBarForMobile(BuildContext context, bool isEnableSendButton) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
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
        padding: EdgeInsets.symmetric(vertical: 16),
        color: Colors.white,
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTextButton(
                AppLocalizations.of(context).cancel,
                textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: AppColor.lineItemListColor),
                backgroundColor: AppColor.emailAddressChipColor,
                width: 150,
                height: 44,
                radius: 10,
                onTap: () => controller.closeComposerWeb()),
              SizedBox(width: 12),
              buildTextButton(
                  AppLocalizations.of(context).save_to_drafts,
                  textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: AppColor.colorTextButton),
                  backgroundColor: AppColor.emailAddressChipColor,
                  width: 150,
                  height: 44,
                  radius: 10,
                  onTap: () {
                    controller.saveEmailAsDrafts(context);
                    controller.closeComposerWeb();
                  }),
              SizedBox(width: 12),
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
        Padding(padding: EdgeInsets.only(left: 20, right: 20, top: 8), child: _buildAppBar(context)),
        Padding(padding: EdgeInsets.only(top: 8), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
        Padding(
            padding: EdgeInsets.only(left: 16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: EdgeInsets.only(top: 20),
                  child: (AvatarBuilder()
                      ..text('${controller.mailboxDashBoardController.userProfile.value?.getAvatarText() ?? ''}')
                      ..size(56)
                      ..addTextStyle(TextStyle(fontWeight: FontWeight.w600, fontSize: 28, color: Colors.white))
                      ..backgroundColor(AppColor.colorAvatar))
                    .build()),
              Expanded(child: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Column(children: [
                  _buildEmailAddress(context, constraints),
                  Divider(color: AppColor.colorDividerComposer, height: 1),
                  Padding(padding: EdgeInsets.only(right: 16), child: _buildSubjectEmail(context)),
                  Divider(color: AppColor.colorDividerComposer, height: 1),
                  _buildListButton(context),
                ]),
              ))
            ])),
        Divider(color: AppColor.colorDividerComposer, height: 1),
        Expanded(child: Padding(
            padding: EdgeInsets.only(left: responsiveUtils.isMobile(context) ? 16 : 60, right: responsiveUtils.isMobile(context) ? 16 : 25),
            child: _buildEditorAndAttachments(context))),
        Divider(color: AppColor.colorDividerComposer, height: 1),
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
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    ));
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
                      ..addOnOpenSuggestionBoxEmailAddress(() => controller.getAutoCompleteSuggestion(isAll: true))
                      ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word: word)))
                    .build()
              )),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true
                  ? Divider(color: AppColor.colorDividerComposer, height: 1)
                  : SizedBox.shrink()),
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
                        ..addOnOpenSuggestionBoxEmailAddress(() => controller.getAutoCompleteSuggestion(isAll: true))
                        ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word: word)))
                      .build())
                  : SizedBox.shrink()
              ),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true
                  ? Divider(color: AppColor.colorDividerComposer, height: 1)
                  : SizedBox.shrink()),
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
                        ..addOnOpenSuggestionBoxEmailAddress(() => controller.getAutoCompleteSuggestion(isAll: true))
                        ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word: word)))
                      .build())
                  : SizedBox.shrink()
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
              padding: EdgeInsets.only(right: 8, top: 16),
              child: Text(
                '${AppLocalizations.of(context).subject_email}:',
                style: TextStyle(fontSize: 15, color: AppColor.colorHintEmailAddressInput))),
          Expanded(
              child: FocusScope(child: Focus(
                onFocusChange: (focus) => controller.onSubjectEmailFocusChange(focus),
                child: (TextFieldBuilder()
                    ..key(Key('subject_email_input'))
                    ..cursorColor(AppColor.colorTextButton)
                    ..onChange((value) => controller.setSubjectEmail(value))
                    ..textStyle(TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal))
                    ..textDecoration(InputDecoration(contentPadding: EdgeInsets.zero, border: InputBorder.none))
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
            padding: EdgeInsets.symmetric(vertical: 5),
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
            : SizedBox.shrink()),
        Obx(() => controller.attachments.isEmpty
            ? _buildAttachmentsLoadingView()
            : SizedBox.shrink()),
        Obx(() => controller.attachments.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: 8, left: responsiveUtils.isMobile(context) ? 16 : 10, right: responsiveUtils.isMobile(context) ? 16 : 10),
                child: _buildAttachmentsList(context, controller.attachments, controller.expandModeAttachments.value))
            : SizedBox.shrink()),
        Obx(() {
          if (controller.composerArguments.value != null) {
            if (controller.composerArguments.value?.emailActionType == EmailActionType.compose) {
              final initContent = controller.textEditorWeb ?? '';
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
                return SizedBox.shrink();
              }
            } else {
              final initContent = controller.textEditorWeb ?? controller.getEmailContentQuotedAsHtml(context, controller.composerArguments.value!);
              return Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsiveUtils.isMobile(context) ? 8 : 10),
                  child: _buildEditor(context, initContent)));
            }
          } else {
            return SizedBox.shrink();
          }
        }),
      ]
    );
  }

  Widget _buildEditor(BuildContext context, String initContent) {
    log('ComposerView::_buildEditor(): initContent: $initContent');

    return HtmlEditorBrowser.HtmlEditor(
      key: Key('composer_editor_web'),
      controller: controller.htmlControllerBrowser,
      htmlEditorOptions: HtmlEditorBrowser.HtmlEditorOptions(
        hint: '${AppLocalizations.of(context).hint_compose_email}',
        darkMode: false,
      ),
      blockQuotedContent: initContent,
      htmlToolbarOptions: HtmlEditorBrowser.HtmlToolbarOptions(
        toolbarPosition: HtmlEditorBrowser.ToolbarPosition.custom
      ),
      otherOptions: HtmlEditorBrowser.OtherOptions(height: 550),
      callbacks: HtmlEditorBrowser.Callbacks(
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
      (failure) => SizedBox.shrink(),
      (success) => success is UploadingAttachmentState
        ? Center(child: Padding(
            padding: padding ?? EdgeInsets.all(10),
            child: SizedBox(
                width: size ?? 20,
                height: size ??  20,
                child: CupertinoActivityIndicator(color: AppColor.colorTextButton))))
        : SizedBox.shrink()));
  }

  Widget _buildAttachmentsTitle(BuildContext context, List<Attachment> attachments, ExpandMode expandModeAttachment) {
    return Row(
      children: [
        Text(
            '${AppLocalizations.of(context).attachments} (${filesize(attachments.totalSize(), 0)}):',
            style: TextStyle(fontSize: 12, color: AppColor.colorHintEmailAddressInput, fontWeight: FontWeight.normal)),
        _buildAttachmentsLoadingView(padding: EdgeInsets.only(left: 16), size: 16),
        Spacer(),
        Material(
            type: MaterialType.circle,
            color: Colors.transparent,
            child: TextButton(
                child: Text(
                    expandModeAttachment == ExpandMode.EXPAND
                        ? AppLocalizations.of(context).hide
                        : '${AppLocalizations.of(context).show_all} (${attachments.length})',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColor.colorTextButton)),
                onPressed: () => controller.toggleDisplayAttachments()
            )
        )
      ],
    );
  }

  Widget _buildAttachmentsList(BuildContext context, List<Attachment> attachments, ExpandMode expandMode) {
    if (expandMode == ExpandMode.COLLAPSE) {
      return SizedBox.shrink();
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              key: Key('list_attachment_minimize'),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) =>
                  (AttachmentFileComposerBuilder(context, imagePaths, attachments[index],
                      itemMargin: EdgeInsets.only(right: 8),
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