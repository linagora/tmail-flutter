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
      mobile: WillPopScope(
          onWillPop: () async {
            controller.saveEmailAsDrafts(context);
            return true;
          },
          child: GestureDetector(
              onTap: () {
                controller.clearFocusEditor(context);
              },
              child: Scaffold(
                backgroundColor: AppColor.primaryLightColor,
                body: SafeArea(
                    right: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
                    left: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
                    child: Container(
                        color: Colors.white,
                        child: Column(children: [
                          Obx(() => Padding(
                            padding: EdgeInsets.only(left: 8, right: 8,
                                top: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context) ? 16 : 0,
                                bottom: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context) ? 8 : 0),
                            child: _buildAppBar(context, controller.isEnableEmailSendButton.value, controller.expandModeMobile.value),)),
                          Obx(() => controller.expandModeMobile == ExpandMode.COLLAPSE
                              ? Divider(color: AppColor.colorDividerComposer, height: 1)
                              : SizedBox.shrink()),
                          Expanded(child: _buildEditorAndAttachments(context))
                        ])
                    )
                ),
              )
          )
      ),
      tablet: WillPopScope(
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
                    child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                        width: responsiveUtils.getSizeScreenWidth(context) * 0.85,
                        height: responsiveUtils.getSizeScreenHeight(context) * 0.85,
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: SafeArea(
                                child: Column(children: [
                                  Obx(() => Padding(
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    child: _buildAppBar(context, controller.isEnableEmailSendButton.value, controller.expandModeMobile.value),)),
                                  Obx(() => controller.expandModeMobile == ExpandMode.COLLAPSE
                                      ? Divider(color: AppColor.colorDividerComposer, height: 1)
                                      : SizedBox.shrink()),
                                  Expanded(child: _buildEditorAndAttachments(context))
                                ])
                            )
                        )
                    )
                ))
              )
          )
      )
    );
  }

  Widget _buildAppBar(BuildContext context, bool isEnableSendButton, ExpandMode expandModeMobile) {
    return Row(children: [
        Material(
            type: MaterialType.circle,
            color: Colors.transparent,
            child: TextButton(
                child: Text(
                    AppLocalizations.of(context).cancel,
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: AppColor.colorTextButton)),
                onPressed: () {
                  controller.saveEmailAsDrafts(context);
                  controller.closeComposer(context);
                }
            )
        ),
        if (expandModeMobile == ExpandMode.EXPAND)
          Spacer(),
        if (expandModeMobile == ExpandMode.COLLAPSE)
          Expanded(child: Text(
            AppLocalizations.of(context).new_message.capitalizeFirstEach,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
          )),
        buildIconWeb(
            icon: SvgPicture.asset(imagePaths.icAttachmentsComposer, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).pick_attachments,
            onTap: () => controller.openPickAttachmentMenu(context, _pickAttachmentsActionTiles(context))),
        if (expandModeMobile == ExpandMode.COLLAPSE)
          buildIconWeb(
            icon: SvgPicture.asset(isEnableSendButton ? imagePaths.icSendMobile : imagePaths.icSendDisable, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).send,
            onTap: () => controller.sendEmailAction(context)),
    ]);
  }

  Widget _buildTitleComposer(BuildContext context, bool isEnableSendButton) {
    return Row(children: [
      Expanded(child: Text(
        AppLocalizations.of(context).new_message.capitalizeFirstEach,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.black),
      )),
      buildIconWeb(
        iconSize: 36,
        iconPadding: EdgeInsets.zero,
        icon: SvgPicture.asset(isEnableSendButton ? imagePaths.icSendMobile : imagePaths.icSendDisable, width: 36, height: 36, fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).send,
        onTap: () => controller.sendEmailAction(context)),
    ]);
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
    return Column(children: [
      Obx(() => (EmailAddressInputBuilder(
              context,
              imagePaths,
              PrefixEmailAddress.to,
              controller.listToEmailAddress,
              controller.listEmailAddressType,
              controller: controller.toEmailAddressController,
              isInitial: controller.isInitialRecipient.value)
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
                PrefixEmailAddress.cc,
                controller.listCcEmailAddress,
                controller.listEmailAddressType,
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
              PrefixEmailAddress.bcc,
              controller.listBccEmailAddress,
              controller.listEmailAddressType,
              controller: controller.bccEmailAddressController,
              isInitial: controller.isInitialRecipient.value,)
            ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
            ..addOnSuggestionEmailAddress((word) => controller.getAutoCompleteSuggestion(word)))
          .build()
        : SizedBox.shrink()
      ),
    ]);
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
          child: (TextFieldBuilder()
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
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification) {
            if (scrollInfo.metrics.pixels >= 30) {
              controller.collapseComposer(ExpandMode.COLLAPSE);
            } else if (scrollInfo.metrics.pixels <= scrollInfo.metrics.minScrollExtent) {
              controller.collapseComposer(ExpandMode.EXPAND);
            }
          }
          return false;
        },
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(children: [
            Obx(() => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _buildTitleComposer(context, controller.isEnableEmailSendButton.value))),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _buildEmailAddress(context)),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _buildSubjectEmail(context)),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
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
        )
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