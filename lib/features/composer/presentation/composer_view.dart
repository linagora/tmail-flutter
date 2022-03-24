import 'package:core/core.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_file_composer_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/email_address_input_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ComposerView extends GetWidget<ComposerController> {

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final keyboardUtils = Get.find<KeyboardUtils>();

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: responsiveUtils,
      mobile: _buildComposerViewForMobile(context),
      tablet: _buildComposerViewForTablet(context),
      tabletLarge: _buildComposerViewForTablet(context),
      desktop: _buildComposerViewForTablet(context),
    );
  }

  Widget _buildComposerViewForMobile(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          controller.saveEmailAsDrafts(context);
          return true;
        },
        child: GestureDetector(
            onTap: () {
              controller.clearFocusEditor(context);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                  right: responsiveUtils.isMobile(context) && responsiveUtils.isLandscape(context),
                  left: responsiveUtils.isMobile(context) && responsiveUtils.isLandscape(context),
                  child: Container(
                      color: Colors.white,
                      child: Column(children: [
                        Obx(() => _buildAppBar(context, controller.isEnableEmailSendButton.value)),
                        Divider(color: AppColor.colorDividerComposer, height: 1),
                        Expanded(child: _buildBodyMobile(context))
                      ])
                  )
              ),
            )
        )
    );
  }

  Widget _buildComposerViewForTablet(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          controller.saveEmailAsDrafts(context);
          return true;
        },
        child: GestureDetector(
            onTap: () {
              controller.clearFocusEditor(context);
            },
            child: Scaffold(
                backgroundColor: Colors.black38,
                body: Align(alignment: Alignment.center, child: Card(
                    color: Colors.transparent,
                    elevation: 20,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                    shadowColor: Colors.transparent,
                    child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                        width: responsiveUtils.getSizeScreenWidth(context) * 0.9,
                        height: responsiveUtils.getSizeScreenHeight(context) * 0.9,
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            child: SafeArea(
                                child: Column(children: [
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _buildAppBar(context, controller.isEnableEmailSendButton.value)),
                                    Padding(padding: EdgeInsets.only(top: 8), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
                                    Expanded(child: _buildBodyTablet(context)),
                                    Divider(color: AppColor.colorDividerComposer, height: 1),
                                    Obx(() => _buildBottomBar(context, controller.isEnableEmailSendButton.value)),
                                ]),
                            )
                        )
                    )
                ))
            )
        )
    );
  }

  Widget _buildAppBar(BuildContext context, bool isEnableSendButton) {
    return Container(
      padding: responsiveUtils.isMobile(context) ? EdgeInsets.all(8) : EdgeInsets.zero,
      color: Colors.white,
      child: Row(
          children: [
            buildIconWeb(
                icon: SvgPicture.asset(imagePaths.icClose, width: 30, height: 30, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).close,
                iconPadding: EdgeInsets.zero,
                onTap: () {
                  controller.saveEmailAsDrafts(context);
                  controller.closeComposer();
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
                onTap: () => controller.closeComposer()),
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
                  controller.closeComposer();
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

  Widget _buildTitleComposer(BuildContext context) {
    return Obx(() => Text(
      controller.subjectEmail.isNotEmpty == true
          ? controller.subjectEmail.value ?? ''
          : AppLocalizations.of(context).new_message.capitalizeFirstEach,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: responsiveUtils.isMobile(context) ? 17 : 24, fontWeight: FontWeight.bold, color: Colors.black),
    ));
  }

  List<Widget> _pickAttachmentsActionTiles(BuildContext context) {
    return [
      _pickPhotoAndVideoAction(context),
      _browseFileAction(context),
      SizedBox(height: kIsWeb ? 16 : 30),
    ];
  }

  Widget _pickPhotoAndVideoAction(BuildContext context) {
    return (SimpleContextMenuActionBuilder(
            Key('pick_photo_and_video_context_menu_action'),
            SvgPicture.asset(imagePaths.icPhotoLibrary, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).photos_and_videos)
        ..onActionClick((_) => controller.openFilePickerByType(context, FileType.media)))
      .build();
  }

  Widget _browseFileAction(BuildContext context) {
    return (SimpleContextMenuActionBuilder(
            Key('browse_file_context_menu_action'),
            SvgPicture.asset(imagePaths.icMore, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).browse)
        ..onActionClick((_) => controller.openFilePickerByType(context, FileType.any)))
      .build();
  }

  Widget _buildEmailAddress(BuildContext context) {
    return Column(
      children: [
        Obx(() => Padding(
            padding: EdgeInsets.only(left: responsiveUtils.isMobile(context) ? 16 : 0),
            child: (EmailAddressInputBuilder(context, imagePaths, responsiveUtils,
                    PrefixEmailAddress.to,
                    controller.listToEmailAddress,
                    controller.listEmailAddressType,
                    expandMode: controller.toAddressExpandMode.value,
                    controller: controller.toEmailAddressController,
                    focusNode: controller.toEmailAddressFocusNode,
                    isInitial: controller.isInitialRecipient.value)
                ..addOnFocusEmailAddressChangeAction((prefixEmailAddress, focus) => controller.onEmailAddressFocusChange(prefixEmailAddress, focus))
                ..addOnShowFullListEmailAddressAction((prefixEmailAddress) => controller.showFullEmailAddress(prefixEmailAddress))
                ..addOnAddEmailAddressTypeAction((prefixEmailAddress) => controller.addEmailAddressType(prefixEmailAddress))
                ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
                ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word)))
              .build()
        )),
        Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true
            ? Divider(color: AppColor.colorDividerComposer, height: 1)
            : SizedBox.shrink()),
        Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true
            ? Padding(
                padding: EdgeInsets.only(left: responsiveUtils.isMobile(context) ? 16 : 0),
                child: (EmailAddressInputBuilder(context, imagePaths, responsiveUtils,
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
                    ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word)))
                  .build())
            : SizedBox.shrink()
        ),
        Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true
            ? Divider(color: AppColor.colorDividerComposer, height: 1)
            : SizedBox.shrink()),
        Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true
            ? Padding(
                padding: EdgeInsets.only(left: responsiveUtils.isMobile(context) ? 16 : 0),
                child: (EmailAddressInputBuilder(context, imagePaths, responsiveUtils,
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
                    ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word)))
                  .build())
            : SizedBox.shrink()
        ),
      ],
    );
  }

  Widget _buildSubjectEmail(BuildContext context) {
    return Row(
        children: [
          Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                  '${AppLocalizations.of(context).subject_email}:',
                  style: TextStyle(fontSize: 15, color: AppColor.colorHintEmailAddressInput))),
          Expanded(
              child: FocusScope(child: Focus(
                onFocusChange: (focus) => controller.onSubjectEmailFocusChange(focus),
                child: (TextFieldBuilder()
                    ..key(Key('subject_email_input'))
                    ..cursorColor(AppColor.colorTextButton)
                    ..maxLines(responsiveUtils.isMobile(context) ? null : 1)
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
                  onTap: () => controller.openPickAttachmentMenu(context, _pickAttachmentsActionTiles(context))),
            ])
        )
    );
  }

  Widget _buildBodyMobile(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(children: [
        _buildEmailAddress(context),
        Divider(color: AppColor.colorDividerComposer, height: 1),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: _buildSubjectEmail(context)),
        Divider(color: AppColor.colorDividerComposer, height: 1),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16),  child: _buildListButton(context)),
        Divider(color: AppColor.colorDividerComposer, height: 1),
        Obx(() => controller.attachments.isNotEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _buildAttachmentsTitle(context, controller.attachments, controller.expandModeAttachments.value))
            : SizedBox.shrink()),
        Obx(() => controller.attachments.isEmpty
            ? _buildAttachmentsLoadingView()
            : SizedBox.shrink()),
        Obx(() => controller.attachments.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                child: _buildAttachmentsList(context, controller.attachments, controller.expandModeAttachments.value))
            : SizedBox.shrink()),
        Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: _buildComposerEditor(context)),
      ])
    );
  }

  Widget _buildBodyTablet(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(children: [
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
                padding: EdgeInsets.only(left: 16),
                child: Column(children: [
                  _buildEmailAddress(context),
                  Divider(color: AppColor.colorDividerComposer, height: 1),
                  Padding(padding: EdgeInsets.only(right: 16), child: _buildSubjectEmail(context)),
                  Divider(color: AppColor.colorDividerComposer, height: 1),
                  _buildListButton(context),
                ]),
              ))
            ])),
        Divider(color: AppColor.colorDividerComposer, height: 1),
        Padding(
            padding: EdgeInsets.only(left: 60, right: 25),
            child: Column(children: [
              Obx(() => controller.attachments.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _buildAttachmentsTitle(context, controller.attachments, controller.expandModeAttachments.value))
                  : SizedBox.shrink()),
              Obx(() => controller.attachments.isEmpty
                  ? _buildAttachmentsLoadingView()
                  : SizedBox.shrink()),
              Obx(() => controller.attachments.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                      child: _buildAttachmentsList(context, controller.attachments, controller.expandModeAttachments.value))
                  : SizedBox.shrink()),
              Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
                  child: _buildComposerEditor(context)),
            ])
        )
      ])
    );
  }

  Widget _buildComposerEditor(BuildContext context) {
    return Obx(() {
      if (controller.composerArguments.value?.emailActionType == EmailActionType.compose) {
        return HtmlEditor(
          key: Key('composer_editor'),
          minHeight: 550,
          onCreated: (editorApi) => controller.htmlEditorApi = editorApi);
      } else {
        final message = controller.getContentEmail(context);
        return message != null && message.isNotEmpty
            ? HtmlEditor(
                key: Key('composer_editor'),
                minHeight: 550,
                onCreated: (editorApi) => controller.htmlEditorApi = editorApi,
                initialContent: message)
            : SizedBox.shrink();
      }
    });
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
    if (expandMode == ExpandMode.EXPAND) {
      return LayoutBuilder(builder: (context, constraints) {
        return GridView.builder(
            key: Key('list_attachment_full'),
            primary: false,
            shrinkWrap: true,
            itemCount: attachments.length,
            gridDelegate: SliverGridDelegateFixedHeight(
                height: 60,
                crossAxisCount: _getMaxItemRowListAttachment(context, constraints),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0),
            itemBuilder: (context, index) =>
                (AttachmentFileComposerBuilder(context, imagePaths, attachments[index])
                  ..addOnDeleteAttachmentAction((attachment) => controller.removeAttachmentAction(attachment)))
              .build()
        );
      });
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
    return constraints.maxWidth / _getMaxItemRowListAttachment(context, constraints);
  }
}