import 'dart:io';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/web_view_state.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_file_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_content_place_holder_loading_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/sender_and_receiver_information_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:filesize/filesize.dart';

class EmailView extends GetView {

  final emailController = Get.find<EmailController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final htmlMessagePurifier = Get.find<HtmlMessagePurifier>();

  @override
  Widget build(BuildContext context) {
    emailController.viewState.value.map((success) {
      if (success is WebViewLoadCompletedState && emailController.emailContents.isNotEmpty) {
        emailController.dispatchState(Right(WebViewLoadingState()));
      }
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.primaryLightColor,
      body: SafeArea(
        right: false,
        left: false,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAppBar(context),
              Expanded(child: _buildEmailBody(context)),
              _buildBottomBar(context),
            ])
        )
      ));
  }

  Widget _buildAppBar(BuildContext context) {
    return Obx(() => Padding(
      padding: EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 6),
      child: (AppBarMailWidgetBuilder(
              context,
              imagePaths,
              responsiveUtils,
              emailController.mailboxDashBoardController.selectedEmail.value)
          ..onBackActionClick(() => emailController.backToThreadView())
          ..onUnreadEmailActionClick((presentationEmail) =>
              emailController.markAsEmailRead(presentationEmail, ReadActions.markAsUnread))
          ..addOnMoveToMailboxActionClick((presentationEmail) =>
              emailController.openDestinationPickerView(presentationEmail))
          ..addOnMarkAsStarActionClick((presentationEmail) =>
              emailController.markAsStarEmail(presentationEmail)))
        .build()));
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 6),
      child: (BottomBarMailWidgetBuilder(context, imagePaths, responsiveUtils)
          ..addOnPressEmailAction((emailActionType) => emailController.pressEmailAction(emailActionType)))
        .build());
  }

  Widget _buildEmailBody(BuildContext context) {
    return Container(
      color: AppColor.bgMessenger,
      margin: EdgeInsets.zero,
      alignment: Alignment.topCenter,
      child: Obx(() => emailController.mailboxDashBoardController.selectedEmail.value != null
        ? SingleChildScrollView(
            physics : ClampingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.zero,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              color: AppColor.bgMessenger,
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildEmailSubject(),
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
      padding: EdgeInsets.only(left: 8, top: 4, bottom: 16),
      child: Text(
          '${emailController.mailboxDashBoardController.selectedEmail.value?.subject}',
          style: TextStyle(fontSize: 18, color: AppColor.mailboxTextColor, fontWeight: FontWeight.w500)
      ));
  }

  Widget _buildLoadingView() {
    return Obx(() => emailController.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) => success is LoadingState || success is WebViewLoadingState
        ? EmailContentPlaceHolderLoading(responsiveUtils: responsiveUtils)
        : SizedBox.shrink()));
  }

  Widget _buildEmailMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
          _buildLoadingView(),
          _buildAttachments(context),
          _buildEmailContent(),
        ],
      )
    );
  }

  Widget _buildAttachments(BuildContext context) {
   return Obx(() => emailController.viewState.value.fold(
    (failure) => SizedBox.shrink(),
    (success) {
      if (success is LoadingState || success is WebViewLoadingState) {
        return SizedBox.shrink();
      } else {
        final attachments = emailController.attachments.attachmentsWithDispositionAttachment;
        return attachments.isNotEmpty
          ? _buildAttachmentsBody(context, attachments)
          : SizedBox.shrink();
      }
    }));
  }

  int _getAttachmentLimitDisplayed(BuildContext context) {
    if (responsiveUtils.isMobile(context)) {
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
                  if (Platform.isAndroid) {
                    emailController.downloadAttachments(context, [attachment]);
                  } else {
                    emailController.exportAttachment(context, attachment);
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

  Widget _buildEmailContent() {
    return Obx(() => emailController.emailContents.isNotEmpty
      ? HtmlContentViewer(
          message: emailController.emailContents.first.content,
          onWebViewLoadStop: (webController, uri) => emailController.dispatchState(Right(WebViewLoadCompletedState())),
          mailtoDelegate: (uri) async {})
      : SizedBox.shrink());
  }
}