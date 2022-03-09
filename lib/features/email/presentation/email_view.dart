import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_file_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachments_place_holder_loading_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_content_item_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_content_place_holder_loading_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/sender_and_receiver_information_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:filesize/filesize.dart';

class EmailView extends GetView {

  final emailController = Get.find<EmailController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryLightColor,
      body: SafeArea(
        right: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
        left: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAppBar(context),
            _buildDivider(),
            Expanded(child: _buildEmailBody(context)),
            _buildBottomBar(context),
          ]
        )
      ));
  }

  Widget _buildDivider(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: AppColor.colorDividerEmailView, height: 0.5));
  }

  Widget _buildAppBar(BuildContext context) {
    return Obx(() => Padding(
      padding: EdgeInsets.only(top: 6),
      child: (AppBarMailWidgetBuilder(
              context,
              imagePaths,
              responsiveUtils,
              emailController.currentEmail,
              emailController.currentMailbox)
          ..onBackActionClick(() => emailController.backToThreadView())
          ..addOnEmailActionClick((email, action) => emailController.handleEmailAction(email, action))
          ..addOnMoreActionClick((email, position) => responsiveUtils.isMobileDevice(context)
              ? emailController.openMoreMenuEmailAction(
                  context,
                  _emailActionMoreActionTile(context, email),
                  cancelButton: _buildCancelButton(context))
              : emailController.openMoreMenuEmailActionForTablet(
                  context,
                  position,
                  _popupMenuEmailActionTile(context, email))))
        .build()));
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 6),
      child: Obx(() => (BottomBarMailWidgetBuilder(
              context,
              imagePaths,
              responsiveUtils,
              emailController.mailboxDashBoardController.selectedEmail.value)
          ..addOnPressEmailAction((emailActionType) => emailController.pressEmailAction(emailActionType)))
        .build()));
  }

  Widget _buildEmailBody(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.zero,
      alignment: Alignment.topCenter,
      child: Obx(() => emailController.mailboxDashBoardController.selectedEmail.value != null
        ? SingleChildScrollView(
            physics : ClampingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.zero,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  top: 16),
              color: Colors.white,
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildEmailMessage(context),
                ])
            ))
        : Center(child: _buildEmailEmpty(context))
      )
    );
  }

  Widget _buildEmailEmpty(BuildContext context) {
    return Text(
      AppLocalizations.of(context).no_mail_selected,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 25, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold));
  }

  Widget _buildEmailSubject() {
    return Padding(
      padding: EdgeInsets.only(left: 8, top: 25, bottom: 16),
      child: Text(
          '${emailController.mailboxDashBoardController.selectedEmail.value?.getEmailTitle()}',
          style: TextStyle(fontSize: 22, color: AppColor.colorNameEmail, fontWeight: FontWeight.w700)
      ));
  }

  Widget _buildEmailMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: 16,
          left: 16,
          right: 16,
          top: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColor.colorShadowBgContentEmail,
            spreadRadius: 3,
            blurRadius: 3,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
        color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Obx(() => SenderAndReceiverInformationTileBuilder(
              context,
              imagePaths,
              emailController.mailboxDashBoardController.selectedEmail.value,
              emailController.emailAddressExpandMode.value)
            .onOpenExpandAddressReceiverActionClick(() => emailController.toggleDisplayEmailAddressAction(expandMode: ExpandMode.EXPAND))
            .build()),
          Padding(
              padding: EdgeInsets.zero,
              child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.1)),
          _buildEmailSubject(),
          _buildAttachments(context),
          _buildListEmailContent(),
        ],
      )
    );
  }

  Widget _buildAttachments(BuildContext context) {
   return Obx(() => emailController.viewState.value.fold(
    (failure) => SizedBox.shrink(),
    (success) {
      if (success is LoadingState) {
        return AttachmentsPlaceHolderLoading(responsiveUtils: responsiveUtils);
      } else {
        final attachments = emailController.attachments.attachmentsWithDispositionAttachment;
        return attachments.isNotEmpty
          ? _buildAttachmentsBody(context, attachments)
          : SizedBox.shrink();
      }
    }));
  }

  int _getAttachmentLimitDisplayed(BuildContext context) {
    if (responsiveUtils.isMobileDevice(context)) {
      return 2;
    } else if (responsiveUtils.isTablet(context)) {
      return 4;
    } else {
      return 3;
    }
  }

  Widget _buildAttachmentsBody(BuildContext context, List<Attachment> attachments) {
    final attachmentLimitDisplayed = _getAttachmentLimitDisplayed(context);
    final countAttachments = _getListAttachmentsSize(
        context,
        emailController.attachmentsExpandMode.value,
        attachments,
        attachmentLimitDisplayed);
    final isExpand = emailController.attachmentsExpandMode.value == ExpandMode.EXPAND
        && attachments.length > attachmentLimitDisplayed;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isExpand)
          Padding(
            padding: EdgeInsets.zero,
            child: _buildAttachmentsHeader(context, attachments)),
        GridView.builder(
          key: Key('list_attachment'),
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: isExpand ? 0 : 16),
          itemCount: countAttachments,
          gridDelegate: SliverGridDelegateFixedHeight(
            height: 60,
            crossAxisCount: attachmentLimitDisplayed,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 8.0),
          itemBuilder: (context, index) =>
                (AttachmentFileTileBuilder(
                    imagePaths,
                    attachments[index],
                    attachments.length,
                    attachmentLimitDisplayed)
                ..setExpandMode((countAttachments - 1 == index) ? emailController.attachmentsExpandMode.value : null)
                ..onExpandAttachmentActionClick(() => emailController.toggleDisplayAttachmentsAction())
                ..onDownloadAttachmentFileActionClick((attachment) {
                  if (kIsWeb) {
                    emailController.downloadAttachmentForWeb(attachment);
                  } else {
                    if (Platform.isAndroid) {
                      emailController.downloadAttachments(context, [attachment]);
                    } else if (Platform.isIOS) {
                      emailController.exportAttachment(context, attachment);
                    }
                  }
                }))
            .build())
      ],
    );
  }

  int _getListAttachmentsSize(
      BuildContext context,
      ExpandMode expandMode,
      List<Attachment> attachments,
      int limitDisplayAttachment
  ) {
    if (attachments.length > limitDisplayAttachment) {
      return expandMode == ExpandMode.EXPAND
        ? attachments.length
        : attachments.sublist(0, limitDisplayAttachment).length;
    } else {
      return attachments.length;
    }
  }

  Widget _buildAttachmentsHeader(BuildContext context, List<Attachment> attachments) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context).count_attachment(attachments.length)}',
              style: TextStyle(fontSize: 12, color: AppColor.baseTextColor)),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                '(${filesize(attachments.totalSize(), 1)})',
                style: TextStyle(fontSize: 12, color: AppColor.nameUserColor, fontWeight: FontWeight.w500)))
          ],
        ),
        if (attachments.length > 2)
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: IconButton(
              icon: SvgPicture.asset(imagePaths.icExpandAttachment,
                width: 20,
                height: 20,
                fit: BoxFit.fill),
              onPressed: () => emailController.toggleDisplayAttachmentsAction()
            ))
      ],
    );
  }

  Widget _buildListEmailContent() {
    return Obx(() => emailController.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) {
        if (success is LoadingState) {
          return EmailContentPlaceHolderLoading(responsiveUtils: responsiveUtils);
        } else {
          if (emailController.emailContents.isNotEmpty) {
            return ListView.builder(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10),
              key: Key('list_email_content'),
              itemCount: emailController.emailContents.length,
              itemBuilder: (context, index) =>
                EmailContentItemBuilder(
                  context,
                  emailController.emailContents[index],
                  loadingWidget: EmailContentPlaceHolderLoading(responsiveUtils: responsiveUtils)
                ).build());
          } else {
            return SizedBox.shrink();
          }
        }
      }));
  }

  List<Widget> _emailActionMoreActionTile(BuildContext context, PresentationEmail email) {
    return <Widget>[
      _unreadEmailAction(context, email),
    ];
  }

  Widget _buildCancelButton(BuildContext context) {
    return CupertinoActionSheetAction(
      child: Text(
          AppLocalizations.of(context).cancel,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: AppColor.colorTextButton)),
      onPressed: () => emailController.closeMoreMenu(),
    );
  }

  Widget _unreadEmailAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
            Key('email_action_unread_action'),
            SvgPicture.asset(imagePaths.icUnreadEmail, width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
            AppLocalizations.of(context).mark_as_unread,
            email,
            iconLeftPadding: responsiveUtils.isMobile(context)
                ? EdgeInsets.only(left: 12, right: 16)
                : EdgeInsets.only(right: 12),
            iconRightPadding: responsiveUtils.isMobile(context)
                ? EdgeInsets.only(right: 12)
                : EdgeInsets.zero)
        ..onActionClick((email) => emailController.handleEmailAction(email, EmailActionType.markAsUnread)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuEmailActionTile(BuildContext context, PresentationEmail email) {
    return [
      PopupMenuItem(padding: EdgeInsets.symmetric(horizontal: 8), child: _unreadEmailAction(context, email)),
    ];
  }
}