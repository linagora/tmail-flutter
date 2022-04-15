import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/network_connection_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_file_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/user_setting_popup_menu_mixin.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:filesize/filesize.dart';

class EmailView extends GetView with UserSettingPopupMenuMixin, NetworkConnectionMixin {

  final emailController = Get.find<EmailController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  static const int LIMIT_ADDRESS_DISPLAY = 1;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        emailController.backToThreadView(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: responsiveUtils.isDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
        body: Stack(children: [
          Container(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            decoration: responsiveUtils.isTabletLarge(context)
                ? BoxDecoration(border: Border(left: BorderSide(color: AppColor.colorLineLeftEmailView, width: 1.0)))
                : null,
            child: SafeArea(
                right: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
                left: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (responsiveUtils.isDesktop(context))
                        Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(right: 10, top: 16, bottom: 10),
                            child: _buildHeader(context)),
                      Expanded(child: _buildBody(context)),
                    ]
                )
            ),
          ),
          Obx(() => !emailController.mailboxDashBoardController.isNetworkConnectionAvailable() && (responsiveUtils.isMobile(context) || responsiveUtils.isTablet(context))
              ? Align(alignment: Alignment.bottomCenter, child: buildNetworkConnectionWidget(context))
              : SizedBox.shrink()),
        ])
      )
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(children: [
      Spacer(),
      Padding(
        padding: EdgeInsets.only(right: 16),
        child: (AvatarBuilder()
            ..text(emailController.mailboxDashBoardController.userProfile.value?.getAvatarText() ?? '')
            ..backgroundColor(Colors.white)
            ..textColor(Colors.black)
            ..context(context)
            ..addOnTapAvatarActionWithPositionClick((position) => openUserSettingAction(
                context,
                position,
                popupMenuUserSettingActionTile(context, () => emailController.mailboxDashBoardController.logoutAction())))
            ..addBoxShadows([BoxShadow(
                color: AppColor.colorShadowBgContentEmail,
                spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))])
            ..size(48))
          .build()),
    ]);
  }

  Widget _buildBody(BuildContext context) {
    return Container(
        decoration: responsiveUtils.isDesktop(context)
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
              color: Colors.white)
          : null,
        margin: responsiveUtils.isDesktop(context) ? EdgeInsets.all(16) : EdgeInsets.zero,
        padding: responsiveUtils.isDesktop(context) ? EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 3) : EdgeInsets.zero,
        child: Column(children: [
          _buildAppBar(context),
          if (responsiveUtils.isDesktop(context)) SizedBox(height: 5),
          Obx(() => emailController.currentEmail != null && !responsiveUtils.isDesktop(context)
              ? _buildDivider() : SizedBox.shrink()),
          Expanded(child: _buildEmailBody(context)),
          Obx(() => emailController.currentEmail != null
              ? Divider(color: AppColor.colorDividerEmailView, height: 1)
              : SizedBox.shrink()),
          _buildBottomBar(context),
        ])
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
      child: (AppBarMailWidgetBuilder(context, imagePaths, responsiveUtils, emailController.currentEmail, emailController.currentMailbox)
          ..onBackActionClick(() => emailController.backToThreadView(context))
          ..addOnEmailActionClick((email, action) => emailController.handleEmailAction(context, email, action))
          ..addOnMoreActionClick((email, position) => responsiveUtils.isMobile(context)
              ? emailController.openContextMenuAction(context, _emailActionMoreActionTile(context, email))
              : emailController.openPopupMenuAction(context, position, _popupMenuEmailActionTile(context, email))))
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
      child: Obx(() {
        if (emailController.currentEmail != null) {
          if (kIsWeb) {
            return _buildEmailMessage(context);
          } else {
            return SingleChildScrollView(
                physics : ClampingScrollPhysics(),
                child: Container(
                    margin: EdgeInsets.zero,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    child: _buildEmailMessage(context)
                )
            );
          }
        } else {
          return Center(child: _buildEmailEmpty(context));
        }
      })
    );
  }

  Widget _buildEmailEmpty(BuildContext context) {
    return Text(
      AppLocalizations.of(context).no_mail_selected,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 25, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold));
  }

  Widget _buildEmailSubject(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: SelectableText(
          '${emailController.mailboxDashBoardController.selectedEmail.value?.getEmailTitle()}',
          maxLines: kIsWeb ? 3 : null,
          minLines: kIsWeb ? 1 : null,
          cursorColor: AppColor.colorTextButton,
          style: TextStyle(
              fontSize: 20,
              color: AppColor.colorNameEmail,
              fontWeight: responsiveUtils.isDesktop(context) ? FontWeight.w500 : FontWeight.normal)
      ));
  }

  Widget _buildEmailMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 10),
      alignment: Alignment.center,
      color: Colors.white,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildEmailSubject(context)),
                    _buildEmailTime(context),
                  ]),
              if (responsiveUtils.isDesktop(context)) SizedBox(height: 20),
              if (!responsiveUtils.isDesktop(context)) _buildDivider(edgeInsets: EdgeInsets.only(top: 16)),
              Obx(() => emailController.currentEmail != null
                  ? _buildEmailAddress(
                      context,
                      emailController.currentEmail!,
                      emailController.emailAddressExpandMode.value,
                      emailController.isDisplayFullEmailAddress.value)
                  : SizedBox.shrink()),
              _buildDivider(edgeInsets: EdgeInsets.only(top: 8)),
              _buildAttachments(context),
              if (kIsWeb)
                Expanded(child: _buildEmailContent(context, constraints))
              else
                _buildEmailContent(context, constraints),
              SizedBox(height: 16),
            ],
          );
        })
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
          _buildDivider(edgeInsets: EdgeInsets.only(top: kIsWeb ? 8 : 4, bottom: 4)),
        if (email.to.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.to, isDisplayFull),
        if (email.cc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildDivider(edgeInsets: EdgeInsets.only(top: kIsWeb ? 8 : 4, bottom: 4)),
        if (email.cc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.cc, isDisplayFull),
        if (email.bcc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildDivider(edgeInsets: EdgeInsets.only(top: kIsWeb ? 8 : 4, bottom: 4)),
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
              padding: EdgeInsets.only(top: kIsWeb ? 10: 20),
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
        return SizedBox.shrink();
      } else {
        final attachments = emailController.attachments.listAttachmentsDisplayedOutSide;
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
      return 3;
    } else {
      return 4;
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
          padding: EdgeInsets.only(top: isExpand ? 0 : 16, bottom: 16),
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
                    emailController.downloadAttachmentForWeb(context, attachment);
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

  Widget _buildEmailContent(BuildContext context, BoxConstraints constraints) {
    return Obx(() => emailController.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) {
        if (success is LoadingState) {
          return Align(alignment: Alignment.topCenter, child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CupertinoActivityIndicator(color: AppColor.colorLoading))));
        } else {
          if (emailController.emailContents.isNotEmpty) {
            final allEmailContents = emailController.emailContents.asHtmlString;

            if (kIsWeb) {
              return HtmlContentViewerOnWeb(
                  widthContent: constraints.maxWidth,
                  heightContent: responsiveUtils.getSizeScreenHeight(context),
                  contentHtml: allEmailContents,
                  controller: HtmlViewerControllerForWeb(),
                  mailtoDelegate: (uri) => emailController.openMailToLink(uri));
            } else {
              return HtmlContentViewer(
                  heightContent: responsiveUtils.getSizeScreenHeight(context),
                  contentHtml: allEmailContents,
                  mailtoDelegate: (uri) async => emailController.openMailToLink(uri));
            }
          } else {
            return SizedBox.shrink();
          }
        }
      }));
  }

  List<Widget> _emailActionMoreActionTile(BuildContext context, PresentationEmail email) {
    return <Widget>[
      _markAsEmailUnreadAction(context, email),
      _markAsEmailSpamOrUnSpamAction(context, email),
    ];
  }

  Widget _markAsEmailUnreadAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
            Key('mark_as_unread_action'),
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

  Widget _markAsEmailSpamOrUnSpamAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
            Key('mark_as_spam_or_un_spam_action'),
            SvgPicture.asset(
                emailController.currentMailbox?.isSpam == true ? imagePaths.icNotSpam : imagePaths.icSpam,
                width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
            emailController.currentMailbox?.isSpam == true
                ? AppLocalizations.of(context).remove_from_spam
                : AppLocalizations.of(context).mark_as_spam,
            email,
            iconLeftPadding: responsiveUtils.isMobile(context)
                ? EdgeInsets.only(left: 12, right: 16)
                : EdgeInsets.only(right: 12),
            iconRightPadding: responsiveUtils.isMobile(context)
                ? EdgeInsets.only(right: 12)
                : EdgeInsets.zero)
        ..onActionClick((email) => emailController.handleEmailAction(context, email,
            emailController.currentMailbox?.isSpam == true ? EmailActionType.unSpam : EmailActionType.moveToSpam)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuEmailActionTile(BuildContext context, PresentationEmail email) {
    return [
      PopupMenuItem(padding: EdgeInsets.symmetric(horizontal: 8), child: _markAsEmailUnreadAction(context, email)),
      PopupMenuItem(padding: EdgeInsets.symmetric(horizontal: 8), child: _markAsEmailSpamOrUnSpamAction(context, email)),
    ];
  }
}