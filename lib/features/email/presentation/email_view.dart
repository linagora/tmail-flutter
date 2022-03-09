import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_file_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachments_place_holder_loading_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_content_item_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_content_place_holder_loading_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:filesize/filesize.dart';

class EmailView extends GetView {

  final emailController = Get.find<EmailController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  static const int LIMIT_ADDRESS_DISPLAY = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        decoration: !(responsiveUtils.isMobile(context) && responsiveUtils.isMobileDevice(context))
          ? BoxDecoration(border: Border(left: BorderSide(color: AppColor.colorLineLeftEmailView, width: 1.0)))
          : null,
        child: SafeArea(
            right: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
            left: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAppBar(context),
                  Obx(() => emailController.currentEmail != null
                      ? _buildDivider()
                      : SizedBox.shrink()),
                  Expanded(child: _buildEmailBody(context)),
                  Obx(() => emailController.currentEmail != null
                      ? Divider(color: AppColor.colorDividerEmailView, height: 1)
                      : SizedBox.shrink()),
                  _buildBottomBar(context),
                ]
            )
        ),
      )
    );
  }

  Widget _buildDivider({EdgeInsets? edgeInsets}){
    return Padding(
      padding: edgeInsets ?? EdgeInsets.symmetric(horizontal: 16),
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
          ..addOnEmailActionClick((email, action) => emailController.handleEmailAction(context, email, action))
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
      padding: EdgeInsets.zero,
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
      child: Obx(() => emailController.currentEmail != null
        ? SingleChildScrollView(
            physics : ClampingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.zero,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.zero,
              color: Colors.white,
              child:  _buildEmailMessage(context)
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
      padding: EdgeInsets.only(right: 16),
      child: Text(
          '${emailController.mailboxDashBoardController.selectedEmail.value?.getEmailTitle()}',
          style: TextStyle(fontSize: 20, color: AppColor.colorNameEmail)
      ));
  }

  Widget _buildEmailMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 10),
      alignment: Alignment.center,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildEmailSubject()),
                _buildEmailTime(context),
              ]),
          _buildDivider(edgeInsets: EdgeInsets.only(top: 16)),
          Obx(() => emailController.currentEmail != null
            ? _buildEmailAddress(
                context,
                emailController.currentEmail!,
                emailController.emailAddressExpandMode.value,
                emailController.isDisplayFullEmailAddress.value)
            : SizedBox.shrink()),
          _buildDivider(edgeInsets: EdgeInsets.only(top: 4)),
          _buildAttachments(context),
          _buildListEmailContent(),
        ],
      )
    );
  }

  Widget _buildEmailTime(BuildContext context) {
    return Transform(
        transform: Matrix4.translationValues(0.0, 12.0, 0.0),
        child: Text(
            '${emailController.currentEmail?.getReceivedAt(
                Localizations.localeOf(context).toLanguageTag(),
                pattern: emailController.currentEmail?.receivedAt?.value.toLocal().toPatternForEmailView())}',
            maxLines: 1,
            overflow:TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColor.colorTime)));
  }

  Widget _buildEmailAddress(BuildContext context, PresentationEmail email, ExpandMode expandMode, bool isDisplayFull) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email.from.numberEmailAddress() > 0)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.from, isDisplayFull),
        if (email.to.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND)
          _buildDivider(edgeInsets: EdgeInsets.only(top: 4)),
        if (email.to.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.to, isDisplayFull),
        if (email.cc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildDivider(edgeInsets: EdgeInsets.only(top: 4)),
        if (email.cc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.cc, isDisplayFull),
        if (email.bcc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildDivider(edgeInsets: EdgeInsets.only(top: 4)),
        if (email.bcc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.bcc, isDisplayFull),
      ],
    );
  }

  Widget _buildEmailAddressByPrefix(
      BuildContext context,
      PresentationEmail presentationEmail,
      PrefixEmailAddress prefixEmailAddress,
      bool isDisplayFull,
  ) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                  '${prefixEmailAddress.asName(context)}:',
                  style: TextStyle(fontSize: 14, color: AppColor.colorEmailAddressPrefix))),
          Expanded(child: _buildEmailAddressWidget(
              context,
              presentationEmail,
              prefixEmailAddress.listEmailAddress(presentationEmail),
              prefixEmailAddress,
              isDisplayFull
          )),
          if (prefixEmailAddress == PrefixEmailAddress.from) _buildEmailAddressDetailButton(context),
        ]
    );
  }

  Widget _buildEmailAddressWidget(
      BuildContext context,
      PresentationEmail presentationEmail,
      List<EmailAddress> listEmailAddress,
      PrefixEmailAddress prefixEmailAddress,
      bool isDisplayFull,
  ) {
    final displayedEmailAddress = isDisplayFull ? listEmailAddress : listEmailAddress.sublist(0, LIMIT_ADDRESS_DISPLAY);
    return Padding(
        padding: EdgeInsets.only(top: 4),
        child: Wrap(
            children: [
              ...displayedEmailAddress.map((emailAddress) {
                return Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: () => emailController.openEmailAddressDialog(context, emailAddress),
                      child: Chip(
                        labelPadding: EdgeInsets.only(left: 8, right: 8, bottom: 2),
                        label: Text('${emailAddress.asString()}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        labelStyle: TextStyle(color: AppColor.colorNameEmail, fontSize: 15, fontWeight: FontWeight.normal),
                        backgroundColor: AppColor.colorEmailAddressTag,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(width: 0, color: AppColor.colorEmailAddressTag),
                        ),
                        avatar: (AvatarBuilder()
                            ..text('${emailAddress.asString().characters.first.toUpperCase()}')
                            ..addTextStyle(TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600))
                            ..avatarColor(emailAddress.avatarColors))
                          .build(),
                      ),
                    )
                );
              }).toList(),
              if (prefixEmailAddress == PrefixEmailAddress.to
                && presentationEmail.numberOfAllEmailAddress() > 1
                && !isDisplayFull)
                _buildEmailAddressCounter(context, presentationEmail),
            ]
        ));
  }

  Widget _buildEmailAddressDetailButton(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Padding(
            padding: EdgeInsets.only(top: 4, left: 16),
            child: TextButton(
              onPressed: () => emailController.toggleDisplayEmailAddressAction(),
              child: Text(
                emailController.isExpandEmailAddress
                    ? AppLocalizations.of(context).hide
                    : AppLocalizations.of(context).details,
                style: TextStyle(fontSize: 15, color: AppColor.colorTextButton, fontWeight: FontWeight.normal),
              ),
            )
        )
    );
  }

  String _getRemainCountAddressReceiver(PresentationEmail email) {
    if (email.numberOfAllEmailAddress() - LIMIT_ADDRESS_DISPLAY >= 999) {
      return '999';
    }
    return '${email.numberOfAllEmailAddress() - LIMIT_ADDRESS_DISPLAY}';
  }

  Widget _buildEmailAddressCounter(BuildContext context, PresentationEmail email) {
    return GestureDetector(
      onTap: () => emailController.showFullEmailAddress(),
      child: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Chip(
          labelPadding: EdgeInsets.symmetric(horizontal: 8),
          label: Text('+${_getRemainCountAddressReceiver(email)}', maxLines: 1, overflow: TextOverflow.ellipsis),
          labelStyle: TextStyle(color: AppColor.colorTextButton, fontSize: 15, fontWeight: FontWeight.normal),
          backgroundColor: AppColor.colorEmailAddressTag,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(width: 0, color: AppColor.colorEmailAddressTag),
          ),
        ),
      ),
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
        ..onActionClick((email) => emailController.handleEmailAction(context, email, EmailActionType.markAsUnread)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuEmailActionTile(BuildContext context, PresentationEmail email) {
    return [
      PopupMenuItem(padding: EdgeInsets.symmetric(horizontal: 8), child: _unreadEmailAction(context, email)),
    ];
  }
}