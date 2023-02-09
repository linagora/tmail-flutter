import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/icon_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_controller_for_web.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:model/extensions/list_email_content_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_file_tile_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/information_sender_and_receiver_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailView extends GetWidget<SingleEmailController> {

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  EmailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => controller.backButtonPressedCallbackAction.call(context),
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
          ? _buildMultipleEmailView(controller.emailSupervisorController.currentListEmail)
          : _buildSingleEmailView(context, email);
      }),
      ),
      const Divider(color: AppColor.colorDividerHorizontal, height: 1),
      _buildBottomBar(context, email),
    ]);
  }

  Widget _buildMultipleEmailView(List<PresentationEmail> listEmails) {
    return Obx(
      () => PageView.builder(
        physics: controller.emailSupervisorController.scrollPhysicsPageView.value,
        itemCount: listEmails.length,
        allowImplicitScrolling: true,
        controller: controller.emailSupervisorController.pageController,
        onPageChanged: controller.emailSupervisorController.onPageChanged,
        itemBuilder: (context, index) => _buildSingleEmailView(context, listEmails[index])
      ),
    );
  }

  Widget _buildSingleEmailView(BuildContext context, PresentationEmail email) {
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
          color: controller.emailSupervisorController.nextEmailActivated
            ? AppColor.primaryColor
            : AppColor.colorAttachmentIcon,
          width: IconUtils.defaultIconSize,
          height: IconUtils.defaultIconSize,
          fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).newer,
        onTap: controller.emailSupervisorController.moveToNextEmail),
      buildIconWeb(
        icon: SvgPicture.asset(
          imagePaths.icOlder,
          width: IconUtils.defaultIconSize,
          height: IconUtils.defaultIconSize,
          color: controller.emailSupervisorController.previousEmailActivated
            ? AppColor.primaryColor
            : AppColor.colorAttachmentIcon,
          fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).older,
        onTap: controller.emailSupervisorController.backToPreviousEmail),
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
          primary: true,
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
            InformationSenderAndReceiverBuilder(
              controller: controller,
              emailSelected: email,
              imagePaths: imagePaths,
              responsiveUtils: responsiveUtils,
            ),
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
    if(email.id != controller.currentEmail?.id) {
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
        } else {
          return HtmlContentViewer(
            heightContent: responsiveUtils.getSizeScreenHeight(context),
            contentHtml: allEmailContents,
            mailtoDelegate: (uri) async => controller.openMailToLink(uri),
            onScrollHorizontalEnd: controller.toggleScrollPhysicsPagerView,
            onWebViewLoaded: (isScrollPageViewActivated) {
              log('EmailView::_buildEmailContent(): isScrollPageViewActivated: $isScrollPageViewActivated');
              controller.emailSupervisorController.updateScrollPhysicPageView(isScrollPageViewActivated: isScrollPageViewActivated);
            },
          );
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
      child: PopupItemWidget(
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
      child: PopupItemWidget(
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
      child: PopupItemWidget(
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