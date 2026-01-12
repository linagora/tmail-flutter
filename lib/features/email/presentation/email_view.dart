import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/tooltip/iframe_tooltip_overlay.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/base/widget/dialog_picker/color_dialog_picker.dart';
import 'package:tmail_ui_user/features/base/widget/optional_expanded.dart';
import 'package:tmail_ui_user/features/base/widget/optional_scroll.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/handle_label_for_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/handle_on_iframe_click_in_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/validate_display_free_busy_message_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_open_context_menu_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/verify_display_overlay_view_on_iframe_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EmailView extends GetWidget<SingleEmailController> {

  const EmailView({
    super.key,
    this.isInsideThreadDetailView = false,
    this.emailId,
    this.isFirstEmailInThreadDetail = false,
    this.threadSubject,
    this.onToggleThreadDetailCollapseExpand,
    this.onIFrameKeyboardShortcutAction,
    this.scrollController,
  });

  final bool isInsideThreadDetailView;
  final EmailId? emailId;
  final bool isFirstEmailInThreadDetail;
  final String? threadSubject;
  final VoidCallback? onToggleThreadDetailCollapseExpand;
  final OnIFrameKeyboardShortcutAction? onIFrameKeyboardShortcutAction;
  final ScrollController? scrollController;

  @override
  String? get tag => emailId?.id.value;

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Container(
      decoration: _getDecorationEmailView(context),
      margin: _getMarginEmailView(context),
      child: Obx(() {
        final currentEmailListener = Rxn(controller.currentEmail);
        final currentEmail = currentEmailListener.value;
        if (currentEmail != null) {
          return Column(
            children: [
              if (!isInsideThreadDetailView)
                Obx(
                  () => EmailViewAppBarWidget(
                    key: const Key('email_view_app_bar_widget'),
                    presentationEmail: currentEmail,
                    mailboxContain: _getMailboxContain(currentEmail),
                    isSearchActivated: controller.mailboxDashBoardController.searchController.isSearchEmailRunning,
                    onBackAction: () => controller.closeEmailView(context: context),
                    onEmailActionClick: controller.handleEmailAction,
                    onMoreActionClick: (presentationEmail, position) {
                      return controller.emailActionReactor.handleMoreEmailAction(
                        mailboxContain: controller.getMailboxContain(presentationEmail),
                        presentationEmail: presentationEmail,
                        position: position,
                        responsiveUtils: controller.responsiveUtils,
                        imagePaths: controller.imagePaths,
                        ownEmailAddress: controller.ownEmailAddress,
                        handleEmailAction: controller.handleEmailAction,
                        additionalActions: [],
                        emailIsRead: presentationEmail.hasRead,
                        isLabelAvailable: controller.isLabelAvailable,
                        labels: controller.mailboxDashBoardController.labelController.labels,
                        openBottomSheetContextMenu: controller.mailboxDashBoardController.openBottomSheetContextMenu,
                        openPopupMenu: controller.mailboxDashBoardController.openPopupMenuActionGroup,
                        onSelectLabelAction: (label, isSelected) =>
                            controller.toggleLabelToEmail(
                              presentationEmail.id!,
                              label,
                              isSelected,
                            ),
                      );
                    },
                    supportBackAction: !isInsideThreadDetailView,
                    appBarDecoration: isInsideThreadDetailView
                        ? const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColor.colorDividerEmailView,
                              ),
                            ),
                          )
                        : null,
                    emailLoaded: controller.currentEmailLoaded.value,
                    isInsideThreadDetailView: isInsideThreadDetailView,
                  ),
                ),
              if (!isInsideThreadDetailView)
                Obx(() {
                  final vacation = controller.mailboxDashBoardController.vacationResponse.value;

                  bool isPlatformSupportVacationVisible =
                      controller.responsiveUtils.isMobile(context) ||
                          controller.responsiveUtils.isTablet(context) ||
                          controller.responsiveUtils.isLandscapeMobile(context);

                  bool isVacationBannerVisible =
                      vacation?.vacationResponderIsValid == true &&
                          isPlatformSupportVacationVisible;

                  if (isVacationBannerVisible) {
                    return VacationNotificationMessageWidget(
                      margin: const EdgeInsetsDirectional.only(
                        start: 12,
                        end: 12,
                        top: 8,
                      ),
                      vacationResponse: vacation!,
                      actionGotoVacationSetting: controller.mailboxDashBoardController.goToVacationSetting,
                      actionEndNow: controller.mailboxDashBoardController.disableVacationResponder,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              OptionalExpanded(
                expandedEnabled: !isInsideThreadDetailView,
                child: LayoutBuilder(builder: (context, constraints) {
                  return _buildBodyWidget(
                    context,
                    currentEmail,
                    constraints,
                    scrollController: scrollController,
                  );
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
                  userName: controller.ownEmailAddress,
                  emailActionCallback: controller.pressEmailAction,
                );
              }),
            ],
          );
        } else {
          return const EmailViewEmptyWidget();
        }
      }),
    );

    if (PlatformInfo.isMobile) {
      return SafeArea(
        right: controller.responsiveUtils.isLandscapeMobile(context),
        left: controller.responsiveUtils.isLandscapeMobile(context),
        bottom: !PlatformInfo.isIOS,
        child: bodyWidget,
      );
    } else {
      return bodyWidget;
    }
  }

  BoxDecoration _getDecorationEmailView(BuildContext context) {
    if ((controller.responsiveUtils.isWebDesktop(context) && !isInsideThreadDetailView) ||
        controller.currentEmail == null ||
        isFirstEmailInThreadDetail) {
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
    required BoxConstraints bodyConstraints,
    CalendarEvent? calendarEvent,
    List<String>? emailAddressSender,
    ScrollController? scrollController,
  }) {
    final isMobileResponsive = controller.responsiveUtils.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isInsideThreadDetailView || isFirstEmailInThreadDetail)
          Obx(() {
            final isLabelCapabilitySupported = controller
                .mailboxDashBoardController.isLabelCapabilitySupported;

            final labelController =
                controller.mailboxDashBoardController.labelController;

            final isLabelSettingEnabled =
                labelController.isLabelSettingEnabled.isTrue;

            List<Label>? emailLabels;

            if (isLabelCapabilitySupported && isLabelSettingEnabled) {
              emailLabels = presentationEmail.getLabelList(
                labelController.labels,
              );
            }

            return EmailSubjectWidget(
              presentationEmail: presentationEmail.copyWith(
                subject: threadSubject,
              ),
              isMobileResponsive: isMobileResponsive,
              labels: emailLabels,
            );
          }),
        Obx(() => InformationSenderAndReceiverBuilder(
          emailSelected: presentationEmail,
          imagePaths: controller.imagePaths,
          responsiveUtils: controller.responsiveUtils,
          sMimeStatus: controller.currentEmailLoaded.value?.sMimeStatus,
          emailUnsubscribe: controller.emailUnsubscribe.value,
          maxBodyHeight: bodyConstraints.maxHeight,
          isInsideThreadCollapsed: false,
          openEmailAddressDetailAction: (_, emailAddress) => controller.openEmailAddressDialog(emailAddress),
          onEmailActionClick: controller.handleEmailAction,
          isInsideThreadDetailView: isInsideThreadDetailView,
          emailLoaded: controller.currentEmailLoaded.value,
          onMoreActionClick: (presentationEmail, position) => controller.emailActionReactor.handleMoreEmailAction(
            mailboxContain: controller.getMailboxContain(presentationEmail),
            presentationEmail: presentationEmail,
            position: position,
            responsiveUtils: controller.responsiveUtils,
            imagePaths: controller.imagePaths,
            ownEmailAddress: controller.ownEmailAddress,
            handleEmailAction: controller.handleEmailAction,
            additionalActions: [
              EmailActionType.reply,
              EmailActionType.forward,
              EmailActionType.replyAll,
              EmailActionType.replyToList,
              EmailActionType.printAll,
              EmailActionType.moveToMailbox,
              EmailActionType.markAsStarred,
              EmailActionType.unMarkAsStarred,
              EmailActionType.moveToTrash,
              EmailActionType.deletePermanently,
            ],
            emailIsRead: presentationEmail.hasRead,
            isLabelAvailable: controller.isLabelAvailable,
            labels: controller.mailboxDashBoardController.labelController.labels,
            openBottomSheetContextMenu: controller.mailboxDashBoardController.openBottomSheetContextMenu,
            openPopupMenu: controller.mailboxDashBoardController.openPopupMenuActionGroup,
            onSelectLabelAction: (label, isSelected) =>
                controller.toggleLabelToEmail(
                  presentationEmail.id!,
                  label,
                  isSelected,
                ),
          ),
          onToggleThreadDetailCollapseExpand: onToggleThreadDetailCollapseExpand,
          mailboxContain: presentationEmail.findMailboxContain(
            controller.mailboxDashBoardController.mapMailboxById,
          ),
        )),
        Obx(() => MailUnsubscribedBanner(
          presentationEmail: controller.currentEmail,
          emailUnsubscribe: controller.emailUnsubscribe.value
        )),
        Obx(() => EmailViewLoadingBarWidget(
          viewState: controller.emailLoadedViewState.value
        )),
        if (!isMobileResponsive)
          _buildAttachmentsList(context),
        if (calendarEvent != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => CalendarEventInformationWidget(
                calendarEvent: calendarEvent,
                imagePaths: controller.imagePaths,
                onOpenComposerAction: controller.openNewComposerAction,
                onOpenNewTabAction: controller.openNewTabAction,
                onCalendarEventReplyActionClick: (eventActionType) =>
                  controller.onCalendarEventReplyAction(
                      eventActionType,
                      presentationEmail.id!,
                  ),
                calendarEventReplying: controller.calendarEventProcessing,
                attendanceStatus: controller.attendanceStatus.value,
                ownEmailAddress: controller.ownEmailAddress,
                onMailtoAttendeesAction: controller.handleMailToAttendees,
                openEmailAddressDetailAction: (_, emailAddress) => controller.openEmailAddressDialog(emailAddress),
                isFreeBusyEnabled: controller.isFreeBusyEnabled(emailAddressSender ?? []),
                listEmailAddressSender: emailAddressSender ?? [],
                isPortraitMobile: controller
                    .responsiveUtils
                    .isPortraitMobile(context),
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
                onMailtoDelegateAction: (uri) async => controller.openMailToLink(uri),
                presentationEmail: controller.currentEmail,
                scrollController: scrollController,
                isInsideThreadDetailView: isInsideThreadDetailView,
                onIFrameClickAction: controller.handleOnIFrameClick,
              )),
            ],
          )
        else if (presentationEmail.id == controller.currentEmail?.id)
          Obx(() {
            if (controller.emailContents.value != null) {
              final allEmailContents = controller.emailContents.value ?? '';

              if (PlatformInfo.isWeb) {
                return Padding(
                  padding: EmailViewStyles.emailContentPadding,
                  child: HtmlContentViewerOnWeb(
                    key: controller.htmlViewKey,
                    widthContent: bodyConstraints.maxWidth,
                    contentHtml: allEmailContents,
                    mailtoDelegate: controller.openMailToLink,
                    direction: AppUtils.getCurrentDirection(context),
                    contentPadding: 0,
                    useDefaultFontStyle: true,
                    scrollController: scrollController,
                    enableQuoteToggle: true,
                    useLinkTooltipOverlay: true,
                    fontSize: isMobileResponsive ? 16 : 14,
                    onIFrameKeyboardShortcutAction: onIFrameKeyboardShortcutAction,
                    onIFrameClickAction: controller.handleOnIFrameClick,
                    iframeTooltipOptions: IframeTooltipOptions(
                      tooltipTextStyle: ThemeUtils.textStyleInter400.copyWith(
                        color: Colors.white,
                      ),
                    ),
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
                          padding: EmailViewStyles.mobileEmailContentPadding,
                          child: HtmlContentViewer(
                            key: PlatformInfo.isIntegrationTesting
                                ? controller.htmlContentViewKey
                                : null,
                            contentHtml: allEmailContents,
                            initialWidth: bodyConstraints.maxWidth,
                            direction: AppUtils.getCurrentDirection(context),
                            contentPadding: 0,
                            useDefaultFontStyle: true,
                            maxHtmlContentHeight: ConstantsUI.htmlContentMaxHeight,
                            onMailtoDelegateAction: (uri) async => controller.openMailToLink(uri),
                            onHtmlContentClippedAction: controller.onHtmlContentClippedAction,
                            onScrollHorizontalEnd: controller.onScrollHorizontalEnd,
                            keepAlive: isInsideThreadDetailView,
                            enableQuoteToggle: true,
                            fontSize: isMobileResponsive ? 16 : 14,
                          ),
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
                  padding: EmailViewStyles.mobileEmailContentPadding,
                  child: HtmlContentViewer(
                    key: PlatformInfo.isIntegrationTesting
                        ? controller.htmlContentViewKey
                        : null,
                    contentHtml: allEmailContents,
                    initialWidth: bodyConstraints.maxWidth,
                    direction: AppUtils.getCurrentDirection(context),
                    contentPadding: 0,
                    useDefaultFontStyle: true,
                    onMailtoDelegateAction: (uri) async => controller.openMailToLink(uri),
                    keepAlive: isInsideThreadDetailView,
                    enableQuoteToggle: true,
                    onScrollHorizontalEnd: controller.onScrollHorizontalEnd,
                    fontSize: isMobileResponsive ? 16 : 14,
                  )
                );
              }
            } else {
              return const SizedBox.shrink();
            }
          }),
        if (PlatformInfo.isIntegrationTesting)
          const Divider(
            key: Key('integration_testing_email_detailed_divider'),
            height: 5,
            color: Colors.transparent,
          ),
        if (isMobileResponsive)
          _buildAttachmentsList(context),
      ],
    );
  }

  Widget _buildAttachmentsList(BuildContext context) {
    return Obx(() {
      if (controller.attachments.isNotEmpty) {
        return EmailAttachmentsWidget(
          key: PlatformInfo.isWeb && controller.responsiveUtils.isMobile(context)
              ? controller.attachmentListKey
              : null,
          responsiveUtils: controller.responsiveUtils,
          attachments: controller.attachments,
          imagePaths: controller.imagePaths,
          isDisplayAllAttachments: controller.isDisplayAllAttachments.value,
          onDragStarted: controller
              .mailboxDashBoardController.enableAttachmentDraggableApp,
          onDragEnd: (_) {
            controller
                .mailboxDashBoardController
                .disableAttachmentDraggableApp();
          },
          downloadAttachmentAction: (attachment) =>
              controller.handleDownloadAttachmentAction(attachment),
          viewAttachmentAction: (attachment) =>
              controller.handleViewAttachmentAction(
                context,
                attachment,
              ),
          onTapShowAllAttachmentFile: controller.showAllAttachmentsAction,
          onTapHideAllAttachments: controller.hideAllAttachmentsAction,
          showDownloadAllAttachmentsButton: controller.downloadAllButtonIsEnabled(),
          onTapDownloadAllButton: () =>
              controller.handleDownloadAllAttachmentsAction(
                'TwakeMail-${DateTime.now()}',
              ),
          singleEmailControllerTag: tag,
        );
      } else {
        return const SizedBox.shrink();
      }
    });
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

  Widget _buildMobileBodyWidget(
    BuildContext context,
    PresentationEmail currentEmail,
    BoxConstraints constraints,
  ) {
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
          bodyConstraints: constraints,
        ))
      )
    );
  }

  Widget _buildWebBodyWidget(
    BuildContext context,
    PresentationEmail currentEmail,
    BoxConstraints constraints, {
    required ScrollController? scrollController
  }) {
    return Obx(() {
      final calendarEvent = controller.calendarEvent;

      final emailContentWidget = Stack(
        children: [
          OptionalScroll(
            scrollEnabled: !isInsideThreadDetailView,
            scrollPhysics : const ClampingScrollPhysics(),
            child: _buildEmailMessage(
              context: context,
              presentationEmail: currentEmail,
              bodyConstraints: constraints,
              scrollController: scrollController,
              calendarEvent: calendarEvent,
              emailAddressSender: currentEmail.listEmailAddressSender.getListAddress(),
            ),
          ),
          Obx(() {
            final dialogRouter = DialogRouter();
            bool isOverlayEnabled = controller.mailboxDashBoardController.isDisplayedOverlayViewOnIFrame ||
                MessageDialogActionManager().isDialogOpened ||
                EmailActionReactor.isDialogOpened ||
                ColorDialogPicker().isOpened.isTrue ||
                dialogRouter.isRuleFilterDialogOpened.isTrue ||
                dialogRouter.isDialogOpened;

            if (isOverlayEnabled) {
              return Positioned.fill(
                child: PointerInterceptor(
                  child: const SizedBox.expand(),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      );

      if (calendarEvent != null) {
        return Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
          child: emailContentWidget,
        );
      } else {
        return emailContentWidget;
      }
    });
  }

  Widget _buildBodyWidget(
    BuildContext context,
    PresentationEmail currentEmail,
    BoxConstraints constraints, {
    required ScrollController? scrollController,
  }) {
    if (PlatformInfo.isWeb) {
      return _buildWebBodyWidget(
        context,
        currentEmail,
        constraints,
        scrollController: scrollController,
      );
    } else {
      return _buildMobileBodyWidget(
        context,
        currentEmail,
        constraints,
      );
    }
  }
}