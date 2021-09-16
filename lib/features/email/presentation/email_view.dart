import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_file_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_content_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/message_content_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/sender_and_receiver_information_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailView extends GetWidget {

  final emailController = Get.find<EmailController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final htmlMessagePurifier = Get.find<HtmlMessagePurifier>();

  @override
  Widget build(BuildContext context) {
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
              Expanded(child: _buildEmailContent(context)),
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
              emailController.markAsEmailRead(presentationEmail, ReadActions.markAsUnread)))
        .build()));
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 6),
      child: (BottomBarMailWidgetBuilder(context, imagePaths, responsiveUtils)
          ..addOnPressEmailAction((emailActionType) => emailController.pressEmailAction(emailActionType)))
        .build());
  }

  Widget _buildEmailContent(BuildContext context) {
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
      (success) => success == UIState.loading
        ? Center(child: Padding(
            padding: EdgeInsets.only(top: 25, bottom: 16),
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: AppColor.primaryColor))))
        : SizedBox.shrink()));
  }

  Widget _buildEmailMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 24),
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
          _buildListMessageContent(),
          _buildListAttachments(context),
        ],
      )
    );
  }

  Widget _buildListAttachments(BuildContext context) {
    if (emailController.mailboxDashBoardController.selectedEmail.value?.hasAttachment == true) {
      return Obx(() => emailController.viewState.value.fold(
        (failure) => SizedBox.shrink(),
        (success) {
          if (success is GetEmailContentSuccess && success.emailContent != null) {
            final attachments = success.emailContent!.getListAttachment();
            return attachments.isNotEmpty
              ? GridView.builder(
                  key: Key('list_attachment'),
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 16),
                  itemCount: attachments.length,
                  gridDelegate: SliverGridDelegateFixedHeight(
                      height: 60,
                      crossAxisCount: responsiveUtils.isMobile(context) ? 2 : 4,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 8.0),
                  itemBuilder: (context, index) =>
                      (AttachmentFileTileBuilder(imagePaths, attachments[index])
                        ..onDownloadAttachmentFileActionClick((attachment) =>
                            emailController.downloadAttachments(context, [attachment])))
                    .build())
              : SizedBox.shrink();
          } else {
            return SizedBox.shrink();
          }
        })
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildListMessageContent() {
    return Obx(() => emailController.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) {
        if (success is GetEmailContentSuccess && success.emailContent != null) {
          final messageContents = success.emailContent!.getListMessageContent();
          final attachmentsInline = success.emailContent!.getListAttachmentInline();
          return messageContents.isNotEmpty
            ? ListView.builder(
                primary: false,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 16),
                key: Key('list_message_content'),
                itemCount: messageContents.length,
                itemBuilder: (context, index) =>
                  MessageContentTileBuilder(
                      htmlMessagePurifier: htmlMessagePurifier,
                      messageContent: messageContents[index],
                      attachmentInlines: attachmentsInline,
                      session: emailController.mailboxDashBoardController.sessionCurrent,
                      accountId: emailController.mailboxDashBoardController.accountId.value)
                    .build())
            : SizedBox.shrink();
        } else {
          return SizedBox.shrink();
        }
      })
    );
  }
}