import 'dart:math';

import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/widget/optional_expanded.dart';
import 'package:tmail_ui_user/features/base/widget/optional_scroll.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_banner_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_detail_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_information_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_attachments_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_subject_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_app_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_bottom_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_empty_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/information_sender_and_receiver_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/mail_unsubscribed_banner.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/view_entire_message_with_message_clipped_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/verify_display_overlay_view_on_iframe_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EmailView extends GetWidget<SingleEmailController> {

  const EmailView({
    super.key,
    this.isInsideThreadDetailView = false,
    this.emailId,
    this.isFirstEmailInThreadDetail = false,
    this.threadSubject,
    this.onToggleThreadDetailCollapseExpand,
    this.scrollController,
  });

  final bool isInsideThreadDetailView;
  final EmailId? emailId;
  final bool isFirstEmailInThreadDetail;
  final String? threadSubject;
  final VoidCallback? onToggleThreadDetailCollapseExpand;
  final ScrollController? scrollController;

  @override
  String? get tag => emailId?.id.value;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ColoredBox(
        color: controller.responsiveUtils.isWebDesktop(context)
          ? AppColor.colorBgDesktop
          : Colors.white,
        child: SafeArea(
          right: controller.responsiveUtils.isLandscapeMobile(context),
          left: controller.responsiveUtils.isLandscapeMobile(context),
          bottom: !PlatformInfo.isIOS,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: _getDecorationEmailView(context),
            margin: _getMarginEmailView(context),
            child: Obx(() {
              final currentEmailListener = Rxn(controller.currentEmail);
              final currentEmail = currentEmailListener.value;
              if (currentEmail != null) {
                return Column(children: [
                  if (!isInsideThreadDetailView)
                    Obx(() => EmailViewAppBarWidget(
                      key: const Key('email_view_app_bar_widget'),
                      presentationEmail: currentEmail,
                      mailboxContain: _getMailboxContain(currentEmail),
                      isSearchActivated: controller.mailboxDashBoardController.searchController.isSearchEmailRunning,
                      onBackAction: () => controller.closeEmailView(context: context),
                      onEmailActionClick: (email, action) => controller.handleEmailAction(context, email, action),
                      onMoreActionClick: (presentationEmail, position) => controller.emailActionReactor.handleMoreEmailAction(
                        mailboxContain: controller.getMailboxContain(presentationEmail),
                        presentationEmail: presentationEmail,
                        position: position,
                        responsiveUtils: controller.responsiveUtils,
                        imagePaths: controller.imagePaths,
                        username: controller.session?.username,
                        handleEmailAction: (email, action) => controller.handleEmailAction(context, email, action),
                        additionalActions: [],
                        emailIsRead: presentationEmail.hasRead,
                      ),
                      supportBackAction: !isInsideThreadDetailView,
                      appBarDecoration: isInsideThreadDetailView
                        ? const BoxDecoration(border: Border(bottom: BorderSide(
                            color: AppColor.colorDividerEmailView,
                          )))
                        : null,
                      emailLoaded: controller.currentEmailLoaded.value,
                      isInsideThreadDetailView: isInsideThreadDetailView,
                    )),
                  Obx(() {
                    final vacation = controller.mailboxDashBoardController.vacationResponse.value;
                    if (vacation?.vacationResponderIsValid == true &&
                        (
                          controller.responsiveUtils.isMobile(context) ||
                          controller.responsiveUtils.isTablet(context) ||
                          controller.responsiveUtils.isLandscapeMobile(context)
                        )
                    ) {
                      return VacationNotificationMessageWidget(
                        margin: const EdgeInsetsDirectional.only(start: 12, end: 12, top: 8),
                        vacationResponse: vacation!,
                        actionGotoVacationSetting: controller.mailboxDashBoardController.goToVacationSetting,
                        actionEndNow: controller.mailboxDashBoardController.disableVacationResponder
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  OptionalExpanded(
                    expandedEnabled: !isInsideThreadDetailView,
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (PlatformInfo.isMobile) {
                        return OptionalScroll(
                          scrollEnabled: !isInsideThreadDetailView,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            color: Colors.white,
                            child: Obx(() => _buildEmailMessage(
                              context: context,
                              presentationEmail: currentEmail,
                              calendarEvent: controller.calendarEvent,
                              maxBodyHeight: constraints.maxHeight
                            ))
                          )
                        );
                      } else {
                        return Obx(() {
                          final calendarEvent = controller.calendarEvent;
                          if (currentEmail.hasCalendarEvent && calendarEvent != null) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
                              child: OptionalScroll(
                                scrollEnabled: !isInsideThreadDetailView,
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  color: Colors.white,
                                  child: _buildEmailMessage(
                                    context: context,
                                    presentationEmail: currentEmail,
                                    calendarEvent: calendarEvent,
                                    emailAddressSender: currentEmail.listEmailAddressSender.getListAddress(),
                                    maxBodyHeight: constraints.maxHeight
                                  )
                                )
                              ),
                            );
                          } else {
                            return _buildEmailMessage(
                              context: context,
                              presentationEmail: currentEmail,
                              maxBodyHeight: constraints.maxHeight
                            );
                          }
                        });
                      }
                    }),
                  ),
                  Obx(() {
                    final emailLoaded = controller.currentEmailLoaded.value;

                    if (emailLoaded == null || isInsideThreadDetailView) {
                      return const SizedBox.shrink();
                    }

                    return EmailViewBottomBarWidget(
                      key: const Key('email_view_button_bar'),
                      imagePaths: controller.imagePaths,
                      responsiveUtils: controller.responsiveUtils,
                      emailLoaded: emailLoaded,
                      presentationEmail: currentEmail,
                      userName: controller.getOwnEmailAddress(),
                      emailActionCallback: controller.pressEmailAction,
                    );
                  }),
                ]);
              } else {
                return const EmailViewEmptyWidget();
              }
            })
          )
        )
      ),
    );
  }

  BoxDecoration _getDecorationEmailView(BuildContext context) {
    if (controller.responsiveUtils.isWebDesktop(context) && !isInsideThreadDetailView) {
      return const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      );
    }

    if (controller.currentEmail == null || !isInsideThreadDetailView) {
      return const BoxDecoration(color: Colors.white);
    }

    return const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(
        color: AppColor.colorDividerEmailView,
        width: 0.5,
      )),
    );
  }

  EdgeInsetsGeometry? _getMarginEmailView(BuildContext context) {
    if (PlatformInfo.isMobile) return null;

    if (isInsideThreadDetailView) {
      return EdgeInsets.zero;
    }

    if (!controller.responsiveUtils.isDesktop(context)) {
      return EdgeInsets.zero;
    }
    
    return const EdgeInsetsDirectional.only(
      end: 16,
      bottom: 16
    );
  }

  PresentationMailbox? _getMailboxContain(PresentationEmail currentEmail) {
    return currentEmail.findMailboxContain(controller.mailboxDashBoardController.mapMailboxById);
  }

  Widget _buildEmailMessage({
    required BuildContext context,
    required PresentationEmail presentationEmail,
    CalendarEvent? calendarEvent,
    List<String>? emailAddressSender,
    double? maxBodyHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isInsideThreadDetailView || isFirstEmailInThreadDetail)
          EmailSubjectWidget(
            presentationEmail: presentationEmail.copyWith(
              subject: threadSubject,
            ),
          )
        else
          const SizedBox(height: 16),
        Obx(() => InformationSenderAndReceiverBuilder(
          emailSelected: presentationEmail,
          imagePaths: controller.imagePaths,
          responsiveUtils: controller.responsiveUtils,
          sMimeStatus: controller.currentEmailLoaded.value?.sMimeStatus,
          emailUnsubscribe: controller.emailUnsubscribe.value,
          maxBodyHeight: maxBodyHeight,
          openEmailAddressDetailAction: (_, emailAddress) => controller.openEmailAddressDialog(emailAddress),
          onEmailActionClick: (presentationEmail, actionType) => controller.handleEmailAction(context, presentationEmail, actionType),
          isInsideThreadDetailView: isInsideThreadDetailView,
          emailLoaded: controller.currentEmailLoaded.value,
          onMoreActionClick: (presentationEmail, position) => controller.emailActionReactor.handleMoreEmailAction(
            mailboxContain: controller.getMailboxContain(presentationEmail),
            presentationEmail: presentationEmail,
            position: position,
            responsiveUtils: controller.responsiveUtils,
            imagePaths: controller.imagePaths,
            username: controller.session?.username,
            handleEmailAction: (email, action) => controller.handleEmailAction(context, email, action),
            additionalActions: [
              EmailActionType.forward,
              EmailActionType.replyAll,
              EmailActionType.replyToList,
              EmailActionType.printAll,
              if (controller.responsiveUtils.isMobile(context))
                EmailActionType.moveToMailbox,
              if (!controller.responsiveUtils.isDesktop(context)) ...[
                EmailActionType.markAsStarred,
                EmailActionType.unMarkAsStarred,
                EmailActionType.moveToTrash,
                EmailActionType.deletePermanently,
              ],
            ],
            emailIsRead: presentationEmail.hasRead,
          ),
          onToggleThreadDetailCollapseExpand: onToggleThreadDetailCollapseExpand,
          onTapAvatarActionClick: onToggleThreadDetailCollapseExpand,
          mailboxContain: presentationEmail.findMailboxContain(
            controller.mailboxDashBoardController.mapMailboxById,
          ),
        )),
        Obx(() => MailUnsubscribedBanner(
          presentationEmail: controller.currentEmail,
          emailUnsubscribe: controller.emailUnsubscribe.value
        )),
        Obx(() {
          if (controller.attachments.isNotEmpty) {
            return EmailAttachmentsWidget(
              responsiveUtils: controller.responsiveUtils,
              attachments: controller.attachments,
              imagePaths: controller.imagePaths,
              onDragStarted: controller.mailboxDashBoardController.enableAttachmentDraggableApp,
              onDragEnd: (details) {
                controller.mailboxDashBoardController.disableAttachmentDraggableApp();
              },
              downloadAttachmentAction: (attachment) => controller.handleDownloadAttachmentAction(context, attachment),
              viewAttachmentAction: (attachment) => controller.handleViewAttachmentAction(context, attachment),
              onTapShowAllAttachmentFile: () => controller.openAttachmentList(context, controller.attachments),
              showDownloadAllAttachmentsButton: controller.downloadAllButtonIsEnabled(),
              onTapDownloadAllButton: () => controller.handleDownloadAllAttachmentsAction(context, 'TwakeMail-${DateTime.now()}'),
              singleEmailControllerTag: tag,
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
              Obx(() => CalendarEventInformationWidget(
                calendarEvent: calendarEvent,
                onOpenComposerAction: controller.openNewComposerAction,
                onOpenNewTabAction: controller.openNewTabAction,
                onCalendarEventReplyActionClick: (eventActionType) =>
                  controller.onCalendarEventReplyAction(eventActionType, presentationEmail.id!),
                calendarEventReplying: controller.calendarEventProcessing,
                attendanceStatus: controller.attendanceStatus.value,
                onMailtoAttendeesAction: controller.handleMailToAttendees,
                openEmailAddressDetailAction: (_, emailAddress) => controller.openEmailAddressDialog(emailAddress),
                isFree: controller.isCalendarEventFree,
                listEmailAddressSender: emailAddressSender ?? [],
              )),
              if (_validateDisplayEventActionBanner(
                  context: context,
                  event: calendarEvent,
                  emailAddressSender: emailAddressSender ?? []))
                CalendarEventActionBannerWidget(
                  calendarEvent: calendarEvent,
                  listEmailAddressSender: emailAddressSender ?? []
                ),
              Obx(() => CalendarEventDetailWidget(
                calendarEvent: calendarEvent,
                emailContent: controller.currentEmailLoaded.value?.htmlContent ?? '',
                isDraggableAppActive: controller.mailboxDashBoardController.isAttachmentDraggableAppActive,
                onMailtoDelegateAction: controller.openMailToLink,
                presentationEmail: controller.currentEmail,
                scrollController: scrollController,
                isInsideThreadDetailView: isInsideThreadDetailView,
              )),
            ],
          )
        else if (presentationEmail.id == controller.currentEmail?.id)
          Obx(() {
            if (controller.emailContents.value != null) {
              final allEmailContents = controller.emailContents.value ?? '';

              if (PlatformInfo.isWeb) {
                return OptionalExpanded(
                  expandedEnabled: !isInsideThreadDetailView,
                  child: Padding(
                    padding: EmailViewStyles.emailContentPadding,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Obx(() {
                        return Stack(
                          children: [
                            HtmlContentViewerOnWeb(
                              key: ValueKey(tag),
                              widthContent: constraints.maxWidth,
                              heightContent: min(
                                constraints.maxHeight,
                                EmailViewStyles.initialHtmlViewHeight,
                              ),
                              contentHtml: allEmailContents,
                              mailtoDelegate: controller.openMailToLink,
                              direction: AppUtils.getCurrentDirection(context),
                              contentPadding: 0,
                              useDefaultFont: true,
                              scrollController: scrollController,
                              enableQuoteToggle: isInsideThreadDetailView,
                            ),
                            if (controller.mailboxDashBoardController.isDisplayedOverlayViewOnIFrame)
                              PointerInterceptor(
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                )
                              ),
                          ],
                        );
                      });
                    }),
                  ),
                );
              } else if (PlatformInfo.isIOS) {
                return Obx(() {
                  if (controller.isEmailContentHidden.isTrue && !controller.responsiveUtils.isScreenWithShortestSide(context)) {
                    return const SizedBox.shrink();
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: EmailViewStyles.mobileContentVerticalMargin,
                            horizontal: EmailViewStyles.mobileContentHorizontalMargin,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return HtmlContentViewer(
                              key: controller.htmlContentViewKey,
                              contentHtml: allEmailContents,
                              initialWidth: constraints.maxWidth,
                              direction: AppUtils.getCurrentDirection(context),
                              contentPadding: 0,
                              useDefaultFont: true,
                              maxHtmlContentHeight: ConstantsUI.htmlContentMaxHeight,
                              onMailtoDelegateAction: controller.openMailToLink,
                              onHtmlContentClippedAction: controller.onHtmlContentClippedAction,
                              keepAlive: isInsideThreadDetailView,
                              enableQuoteToggle: isInsideThreadDetailView,
                            );
                          }),
                        ),
                        Obx(() {
                          if (controller.isEmailContentClipped.isTrue) {
                            return ViewEntireMessageWithMessageClippedWidget(
                              buttonActionName: AppLocalizations.of(context).viewEntireMessage.toUpperCase(),
                              onViewEntireMessageAction: () => controller.onViewEntireMessage(
                                context: context,
                                emailContent: allEmailContents,
                                presentationEmail: presentationEmail,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                      ],
                    );
                  }
                });
              } else {
                return Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    vertical: EmailViewStyles.mobileContentVerticalMargin,
                    horizontal: EmailViewStyles.mobileContentHorizontalMargin
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return HtmlContentViewer(
                      key: controller.htmlContentViewKey,
                      contentHtml: allEmailContents,
                      initialWidth: constraints.maxWidth,
                      direction: AppUtils.getCurrentDirection(context),
                      contentPadding: 0,
                      useDefaultFont: true,
                      onMailtoDelegateAction: controller.openMailToLink,
                      keepAlive: isInsideThreadDetailView,
                      enableQuoteToggle: isInsideThreadDetailView,
                    );
                  })
                );
              }
            } else {
              return const SizedBox.shrink();
            }
          })
      ],
    );
  }

  bool _validateDisplayEventActionBanner({
    required BuildContext context,
    required CalendarEvent event,
    required List<String> emailAddressSender
  }) {
    final usernameEvent = event.getUserNameEventAction(
      context: context,
      imagePaths: controller.imagePaths,
      listEmailAddressSender: emailAddressSender);
    final titleEvent = event.getTitleEventAction(context, emailAddressSender);

    return usernameEvent.isNotEmpty && titleEvent.isNotEmpty;
  }
}