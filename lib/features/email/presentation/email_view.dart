import 'package:core/core.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/network_connection_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_file_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailView extends GetWidget<EmailController> with NetworkConnectionMixin {

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  static const int limitAddressDisplay = 1;

  EmailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.closeEmailView(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: responsiveUtils.isWebDesktop(context)
            ? AppColor.colorBgDesktop
            : Colors.white,
        body: Row(children: [
          if (_supportVerticalDivider(context))
            const VerticalDivider(
                color: AppColor.lineItemListColor,
                width: 1,
                thickness: 0.2),
          Expanded(child: SafeArea(
              right: responsiveUtils.isLandscapeMobile(context),
              left: responsiveUtils.isLandscapeMobile(context),
              child: Container(
                  decoration: responsiveUtils.isWebDesktop(context)
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
                          color: Colors.white)
                      : null,
                  margin: responsiveUtils.isWebDesktop(context)
                      ? const EdgeInsets.only(right: 16, top: 16, bottom: 16)
                      : EdgeInsets.zero,
                  padding: responsiveUtils.isWebDesktop(context)
                      ? const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 3)
                      : EdgeInsets.zero,
                  child: Column(children: [
                    _buildAppBar(context),
                    _buildVacationNotificationMessage(context),
                    if (responsiveUtils.isWebDesktop(context))
                      const SizedBox(height: 5),
                    Obx(() {
                     if (controller.currentEmail != null &&
                         !responsiveUtils.isWebDesktop(context)) {
                       return _buildDivider();
                     }
                     return const SizedBox.shrink();
                    }),
                    Expanded(child: _buildEmailBody(context)),
                    Obx(() => controller.currentEmail != null
                        ? const Divider(color: AppColor.colorDividerEmailView, height: 1)
                        : const SizedBox.shrink()),
                    _buildBottomBar(context),
                  ])
              )
          ))
        ])
      )
    );
  }

  bool _supportVerticalDivider(BuildContext context) {
    if (BuildUtils.isWeb) {
      return responsiveUtils.isTabletLarge(context);
    } else {
      return responsiveUtils.isLandscapeTablet(context) || responsiveUtils.isDesktop(context);
    }
  }

  Widget _buildDivider({EdgeInsets? edgeInsets}){
    return Padding(
      padding: edgeInsets ?? const EdgeInsets.symmetric(horizontal: 16),
      child: const Divider(color: AppColor.colorDividerEmailView, height: 0.5));
  }

  Widget _buildVacationNotificationMessage(BuildContext context) {
    return Obx(() {
      final vacation = controller.mailboxDashBoardController.vacationResponse.value;
      if (vacation?.vacationResponderIsValid == true &&
          (responsiveUtils.isMobile(context) ||
              responsiveUtils.isTablet(context) ||
              responsiveUtils.isLandscapeMobile(context))) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: VacationNotificationMessageWidget(
              radius: 0,
              margin: EdgeInsets.zero,
              vacationResponse: vacation!,
              actionGotoVacationSetting: () => controller.mailboxDashBoardController.goToVacationSetting(),
              actionEndNow: () => controller.mailboxDashBoardController.disableVacationResponder()),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: AppBarMailWidgetBuilder(
        controller.currentEmail,
        currentMailbox: controller.mailboxDashBoardController.searchController.isSearchEmailRunning
          ? controller.currentEmail?.findMailboxContain(controller.mailboxDashBoardController.mapMailbox)
          : controller.currentMailbox,
        isSearchIsRunning: controller.mailboxDashBoardController.searchController.isSearchEmailRunning,
        onBackActionClick: () => controller.closeEmailView(context),
        onEmailActionClick: (email, action) =>
            controller.handleEmailAction(context, email, action),
        onMoreActionClick: (email, position) {
          if (responsiveUtils.isMobile(context)) {
            controller.openContextMenuAction(
                context,
                _emailActionMoreActionTile(context, email));
          } else {
            controller.openPopupMenuAction(
                context,
                position,
                _popupMenuEmailActionTile(context, email));
          }
        }
      )
    ));
  }

  Widget _buildBottomBar(BuildContext context) {
    bool isMobileDevice = responsiveUtils.isPortraitMobile(context) ||
        responsiveUtils.isLandscapeMobile(context);
    return Padding(
      padding: EdgeInsets.only(
          bottom: isMobileDevice ? 16 : 0),
      child: Obx(() => (BottomBarMailWidgetBuilder(
              context,
              imagePaths,
              responsiveUtils,
              controller.mailboxDashBoardController.selectedEmail.value)
          ..addOnPressEmailAction((emailActionType) =>
              controller.pressEmailAction(emailActionType)))
        .build()));
  }

  Widget _buildEmailBody(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.zero,
        alignment: Alignment.topCenter,
        child: Obx(() {
          if (controller.currentEmail != null) {
            if (kIsWeb) {
              return _buildEmailMessage(context);
            } else {
              return SingleChildScrollView(
                  physics : const ClampingScrollPhysics(),
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
      ),
    );
  }

  Widget _buildEmailEmpty(BuildContext context) {
    return Text(
      AppLocalizations.of(context).no_mail_selected,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 25, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold));
  }

  Widget _buildEmailSubject(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: SelectableText(
          '${controller.mailboxDashBoardController.selectedEmail.value?.getEmailTitle()}',
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
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
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
              if (responsiveUtils.isDesktop(context)) const SizedBox(height: 20),
              if (!responsiveUtils.isDesktop(context)) _buildDivider(edgeInsets: const EdgeInsets.only(top: 16)),
              Obx(() => controller.currentEmail != null
                  ? _buildEmailAddress(
                      context,
                      controller.currentEmail!,
                      controller.emailAddressExpandMode.value,
                      controller.isDisplayFullEmailAddress.value)
                  : const SizedBox.shrink()),
              _buildDivider(edgeInsets: const EdgeInsets.only(top: 8)),
              _buildLoadingView(),
              _buildAttachments(context),
              if (kIsWeb)
                Expanded(child: _buildEmailContent(context, constraints))
              else
                _buildEmailContent(context, constraints),
              const SizedBox(height: 16),
            ],
          );
        })
    );
  }

  Widget _buildLoadingView() {
    return Obx(() {
      if (controller.emailContents.isEmpty) {
        return controller.viewState.value.fold(
          (failure) => const SizedBox.shrink(),
          (success) {
            if (success is GetEmailContentLoading) {
              return const Align(alignment: Alignment.topCenter, child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CupertinoActivityIndicator(color: AppColor.colorLoading))));
            } else {
              return const SizedBox.shrink();
            }
          });
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildEmailTime(BuildContext context) {
    return Transform(
        transform: Matrix4.translationValues(0.0, 12.0, 0.0),
        child: Text(
            '${controller.currentEmail?.getReceivedAt(
                Localizations.localeOf(context).toLanguageTag(),
                pattern: controller.currentEmail?.receivedAt?.value.toLocal().toPatternForEmailView())}',
            maxLines: 1,
            overflow:TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColor.colorTime)));
  }

  Widget _buildEmailAddress(BuildContext context, PresentationEmail email, ExpandMode expandMode, bool isDisplayFull) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email.from.numberEmailAddress() > 0)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.from, isDisplayFull),
        if (email.to.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND)
          _buildDivider(edgeInsets: const EdgeInsets.only(top: kIsWeb ? 8 : 4, bottom: 4)),
        if (email.to.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.to, isDisplayFull),
        if (email.cc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildDivider(edgeInsets: const EdgeInsets.only(top: kIsWeb ? 8 : 4, bottom: 4)),
        if (email.cc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildEmailAddressByPrefix(context, email, PrefixEmailAddress.cc, isDisplayFull),
        if (email.bcc.numberEmailAddress() > 0 && expandMode == ExpandMode.EXPAND && isDisplayFull)
          _buildDivider(edgeInsets: const EdgeInsets.only(top: kIsWeb ? 8 : 4, bottom: 4)),
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
              padding: const EdgeInsets.only(top: kIsWeb ? 10: 20),
              child: Text(
                  '${prefixEmailAddress.asName(context)}:',
                  style: const TextStyle(fontSize: 14, color: AppColor.colorEmailAddressPrefix))),
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
    final displayedEmailAddress = isDisplayFull
        ? listEmailAddress
        : listEmailAddress.sublist(0, limitAddressDisplay);

    return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
            children: [
              ...displayedEmailAddress.map((emailAddress) {
                return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: () => controller.openEmailAddressDialog(context, emailAddress),
                      child: Chip(
                        labelPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 2),
                        label: Text(emailAddress.asString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                        labelStyle: const TextStyle(color: AppColor.colorNameEmail, fontSize: 15, fontWeight: FontWeight.normal),
                        backgroundColor: AppColor.colorEmailAddressTag,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(width: 0, color: AppColor.colorEmailAddressTag),
                        ),
                        avatar: (AvatarBuilder()
                            ..text(emailAddress.asString().characters.first.toUpperCase())
                            ..addTextStyle(const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600))
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
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: TextButton(
              onPressed: () => controller.toggleDisplayEmailAddressAction(),
              child: Text(
                controller.isExpandEmailAddress
                    ? AppLocalizations.of(context).hide
                    : AppLocalizations.of(context).details,
                style: const TextStyle(fontSize: 15, color: AppColor.colorTextButton, fontWeight: FontWeight.normal),
              ),
            )
        )
    );
  }

  String _getRemainCountAddressReceiver(PresentationEmail email) {
    if (email.numberOfAllEmailAddress() - limitAddressDisplay >= 999) {
      return '999';
    }
    return '${email.numberOfAllEmailAddress() - limitAddressDisplay}';
  }

  Widget _buildEmailAddressCounter(BuildContext context, PresentationEmail email) {
    return GestureDetector(
      onTap: () => controller.showFullEmailAddress(),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Chip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          label: Text('+${_getRemainCountAddressReceiver(email)}', maxLines: 1, overflow: TextOverflow.ellipsis),
          labelStyle: const TextStyle(color: AppColor.colorTextButton, fontSize: 15, fontWeight: FontWeight.normal),
          backgroundColor: AppColor.colorEmailAddressTag,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 0, color: AppColor.colorEmailAddressTag),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
   return Obx(() {
     final attachments = controller.attachments.listAttachmentsDisplayedOutSide;
     return attachments.isNotEmpty
         ? _buildAttachmentsBody(context, attachments)
         : const SizedBox.shrink();
   });
  }

  int _getAttachmentLimitDisplayed(BuildContext context) {
    if (responsiveUtils.isMobile(context)
        || responsiveUtils.isLandscapeMobile(context)) {
      return 2;
    } else if (responsiveUtils.isTablet(context) ||
        responsiveUtils.isLandscapeTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  Widget _buildAttachmentsBody(BuildContext context, List<Attachment> attachments) {
    final attachmentLimitDisplayed = _getAttachmentLimitDisplayed(context);
    final countAttachments = _getListAttachmentsSize(
        context,
        controller.attachmentsExpandMode.value,
        attachments,
        attachmentLimitDisplayed);
    final isExpand = controller.attachmentsExpandMode.value == ExpandMode.EXPAND
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
          key: const Key('list_attachment'),
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
                ..setExpandMode((countAttachments - 1 == index) ? controller.attachmentsExpandMode.value : null)
                ..onExpandAttachmentActionClick(() => controller.toggleDisplayAttachmentsAction())
                ..onDownloadAttachmentFileActionClick((attachment) {
                  if (kIsWeb) {
                    controller.downloadAttachmentForWeb(context, attachment);
                  } else {
                    controller.exportAttachment(context, attachment);
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
              AppLocalizations.of(context).count_attachment(attachments.length),
              style: const TextStyle(fontSize: 12, color: AppColor.baseTextColor)),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '(${filesize(attachments.totalSize(), 1)})',
                style: const TextStyle(fontSize: 12, color: AppColor.nameUserColor, fontWeight: FontWeight.w500)))
          ],
        ),
        if (attachments.length > 2)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: SvgPicture.asset(imagePaths.icExpandAttachment,
                width: 20,
                height: 20,
                color: AppColor.primaryColor,
                fit: BoxFit.fill),
              onPressed: () => controller.toggleDisplayAttachmentsAction()
            ))
      ],
    );
  }

  Widget _buildEmailContent(BuildContext context, BoxConstraints constraints) {
    return Obx(() {
      if (controller.emailContents.isNotEmpty) {
        final allEmailContents = controller.emailContents.asHtmlString;

        if (kIsWeb) {
          return HtmlContentViewerOnWeb(
              widthContent: constraints.maxWidth,
              heightContent: responsiveUtils.getSizeScreenHeight(context),
              contentHtml: allEmailContents,
              controller: HtmlViewerControllerForWeb(),
              mailtoDelegate: (uri) => controller.openMailToLink(uri));
        } else {
          return HtmlContentViewer(
              heightContent: responsiveUtils.getSizeScreenHeight(context),
              contentHtml: allEmailContents,
              mailtoDelegate: (uri) async => controller.openMailToLink(uri));
        }
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  List<Widget> _emailActionMoreActionTile(BuildContext context, PresentationEmail email) {
    return <Widget>[
      _markAsEmailUnreadAction(context, email),
      _markAsEmailSpamOrUnSpamAction(context, email),
    ];
  }

  Widget _markAsEmailUnreadAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
            const Key('mark_as_unread_action'),
            SvgPicture.asset(imagePaths.icUnreadEmail, width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
            AppLocalizations.of(context).mark_as_unread,
            email,
            iconLeftPadding: responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(left: 12, right: 16)
                : const EdgeInsets.only(right: 12),
            iconRightPadding: responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(right: 12)
                : EdgeInsets.zero)
        ..onActionClick((email) => controller.handleEmailAction(context, email, EmailActionType.markAsUnread)))
      .build();
  }

  Widget _markAsEmailSpamOrUnSpamAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
            const Key('mark_as_spam_or_un_spam_action'),
            SvgPicture.asset(
                controller.currentMailbox?.isSpam == true ? imagePaths.icNotSpam : imagePaths.icSpam,
                width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
            controller.currentMailbox?.isSpam == true
                ? AppLocalizations.of(context).remove_from_spam
                : AppLocalizations.of(context).mark_as_spam,
            email,
            iconLeftPadding: responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(left: 12, right: 16)
                : const EdgeInsets.only(right: 12),
            iconRightPadding: responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(right: 12)
                : EdgeInsets.zero)
        ..onActionClick((email) => controller.handleEmailAction(context, email,
            controller.currentMailbox?.isSpam == true ? EmailActionType.unSpam : EmailActionType.moveToSpam)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuEmailActionTile(BuildContext context, PresentationEmail email) {
    return [
      PopupMenuItem(padding: const EdgeInsets.symmetric(horizontal: 8), child: _markAsEmailUnreadAction(context, email)),
      PopupMenuItem(padding: const EdgeInsets.symmetric(horizontal: 8), child: _markAsEmailSpamOrUnSpamAction(context, email)),
    ];
  }
}