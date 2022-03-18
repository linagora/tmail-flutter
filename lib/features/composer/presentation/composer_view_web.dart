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
          body: Align(alignment: Alignment.center, child: Card(
              color: Colors.transparent,
              child: Container(
                  color: Colors.white,
                  child: PointerInterceptor(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => _buildAppBarForMobile(context, controller.isEnableEmailSendButton.value)),
                        SizedBox(height: 16),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildEmailAddress(context)),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20),  child: _buildSubjectEmail(context)),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                        Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: _buildEditorAndAttachments(context))),
                      ]
                  ))
              )
          ))
      ),
      desktop: Obx(() {
        return Stack(children: [
          if (controller.screenDisplayMode == ScreenDisplayMode.normal)
            Positioned(right: 10, bottom: 10, child: Card(
                elevation: 20,
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: responsiveUtils.getSizeWidthScreen(context) * 0.55,
                    height: responsiveUtils.getSizeHeightScreen(context) * 0.75,
                    child: PointerInterceptor(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildAppBar(context)),
                          SizedBox(height: 10),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildTitleComposer(context)),
                          SizedBox(height: 16),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildEmailAddress(context)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20),  child: _buildSubjectEmail(context)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                          Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: _buildEditorAndAttachments(context))),
                          Obx(() => _buildBottomBar(context, controller.isEnableEmailSendButton.value)),
                        ]
                    )
                    )
                )
            )),
          if (controller.screenDisplayMode == ScreenDisplayMode.minimize)
            Positioned(right: 10, bottom: 10, child: Card(
                elevation: 20,
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(color: AppColor.colorTextButton, borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: 500,
                    height: 50,
                    child: PointerInterceptor(child: Row(
                        children: [
                          Expanded(child: Padding(
                            padding: EdgeInsets.only(left: 20, right: 16),
                            child: _buildTitleComposer(context),
                          )),
                          buildIconWeb(
                              icon: SvgPicture.asset(imagePaths.icMinimizeComposer, color: Colors.white, fit: BoxFit.fill),
                              tooltip: AppLocalizations.of(context).minimize,
                              onTap: () => controller.minimizeComposer()),
                          buildIconWeb(
                              icon: SvgPicture.asset(imagePaths.icFullScreenComposer, color: Colors.white, fit: BoxFit.fill),
                              tooltip: AppLocalizations.of(context).fullscreen,
                              onTap: () => controller.setFullScreenComposer()),
                          Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: buildIconWeb(
                                  icon: SvgPicture.asset(imagePaths.icCloseComposer, color: Colors.white, fit: BoxFit.fill),
                                  tooltip: AppLocalizations.of(context).close,
                                  onTap: () {
                                    controller.saveEmailAsDrafts(context);
                                    controller.closeComposerWeb();
                                  })),
                        ]
                    ))
                )
            )),
          if (controller.screenDisplayMode == ScreenDisplayMode.fullScreen)
            Scaffold(
                backgroundColor: Colors.black38,
                body: Align(alignment: Alignment.center, child: Card(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                        width: responsiveUtils.getSizeWidthScreen(context) * 0.85,
                        height: responsiveUtils.getSizeHeightScreen(context) * 0.9,
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: PointerInterceptor(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildAppBar(context)),
                                  SizedBox(height: 10),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildTitleComposer(context)),
                                  SizedBox(height: 16),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildEmailAddress(context)),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 20),  child: _buildSubjectEmail(context)),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                                  Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: _buildEditorAndAttachments(context))),
                                  Obx(() => _buildBottomBar(context, controller.isEnableEmailSendButton.value)),
                                ]
                            ))
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
              child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: PointerInterceptor(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildAppBar(context)),
                            SizedBox(height: 10),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildTitleComposer(context)),
                            SizedBox(height: 16),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _buildEmailAddress(context)),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 20),  child: _buildSubjectEmail(context)),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                            Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: _buildEditorAndAttachments(context))),
                            Obx(() => _buildBottomBar(context, controller.isEnableEmailSendButton.value)),
                          ]
                      ))
                  )
              )
          ))
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Transform(
      transform: Matrix4.translationValues(15.0, 0.0, 0.0),
      child: Row(
          children: [
            Spacer(),
            if (responsiveUtils.isDesktop(context))
              buildIconWeb(
                  icon: SvgPicture.asset(imagePaths.icMinimizeComposer, fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).minimize,
                  onTap: () => controller.minimizeComposer()),
            if (responsiveUtils.isDesktop(context))
              buildIconWeb(
                  icon: SvgPicture.asset(imagePaths.icFullScreenComposer, fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).fullscreen,
                  onTap: () => controller.setFullScreenComposer()),
            buildIconWeb(
                icon: SvgPicture.asset(imagePaths.icCloseComposer, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).close,
                onTap: () {
                  controller.saveEmailAsDrafts(context);
                  controller.closeComposerWeb();
                }),
          ]
      ),
    );
  }

  Widget _buildAppBarForMobile(BuildContext context, bool isEnableSendButton) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      color: Colors.white,
      child: Row(
          children: [
            buildIconWeb(
                icon: SvgPicture.asset(imagePaths.icCloseComposer, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).close,
                onTap: () {
                  controller.saveEmailAsDrafts(context);
                  controller.closeComposerWeb();
                }),
            Spacer(),
            buildIconWeb(
                icon: SvgPicture.asset(imagePaths.icAttachmentsComposer, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).pick_attachments,
                onTap: () => controller.openFilePickerByType(context, FileType.any)),
            buildIconWeb(
                icon: SvgPicture.asset(
                    imagePaths.icSendComposer,
                    color: isEnableSendButton ? AppColor.colorTextButton : AppColor.colorDisableMailboxCreateButton,
                    fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).send,
                onTap: () => controller.sendEmailAction(context)),
          ]
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isEnableSendButton) {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 20, top: 18, bottom: 18),
        color: AppColor.colorBottomBarComposer,
        child: Row(
            children: [
              buildIconWeb(
                  icon: SvgPicture.asset(imagePaths.icDeleteComposer, fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).delete,
                  onTap: () => controller.deleteComposer()),
              Spacer(),
              buildIconWeb(
                  icon: SvgPicture.asset(imagePaths.icAttachmentsComposer, fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).pick_attachments,
                  onTap: () => controller.openFilePickerByType(context, FileType.any)),
              SizedBox(width: 16),
              SizedBox(
                width: 102,
                height: 36,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:  MaterialStateProperty.resolveWith(
                                (states) => isEnableSendButton ? AppColor.colorTextButton : AppColor.colorDisableMailboxCreateButton),
                        padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                        elevation: MaterialStateProperty.resolveWith((states) => 0),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(width: 0, color: isEnableSendButton ? AppColor.colorTextButton : AppColor.colorDisableMailboxCreateButton)))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(AppLocalizations.of(context).send.toUpperCase(), style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500)),
                      SizedBox(width: 5),
                      SvgPicture.asset(imagePaths.icSendComposer, width: 18, height: 18, fit: BoxFit.fill),
                    ]),
                    onPressed: () => controller.sendEmailAction(context)
                ),
              )
            ]
        ),
      );
  }

  Widget _buildTitleComposer(BuildContext context) {
    return Obx(() => Text(
      controller.subjectEmail.isNotEmpty == true
          ? controller.subjectEmail.value ?? ''
          : AppLocalizations.of(context).new_message.capitalizeFirstEach,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
          color: controller.screenDisplayMode == ScreenDisplayMode.minimize ? Colors.white : Colors.black),
    ));
  }

  Widget _buildEmailAddress(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  '${AppLocalizations.of(context).from_email_address_prefix}:',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 15, color: AppColor.colorHintEmailAddressInput))),
              Expanded(
                child: Obx(() => controller.composerArguments.value != null
                    ? Text(
                        '<${controller.getEmailAddressSender()}>',
                        style: TextStyle(fontSize: 16, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal))
                    : SizedBox.shrink()
                )
              )
            ]
          )
        ),
        Divider(color: AppColor.colorDividerComposer, height: 1),
        Obx(() => (EmailAddressInputBuilder(
                context,
                imagePaths,
                appToast,
                PrefixEmailAddress.to,
                controller.listToEmailAddress,
                controller: controller.toEmailAddressController,
                isInitial: controller.isInitialRecipient.value,
                expandMode: controller.expandMode.value)
            ..addExpandAddressActionClick(() => controller.expandEmailAddressAction())
            ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
            ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word)))
          .build()
        ),
        Obx(() => controller.expandMode.value == ExpandMode.EXPAND
          ? Divider(color: AppColor.colorDividerComposer, height: 1)
          : SizedBox.shrink()),
        Obx(() => controller.expandMode.value == ExpandMode.EXPAND
          ? (EmailAddressInputBuilder(
                  context,
                  imagePaths,
                  appToast,
                  PrefixEmailAddress.cc,
                  controller.listCcEmailAddress,
                  controller: controller.ccEmailAddressController,
                  isInitial: controller.isInitialRecipient.value,)
              ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
              ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word)))
            .build()
          : SizedBox.shrink()
        ),
        Obx(() => controller.expandMode.value == ExpandMode.EXPAND
          ? Divider(color: AppColor.colorDividerComposer, height: 1)
          : SizedBox.shrink()),
        Obx(() => controller.expandMode.value == ExpandMode.EXPAND
          ? (EmailAddressInputBuilder(
                context,
                imagePaths,
                appToast,
                PrefixEmailAddress.bcc,
                controller.listBccEmailAddress,
                controller: controller.bccEmailAddressController,
                isInitial: controller.isInitialRecipient.value,)
              ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
              ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word)))
            .build()
          : SizedBox.shrink()
        ),
      ],
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
          Expanded(child: (TextFieldBuilder()
              ..key(Key('subject_email_input'))
              ..cursorColor(AppColor.colorTextButton)
              ..onChange((value) => controller.setSubjectEmail(value))
              ..textStyle(TextStyle(color: AppColor.colorEmailAddress, fontSize: 15))
              ..textDecoration(InputDecoration(contentPadding: EdgeInsets.zero, border: InputBorder.none))
              ..addController(controller.subjectEmailInputController))
            .build()
          )
        ]
    );
  }

  Widget _buildEditorAndAttachments(BuildContext context) {
    return Column(
      children: [
        Obx(() => controller.attachments.isNotEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                child: _buildAttachmentsTitle(context, controller.attachments, controller.expandModeAttachments.value))
            : SizedBox.shrink()),
        Obx(() => controller.attachments.isEmpty
            ? _buildAttachmentsLoadingView()
            : SizedBox.shrink()),
        Obx(() => controller.attachments.isNotEmpty && controller.expandModeAttachments.value == ExpandMode.COLLAPSE
            ? Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Divider(color: AppColor.colorDividerComposer, height: 1))
            : SizedBox.shrink()),
        Obx(() => controller.attachments.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: 8, left: 10, right: 10),
                child: _buildAttachmentsList(context, controller.attachments, controller.expandModeAttachments.value))
            : SizedBox.shrink()),
        Obx(() {
          if (controller.composerArguments.value != null) {
            if (controller.composerArguments.value?.emailActionType == EmailActionType.compose) {
              final initContent = controller.textEditorWeb ?? '';
              log('ComposerView::_buildEditorAndAttachments(): initContent: $initContent');
              return Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: _buildEditor(context, initContent)));
            } else if (controller.composerArguments.value?.emailActionType == EmailActionType.edit) {
              final initContent = controller.getEmailContentDraftsAsHtml();
              log('ComposerView::_buildEditorAndAttachments(): initContent: $initContent');
              if (initContent != null) {
                return Expanded(child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: _buildEditor(context, initContent)));
              } else {
                return SizedBox.shrink();
              }
            } else {
              final initContent = controller.getEmailContentQuotedAsHtml(context, controller.composerArguments.value!);
              log('ComposerView::_buildEditorAndAttachments(): initContent: $initContent');
              return Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
    return HtmlEditorBrowser.HtmlEditor(
      key: Key('composer_editor_web'),
      controller: controller.htmlControllerBrowser,
      htmlEditorOptions: HtmlEditorBrowser.HtmlEditorOptions(
        hint: '<p></p>',
        initialText: initContent,
        darkMode: false,
      ),
      htmlToolbarOptions: HtmlEditorBrowser.HtmlToolbarOptions(
        toolbarPosition: HtmlEditorBrowser.ToolbarPosition.custom
      ),
      otherOptions: HtmlEditorBrowser.OtherOptions(height: 550),
      callbacks: HtmlEditorBrowser.Callbacks(
          onBeforeCommand: (String? currentHtml) {
            log('ComposerView::_buildComposerEditor(): onBeforeCommand');
            controller.setTextEditorWeb(currentHtml);
          }, onChangeContent: (String? changed) {
            log('ComposerView::_buildComposerEditor(): onChangeContent');
            controller.setTextEditorWeb(changed);
          }, onInit: () {
            log('ComposerView::_buildComposerEditor(): onInit');
            controller.setFullScreenEditor();
          }, onFocus: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(const Duration(milliseconds: 500), () {
              controller.htmlControllerBrowser.setFocus();
            });
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
    if (constraints.maxWidth < ResponsiveUtils.minTabletWidth) {
      return 2;
    } else if (constraints.maxWidth < ResponsiveUtils.minTabletLargeWidth) {
      return 3;
    } else {
      return 4;
    }
  }

  double _getMaxWidthItemListAttachment(BuildContext context, BoxConstraints constraints) {
    final currentWidth = constraints.maxWidth - 40;
    return currentWidth / _getMaxItemRowListAttachment(context, constraints);
  }
}