import 'dart:io';

import 'package:core/core.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_windows.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_file_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailView extends GetWidget<SingleEmailController>
    with PopupMenuWidgetMixin {

  static const double maxSizeFullDisplayEmailAddressArrowDownButton = 30.0;

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

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
                      : const BoxDecoration(color: Colors.white),
                  margin: _getMarginEmailView(context),
                  child: Obx(() {
                    if (controller.currentEmail != null) {
                      return _buildEmailView(context, controller.currentEmail!);
                    } else {
                      return _buildEmailViewEmpty(context);
                    }
                  })
              )
          ))
        ])
      )
    );
  }

  EdgeInsets _getMarginEmailView(BuildContext context) {
    if (BuildUtils.isWeb) {
      if (responsiveUtils.isDesktop(context)) {
        return const EdgeInsets.only(right: 16, top: 16, bottom: 16);
      } else {
        return const EdgeInsets.symmetric(vertical: 16);
      }
    } else {
      return EdgeInsets.zero;
    }
  }

  Widget _buildEmailViewEmpty(BuildContext context) {
    return Center(child: _buildEmailEmpty(context));
  }

  Widget _buildEmailView(BuildContext context, PresentationEmail email) {
    return Column(children: [
      _buildAppBar(context, email),
      _buildVacationNotificationMessage(context),
      const Divider(color: AppColor.colorDividerHorizontal, height: 1),
      Expanded(child: Obx(() {
        return controller.emailSupervisorController.supportedPageView.isTrue
          ? _buildMultipleEmailView(controller.emailSupervisorController.listEmail)
          : _buildSingleEmailView(context, email);
      }),
      ),
      const Divider(color: AppColor.colorDividerHorizontal, height: 1),
      _buildBottomBar(context, email),
    ]);
  }

  Widget _buildMultipleEmailView(List<PresentationEmail> listEmails) {
    log('EmailView::_buildMultipleEmailView(): ');
    return PageView.builder(
      physics: BuildUtils.isWeb ? const NeverScrollableScrollPhysics() : null,
      itemCount: listEmails.length,
      controller: controller.emailSupervisorController.pageController,
      onPageChanged: controller.emailSupervisorController.onPageChanged,
      itemBuilder: (context, index) => _buildSingleEmailView(context, listEmails[index])
    );
  }

  Widget _buildSingleEmailView(BuildContext context, PresentationEmail email) {
    log('EmailView::_buildSingleEmailView(): ');
    return _buildEmailBody(context, email);
  }

  bool _supportVerticalDivider(BuildContext context) {
    if (BuildUtils.isWeb) {
      return responsiveUtils.isTabletLarge(context);
    } else {
      return responsiveUtils.isLandscapeTablet(context) || responsiveUtils.isDesktop(context);
    }
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

  Widget _buildAppBar(BuildContext context, PresentationEmail presentationEmail) {
    return Obx(() => AppBarMailWidgetBuilder(
      presentationEmail,
      mailboxContain: _getMailboxContain(presentationEmail),
      isSearchIsRunning: controller.mailboxDashBoardController.searchController.isSearchEmailRunning,
      onBackActionClick: () => controller.closeEmailView(context),
      onEmailActionClick: (email, action) =>
          controller.handleEmailAction(context, email, action),
      onMoreActionClick: (email, position) {
        if (position == null) {
          controller.openContextMenuAction(
              context,
              _emailActionMoreActionTile(context, email));
        } else {
          controller.openPopupMenuAction(
              context,
              position,
              _popupMenuEmailActionTile(context, email));
        }
      },
      optionsWidget: BuildUtils.isWeb && controller.emailSupervisorController.supportedPageView.isTrue
        ? _buildNavigatorPageViewWidgets(context)
        : null,
    ));
  }

  PresentationMailbox? _getMailboxContain(PresentationEmail currentEmail) {
    return currentEmail.findMailboxContain(controller.mailboxDashBoardController.mapMailboxById);
  }
  
  List<Widget> _buildNavigatorPageViewWidgets(BuildContext context) {
    return [
      buildIconWeb(
        icon: SvgPicture.asset(
          imagePaths.icNewer,
          color: controller.emailSupervisorController.canGetNewerEmail.value ? AppColor.primaryColor : AppColor.colorAttachmentIcon,
          width: IconUtils.defaultIconSize,
          height: IconUtils.defaultIconSize,
          fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).newer,
        onTap: controller.emailSupervisorController.canGetNewerEmail.value ? controller.emailSupervisorController.getNewerEmail : null),
      buildIconWeb(
        icon: SvgPicture.asset(
          imagePaths.icOlder,
          width: IconUtils.defaultIconSize,
          height: IconUtils.defaultIconSize,
          color: controller.emailSupervisorController.canGetOlderEmail.value ? AppColor.primaryColor : AppColor.colorAttachmentIcon,
          fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).older,
        onTap: controller.emailSupervisorController.canGetOlderEmail.value ? controller.emailSupervisorController.getOlderEmail : null),
    ];
  }

  Widget _buildBottomBar(BuildContext context, PresentationEmail presentationEmail) {
    return BottomBarMailWidgetBuilder(
      presentationEmail,
      onPressEmailActionClick: (emailActionType) => controller.pressEmailAction(emailActionType));
  }

  Widget _buildEmailBody(BuildContext context, PresentationEmail email) {
    if (BuildUtils.isWeb) {
      return _buildEmailMessage(context, email);
    } else {
      return SingleChildScrollView(
          physics : const ClampingScrollPhysics(),
          child: Container(
              margin: EdgeInsets.zero,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.zero,
              color: Colors.white,
              child: _buildEmailMessage(context, email)
          )
      );
    }
  }

  Widget _buildEmailEmpty(BuildContext context) {
    return Text(
      AppLocalizations.of(context).no_mail_selected,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 25, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold));
  }

  Widget _buildEmailSubject(BuildContext context, PresentationEmail email) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SelectableText(
          email.getEmailTitle(),
          maxLines: BuildUtils.isWeb ? 2 : null,
          minLines: BuildUtils.isWeb ? 1 : null,
          cursorColor: AppColor.colorTextButton,
          style: const TextStyle(
              fontSize: 20,
              color: AppColor.colorNameEmail,
              fontWeight: FontWeight.w500)
      ));
  }

  Widget _buildEmailMessage(BuildContext context, PresentationEmail email) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmailSubject(context, email),
            _buildEmailInformationSenderAndReceiver(context, email),
            _buildLoadingView(),
            _buildAttachments(context),
            if (BuildUtils.isWeb)
              Expanded(child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 16),
                  child: _buildEmailContent(context, constraints, email)))
            else
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildEmailContent(context, constraints, email))
          ],
        );
      });
  }

  Widget _buildEmailInformationSenderAndReceiver(
      BuildContext context,
      PresentationEmail presentationEmail
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
          crossAxisAlignment: presentationEmail.numberOfAllEmailAddress() > 0
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            (AvatarBuilder()
                ..text(presentationEmail.getAvatarText())
                ..size(48)
                ..addTextStyle(const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                    color: Colors.white))
                ..backgroundColor(AppColor.colorAvatar)
                ..avatarColor(presentationEmail.avatarColors))
              .build(),
            const SizedBox(width: 16),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (presentationEmail.from?.isNotEmpty == true)
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Transform(
                            transform: Matrix4.translationValues(-5.0, 0.0, 0.0),
                            child: _buildEmailAddressOfSender(
                                context,
                                presentationEmail.from!.first,
                                constraints.maxWidth),
                          ),
                        )),
                      _buildEmailReceivedTime(context),
                    ]),
                    if (presentationEmail.numberOfAllEmailAddress() > 0)
                      Obx(() => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildEmailAddressOfReceiver(
                                context,
                                presentationEmail,
                                controller.isDisplayFullEmailAddress,
                                constraints)),
                            if (controller.isDisplayFullEmailAddress)
                              Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _buildGoneDisplayFullButton(context))
                          ]
                      )),
                  ]
                );
              }),
            )
          ]
      ),
    );
  }

  Widget _buildLoadingView() {
    return Obx(() {
      return controller.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) {
          if (success is LoadingState) {
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
    });
  }

  Widget _buildEmailReceivedTime(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      color: Colors.transparent,
      child: Text(
          '${controller.currentEmail?.getReceivedAt(
              Localizations.localeOf(context).toLanguageTag(),
              pattern: controller.currentEmail?.receivedAt?.value.toLocal().toPatternForEmailView())}',
          maxLines: 1,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColor.colorEmailAddressFull)),
    );
  }

  Widget _buildEmailAddressOfSender(
      BuildContext context,
      EmailAddress sender,
      double maxWidth
  ) {
    return Row(
        children: [
          if (sender.displayName.isNotEmpty)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.openEmailAddressDialog(context, sender),
                customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth - 100),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                      sender.displayName,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ),
            ),
          Expanded(
            child: Text(
                '<${sender.emailAddress}>',
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColor.colorEmailAddressFull)),
          ),
        ]
    );
  }

  double _getMaxWidthEmailAddressDisplayed(BuildContext context, double maxWidth) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return maxWidth - maxSizeFullDisplayEmailAddressArrowDownButton;
    } else if (responsiveUtils.isWebDesktop(context)) {
      return maxWidth / 2;
    } else {
      return maxWidth * 3/4;
    }
  }

  Widget _buildEmailAddressOfReceiver(
      BuildContext context,
      PresentationEmail presentationEmail,
      bool isDisplayFull,
      BoxConstraints constraints
  ) {
    if (!isDisplayFull && presentationEmail.numberOfAllEmailAddress() > 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            color: Colors.white,
            constraints: BoxConstraints(
                maxWidth: _getMaxWidthEmailAddressDisplayed(
                    context,
                    constraints.maxWidth)),
            child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  if (presentationEmail.to.numberEmailAddress() > 0)
                    _buildEmailAddressByPrefix(
                        context,
                        presentationEmail,
                        PrefixEmailAddress.to,
                        isDisplayFull),
                  if (presentationEmail.cc.numberEmailAddress() > 0)
                    _buildEmailAddressByPrefix(
                        context,
                        presentationEmail,
                        PrefixEmailAddress.cc,
                        isDisplayFull),
                  if (presentationEmail.bcc.numberEmailAddress() > 0)
                    _buildEmailAddressByPrefix(
                        context,
                        presentationEmail,
                        PrefixEmailAddress.bcc,
                        isDisplayFull),
                ]
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.expandEmailAddress,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(5),
                color: Colors.transparent,
                constraints: const BoxConstraints(
                    maxHeight: maxSizeFullDisplayEmailAddressArrowDownButton,
                    maxWidth: maxSizeFullDisplayEmailAddressArrowDownButton),
                child: SvgPicture.asset(
                    imagePaths.icChevronDown,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
              ),
            ),
          ),
        ]
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (presentationEmail.to.numberEmailAddress() > 0)
            _buildEmailAddressByPrefix(
                context,
                presentationEmail,
                PrefixEmailAddress.to,
                isDisplayFull),
          if (presentationEmail.cc.numberEmailAddress() > 0)
            _buildEmailAddressByPrefix(
                context,
                presentationEmail,
                PrefixEmailAddress.cc,
                isDisplayFull),
          if (presentationEmail.bcc.numberEmailAddress() > 0)
            _buildEmailAddressByPrefix(
                context,
                presentationEmail,
                PrefixEmailAddress.bcc,
                isDisplayFull),
        ],
      );
    }
  }

  Widget _buildEmailAddressByPrefix(
      BuildContext context,
      PresentationEmail presentationEmail,
      PrefixEmailAddress prefixEmailAddress,
      bool isDisplayFull
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                  '${prefixEmailAddress.asName(context)}:',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColor.colorEmailAddressFull)),
            ),
            if (!isDisplayFull && presentationEmail.numberOfAllEmailAddress() > 2)
              _buildListEmailAddressWidget(
                  context,
                  prefixEmailAddress.listEmailAddress(presentationEmail),
                  isDisplayFull
              )
            else
              Expanded(child: _buildListEmailAddressWidget(
                  context,
                  prefixEmailAddress.listEmailAddress(presentationEmail),
                  isDisplayFull
              ))
          ]
      ),
    );
  }

  Widget _buildListEmailAddressWidget(
      BuildContext context,
      List<EmailAddress> listEmailAddress,
      bool isDisplayFull
  ) {
    final lastEmailAddress = listEmailAddress.last;
    final emailAddressWidgets = listEmailAddress.map((emailAddress) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.openEmailAddressDialog(context, emailAddress),
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text(
                lastEmailAddress == emailAddress
                  ? emailAddress.asString()
                  : '${emailAddress.asString()},',
                maxLines: 1,
                softWrap: CommonTextStyle.defaultSoftWrap,
                overflow: CommonTextStyle.defaultTextOverFlow,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal)),
          ),
        ),
      );
    }).toList();

    if (isDisplayFull) {
      return Wrap(children: emailAddressWidgets);
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
            crossAxisAlignment:CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: emailAddressWidgets),
      );
    }
  }

  Widget _buildGoneDisplayFullButton(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.collapseEmailAddress,
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text(
              AppLocalizations.of(context).hide,
              style: const TextStyle(
                  fontSize: 15,
                  color: AppColor.colorTextButton,
                  fontWeight: FontWeight.normal),
            ),
          ),
        )
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

  Widget _buildAttachmentsBody(BuildContext context, List<Attachment> attachments) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttachmentsHeader(context, attachments),
          _buildAttachmentsList(context, attachments, controller.isDisplayFullAttachments)
        ],
      ),
    );
  }

  Widget _buildAttachmentsHeader(BuildContext context, List<Attachment> attachments) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SvgPicture.asset(imagePaths.icAttachment,
                    width: 20,
                    height: 20,
                    color: AppColor.colorAttachmentIcon,
                    fit: BoxFit.fill),
                const SizedBox(width: 5),
                Expanded(child: Text(
                    AppLocalizations.of(context).titleHeaderAttachment(
                        attachments.length,
                        filesize(attachments.totalSize(), 1)),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: AppColor.colorTitleHeaderAttachment)))
              ])
          )),
          if (attachments.length > 2)
            Obx(() => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.toggleDisplayAttachmentsAction,
                customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                      controller.isDisplayFullAttachments
                          ? AppLocalizations.of(context).hide
                          : AppLocalizations.of(context).showAll,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColor.colorTextButton,
                          fontWeight: FontWeight.normal)),
                ),
              ),
            ))
        ],
      ),
    );
  }

  Widget _buildAttachmentsList(
      BuildContext context,
      List<Attachment> attachments,
      bool isDisplayAll
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      if (isDisplayAll) {
        return Wrap(
          runSpacing: 12,
          children: attachments
            .map((attachment) => AttachmentFileTileBuilder(
              attachment,
              onDownloadAttachmentFileActionClick: (attachment) {
                if (BuildUtils.isWeb) {
                  controller.downloadAttachmentForWeb(context, attachment);
                } else {
                  controller.exportAttachment(context, attachment);
                }
              }))
            .toList());
      } else {
        return Container(
            height: 60,
            color: Colors.transparent,
            child: ListView.builder(
                key: const Key('list_attachment_minimize_in_email'),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                itemBuilder: (context, index) => AttachmentFileTileBuilder(
                    attachments[index],
                    onDownloadAttachmentFileActionClick: (attachment) {
                      if (BuildUtils.isWeb) {
                        controller.downloadAttachmentForWeb(context, attachment);
                      } else {
                        controller.exportAttachment(context, attachment);
                      }
                    })
            )
        );
      }
    });
  }

  Widget _buildEmailContent(BuildContext context, BoxConstraints constraints, PresentationEmail email) {
    if(email.id != controller.mailboxDashBoardController.selectedEmail.value?.id) {
      return const SizedBox.shrink();
    }
    return Obx(() {
      if (controller.emailContents.isNotEmpty) {
        final allEmailContents = controller.emailContents.asHtmlString;

        if (BuildUtils.isWeb) {
          return HtmlContentViewerOnWeb(
              widthContent: constraints.maxWidth,
              heightContent: responsiveUtils.getSizeScreenHeight(context),
              contentHtml: allEmailContents,
              controller: HtmlViewerControllerForWeb(),
              mailtoDelegate: (uri) => controller.openMailToLink(uri));
        } else if(Platform.isWindows) {
          return HtmlContentViewerForWindows(
            contentHtml: allEmailContents, 
            heightContent: responsiveUtils.getSizeScreenHeight(context), 
            mailtoDelegate: (uri) async => controller.openMailToLink(uri));
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
      _quickCreatingRuleAction(context, email),
    ];
  }

  Widget _markAsEmailUnreadAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
          const Key('mark_as_unread_action'),
          SvgPicture.asset(
            imagePaths.icUnreadEmail,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
            color: AppColor.colorTextButton
          ),
          AppLocalizations.of(context).mark_as_unread,
          email,
          iconLeftPadding: responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(left: 12, right: 16)
            : const EdgeInsets.only(right: 12),
          iconRightPadding: responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(right: 12)
            : EdgeInsets.zero)
      ..onActionClick((email) => controller.handleEmailAction(
        context,
        email,
        EmailActionType.markAsUnread)
      )
    ).build();
  }

  Widget _markAsEmailSpamOrUnSpamAction(BuildContext context, PresentationEmail email) {
    final currentMailbox = controller.getMailboxContain(email);

    return (EmailActionCupertinoActionSheetActionBuilder(
          const Key('mark_as_spam_or_un_spam_action'),
          SvgPicture.asset(
            currentMailbox?.isSpam == true ? imagePaths.icNotSpam : imagePaths.icSpam,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
            color: AppColor.colorTextButton
          ),
          currentMailbox?.isSpam == true
            ? AppLocalizations.of(context).remove_from_spam
            : AppLocalizations.of(context).mark_as_spam,
          email,
          iconLeftPadding: responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(left: 12, right: 16)
            : const EdgeInsets.only(right: 12),
          iconRightPadding: responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(right: 12)
            : EdgeInsets.zero)
      ..onActionClick((email) => controller.handleEmailAction(
        context,
        email,
        currentMailbox?.isSpam == true ? EmailActionType.unSpam : EmailActionType.moveToSpam)
      )
    ).build();
  }

  Widget _quickCreatingRuleAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
          const Key('quick_creating_rule_action'),
          SvgPicture.asset(
            imagePaths.icQuickCreatingRule,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
            color: AppColor.colorTextButton),
          AppLocalizations.of(context).quickCreatingRule,
          email,
          iconLeftPadding: responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(left: 12, right: 16)
            : const EdgeInsets.only(right: 12),
          iconRightPadding: responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(right: 12)
            : EdgeInsets.zero)
        ..onActionClick((email) => controller.quickCreatingRule(context, email.from!.first)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuEmailActionTile(BuildContext context, PresentationEmail email) {
    final mailboxContain = controller.getMailboxContain(email);
    return [
      _markAsEmailUnreadPopupItemAction(context, email),
      _markAsEmailSpamOrUnSpamPopupItemAction(context, email, mailboxContain),
      _quickCreatingRulePopupItemAction(context, email)
    ];
  }

  PopupMenuEntry _markAsEmailUnreadPopupItemAction(BuildContext context, PresentationEmail email) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: popupItem(
        imagePaths.icUnreadEmail,
        AppLocalizations.of(context).mark_as_unread,
        colorIcon: AppColor.colorTextButton,
        styleName: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black
        ),
        onCallbackAction: () => controller.handleEmailAction(
          context,
          email,
          EmailActionType.markAsUnread
        )
      )
    );
  }

  PopupMenuEntry _markAsEmailSpamOrUnSpamPopupItemAction(
    BuildContext context,
    PresentationEmail email,
    PresentationMailbox? mailboxContain
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: popupItem(
        mailboxContain?.isSpam == true ? imagePaths.icNotSpam : imagePaths.icSpam,
        mailboxContain?.isSpam == true
          ? AppLocalizations.of(context).remove_from_spam
          : AppLocalizations.of(context).mark_as_spam,
        colorIcon: AppColor.colorTextButton,
        styleName: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black
        ),
        onCallbackAction: () => controller.handleEmailAction(
          context,
          email,
          mailboxContain?.isSpam == true ? EmailActionType.unSpam : EmailActionType.moveToSpam
        )
      )
    );
  }

  PopupMenuEntry _quickCreatingRulePopupItemAction(BuildContext context, PresentationEmail email) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: popupItem(
        imagePaths.icQuickCreatingRule,
        AppLocalizations.of(context).quickCreatingRule,
        colorIcon: AppColor.colorTextButton,
        styleName: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black
        ),
        onCallbackAction: () => controller.quickCreatingRule(context, email.from!.first)
      )
    );
  }
}