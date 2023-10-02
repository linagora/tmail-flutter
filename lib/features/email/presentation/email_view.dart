import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/icon_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_controller_for_web.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_banner_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_information_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_attachments_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_subject_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_empty_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/information_sender_and_receiver_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

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
                width: 12),
          Expanded(child: SafeArea(
              right: responsiveUtils.isLandscapeMobile(context),
              left: responsiveUtils.isLandscapeMobile(context),
              child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: responsiveUtils.isWebDesktop(context)
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
                          color: Colors.white)
                      : const BoxDecoration(color: Colors.white),
                  margin: _getMarginEmailView(context),
                  child: Obx(() {
                    if (controller.currentEmail != null) {
                      return Column(children: [
                        _buildAppBar(context, controller.currentEmail!),
                        _buildVacationNotificationMessage(context),
                        const Divider(color: AppColor.colorDividerHorizontal, height: 1),
                        Expanded(
                          child: Obx(() {
                            return controller.emailSupervisorController.supportedPageView.isTrue
                              ? _buildMultipleEmailView(controller.emailSupervisorController.currentListEmail)
                              : _buildSingleEmailView(context, controller.currentEmail!);
                          }),
                        ),
                        BottomBarMailWidgetBuilder(
                          controller.currentEmail!,
                          onPressEmailActionClick: controller.pressEmailAction
                        ),
                      ]);
                    } else {
                      return const EmailViewEmptyWidget();
                    }
                  })
              )
          ))
        ])
      )
    );
  }

  EdgeInsets _getMarginEmailView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isDesktop(context)) {
        return EdgeInsets.only(
          left: AppUtils.isDirectionRTL(context) ? 16 : 0,
          right: AppUtils.isDirectionRTL(context) ? 0 : 16,
          top: 16,
          bottom: 16
        );
      } else {
        return const EdgeInsets.symmetric(vertical: 16);
      }
    } else {
      return EdgeInsets.zero;
    }
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

  bool _supportVerticalDivider(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return responsiveUtils.isTabletLarge(context);
    } else {
      return responsiveUtils.isLandscapeTablet(context) ||
        responsiveUtils.isDesktop(context) ||
        responsiveUtils.isTabletLarge(context);
    }
  }

  Widget _buildVacationNotificationMessage(BuildContext context) {
    return Obx(() {
      final vacation = controller.mailboxDashBoardController.vacationResponse.value;
      if (vacation?.vacationResponderIsValid == true &&
          (responsiveUtils.isMobile(context) ||
              responsiveUtils.isTablet(context) ||
              responsiveUtils.isLandscapeMobile(context))) {
        return VacationNotificationMessageWidget(
          margin: const EdgeInsets.only(left: 12, right: 12, bottom: 5),
          vacationResponse: vacation!,
          actionGotoVacationSetting: controller.mailboxDashBoardController.goToVacationSetting,
          actionEndNow: controller.mailboxDashBoardController.disableVacationResponder);
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
      optionsWidget: PlatformInfo.isWeb && controller.emailSupervisorController.supportedPageView.isTrue
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
          DirectionUtils.isDirectionRTLByLanguage(context) ? imagePaths.icOlder : imagePaths.icNewer,
          colorFilter: controller.emailSupervisorController.nextEmailActivated
            ? AppColor.primaryColor.asFilter()
            : AppColor.colorAttachmentIcon.asFilter(),
          width: IconUtils.defaultIconSize,
          height: IconUtils.defaultIconSize,
          fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).newer,
        onTap: controller.emailSupervisorController.moveToNextEmail),
      buildIconWeb(
        icon: SvgPicture.asset(
          DirectionUtils.isDirectionRTLByLanguage(context) ? imagePaths.icNewer : imagePaths.icOlder,
          width: IconUtils.defaultIconSize,
          height: IconUtils.defaultIconSize,
          colorFilter: controller.emailSupervisorController.previousEmailActivated
            ? AppColor.primaryColor.asFilter()
            : AppColor.colorAttachmentIcon.asFilter(),
          fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).older,
        onTap: controller.emailSupervisorController.backToPreviousEmail),
    ];
  }

  Widget _buildSingleEmailView(BuildContext context, PresentationEmail presentationEmail) {
    if (PlatformInfo.isMobile) {
      return SingleChildScrollView(
        physics : const ClampingScrollPhysics(),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          color: Colors.white,
          child: Obx(() => _buildEmailMessage(
            context: context,
            presentationEmail: presentationEmail,
            calendarEvent: controller.calendarEvent.value
          ))
        )
      );
    } else {
      return Obx(() {
        final calendarEvent = controller.calendarEvent.value;
        if (presentationEmail.hasCalendarEvent && calendarEvent != null) {
          return SingleChildScrollView(
            physics : const ClampingScrollPhysics(),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              color: Colors.white,
              child: _buildEmailMessage(
                context: context,
                presentationEmail: presentationEmail,
                calendarEvent: calendarEvent,
                emailAddressSender: presentationEmail.listEmailAddressSender.getListAddress(),
              )
            )
          );
        } else {
          return _buildEmailMessage(context: context, presentationEmail: presentationEmail);
        }
      });
    }
  }

  Widget _buildEmailMessage({
    required BuildContext context,
    required PresentationEmail presentationEmail,
    CalendarEvent? calendarEvent,
    List<String>? emailAddressSender,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmailSubjectWidget(presentationEmail: presentationEmail),
            InformationSenderAndReceiverBuilder(
              controller: controller,
              emailSelected: presentationEmail,
              imagePaths: imagePaths,
              responsiveUtils: responsiveUtils,
            ),
            Obx(() {
              final attachments = controller.attachments.listAttachmentsDisplayedOutSide;
              if (attachments.isNotEmpty) {
                return EmailAttachmentsWidget(
                  attachments: attachments,
                  onDragStarted: () {
                    log('EmailView::_buildEmailMessage:onDragStarted:');
                    controller.mailboxDashBoardController.enableDraggableApp();
                  },
                  onDragEnd: (details) {
                    log('EmailView::_buildEmailMessage:onDragEnd:');
                    controller.mailboxDashBoardController.disableDraggableApp();
                  },
                  downloadAttachmentAction: (attachment) {
                    if (PlatformInfo.isWeb) {
                      controller.downloadAttachmentForWeb(context, attachment);
                    } else {
                      controller.exportAttachment(context, attachment);
                    }
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            Obx(() => EmailViewLoadingBarWidget(
              viewState: controller.emailLoadedViewState.value
            )),
            if (calendarEvent != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CalendarEventInformationWidget(
                    calendarEvent: calendarEvent,
                    eventActions: controller.eventActions,
                    onOpenComposerAction: controller.openNewComposerAction,
                    onOpenNewTabAction: controller.openNewTabAction,
                  ),
                  if (calendarEvent.getTitleEventAction(context, emailAddressSender ?? []).isNotEmpty)
                    CalendarEventActionBannerWidget(
                      calendarEvent: calendarEvent,
                      listEmailAddressSender: emailAddressSender ?? []
                    ),
                  CalendarEventDetailWidget(
                    calendarEvent: calendarEvent,
                    eventActions: controller.eventActions,
                    onOpenComposerAction: controller.openNewComposerAction,
                    onOpenNewTabAction: controller.openNewTabAction,
                  ),
                ],
              )
            else
              _buildEmailContentOnHtmlViewer(context, constraints, presentationEmail)
          ],
        );
      });
  }

  Widget _buildEmailContentOnHtmlViewer(
    BuildContext context,
    BoxConstraints constraints,
    PresentationEmail email
  ) {
    if (email.id != controller.currentEmail?.id) {
      return const SizedBox.shrink();
    }
    return Obx(() {
      if (controller.emailContents.value != null) {
        final allEmailContents = controller.emailContents.value;

        if (PlatformInfo.isWeb) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
              child: Obx(() {
                return Stack(
                  children: [
                    HtmlContentViewerOnWeb(
                      widthContent: constraints.maxWidth,
                      heightContent: responsiveUtils.getSizeScreenHeight(context),
                      contentHtml: allEmailContents ?? "",
                      controller: HtmlViewerControllerForWeb(),
                      mailtoDelegate: (uri) => controller.openMailToLink(uri),
                      direction: AppUtils.getCurrentDirection(context),
                    ),
                    if (controller.mailboxDashBoardController.isDraggableAppActive)
                      PointerInterceptor(
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        )
                      )
                  ],
                );
              }),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: EmailViewStyles.mobileContentVerticalMargin,
              horizontal: EmailViewStyles.mobileContentHorizontalMargin
            ),
            child: HtmlContentViewer(
              heightContent: responsiveUtils.getSizeScreenHeight(context),
              contentHtml: allEmailContents ?? "",
              mailtoDelegate: (uri) async => controller.openMailToLink(uri),
              onScrollHorizontalEnd: controller.toggleScrollPhysicsPagerView,
              onWebViewLoaded: (isScrollPageViewActivated) {
                log('EmailView::_buildEmailContent(): isScrollPageViewActivated: $isScrollPageViewActivated');
                controller.emailSupervisorController.updateScrollPhysicPageView(isScrollPageViewActivated: isScrollPageViewActivated);
              },
              direction: AppUtils.getCurrentDirection(context),
            ),
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
            colorFilter: AppColor.colorTextButton.asFilter()
          ),
          AppLocalizations.of(context).mark_as_unread,
          email,
          iconLeftPadding: responsiveUtils.isMobile(context)
            ? EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 16 : 12,
                right: AppUtils.isDirectionRTL(context) ? 12 : 16,
              )
            : EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 12 : 0,
                right: AppUtils.isDirectionRTL(context) ? 0 : 12,
              ),
          iconRightPadding: responsiveUtils.isMobile(context)
            ? EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 12 : 0,
                right: AppUtils.isDirectionRTL(context) ? 0 : 12,
              )
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
            colorFilter: AppColor.colorTextButton.asFilter()
          ),
          currentMailbox?.isSpam == true
            ? AppLocalizations.of(context).remove_from_spam
            : AppLocalizations.of(context).mark_as_spam,
          email,
          iconLeftPadding: responsiveUtils.isMobile(context)
            ? EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 16 : 12,
                right: AppUtils.isDirectionRTL(context) ? 12 : 16,
              )
            : EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 12 : 0,
                right: AppUtils.isDirectionRTL(context) ? 0 : 12,
              ),
          iconRightPadding: responsiveUtils.isMobile(context)
            ? EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 12 : 0,
                right: AppUtils.isDirectionRTL(context) ? 0 : 12,
              )
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
            colorFilter: AppColor.colorTextButton.asFilter()),
          AppLocalizations.of(context).quickCreatingRule,
          email,
          iconLeftPadding: responsiveUtils.isMobile(context)
            ? EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 16 : 12,
                right: AppUtils.isDirectionRTL(context) ? 12 : 16,
              )
            : EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 12 : 0,
                right: AppUtils.isDirectionRTL(context) ? 0 : 12,
              ),
          iconRightPadding: responsiveUtils.isMobile(context)
            ? EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 12 : 0,
                right: AppUtils.isDirectionRTL(context) ? 0 : 12,
              )
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
        padding: const EdgeInsetsDirectional.only(start: 12),
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
        padding: const EdgeInsetsDirectional.only(start: 12),
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
        padding: const EdgeInsetsDirectional.only(start: 12),
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