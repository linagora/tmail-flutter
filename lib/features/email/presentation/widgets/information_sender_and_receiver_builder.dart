import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/icon_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/email_avatar_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_unsubscribe.dart';
import 'package:tmail_ui_user/features/email/presentation/model/smime_signature_status.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_receiver_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_app_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/received_time_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class InformationSenderAndReceiverBuilder extends StatelessWidget {

  final PresentationEmail emailSelected;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final EmailUnsubscribe? emailUnsubscribe;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;
  final OnEmailActionClick? onEmailActionClick;
  final double? maxBodyHeight;
  final SMimeSignatureStatus? sMimeStatus;
  final bool isInsideThreadDetailView;
  final EmailLoaded? emailLoaded;
  final OnMoreActionClick? onMoreActionClick;
  final bool showRecipients;
  final VoidCallback? onToggleThreadDetailCollapseExpand;
  final PresentationMailbox? mailboxContain;
  final bool showUnreadVisualization;
  final bool isInsideThreadCollapsed;

  const InformationSenderAndReceiverBuilder({
    Key? key,
    required this.emailSelected,
    required this.responsiveUtils,
    required this.imagePaths,
    this.sMimeStatus,
    this.emailUnsubscribe,
    this.maxBodyHeight,
    this.openEmailAddressDetailAction,
    this.onEmailActionClick,
    this.isInsideThreadDetailView = false,
    this.emailLoaded,
    this.onMoreActionClick,
    this.showRecipients = true,
    this.onToggleThreadDetailCollapseExpand,
    this.mailboxContain,
    this.showUnreadVisualization = false,
    this.isInsideThreadCollapsed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobileResponsive = responsiveUtils.isMobile(context);
    final crossAxisAlignment = _getAxisAlignment(isMobileResponsive);

    return Padding(
      padding: _getPadding(isMobileResponsive),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          EmailAvatarBuilder(
            emailSelected: emailSelected,
            onTapAvatarActionClick: () {
              if (emailSelected.from?.isNotEmpty == true) {
                openEmailAddressDetailAction?.call(
                  context,
                  emailSelected.from!.first,
                );
              }
            },
            size: isMobileResponsive ? 44 : 32,
            textStyle: !isMobileResponsive
                ? ThemeUtils.textStyleHeadingHeadingSmall(color: Colors.white)
                : ThemeUtils.textStyleInter600().copyWith(
                    fontSize: 18.86,
                    height: 17.29 / 18.86,
                    letterSpacing: -0.32,
                    color: Colors.white,
                  ),
            padding: crossAxisAlignment == CrossAxisAlignment.start
                ? const EdgeInsetsDirectional.only(top: 4)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            return InkWell(
              onTap: onToggleThreadDetailCollapseExpand,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (showUnreadVisualization &&
                                !emailSelected.hasRead &&
                                isMobileResponsive)
                              TMailButtonWidget.fromIcon(
                                icon: imagePaths.icUnreadStatus,
                                backgroundColor: Colors.transparent,
                                iconSize: 9,
                                onTapActionCallback: () => onEmailActionClick?.call(
                                  emailSelected,
                                  EmailActionType.markAsRead,
                                ),
                              ),
                            if (emailSelected.from?.isNotEmpty == true)
                              Flexible(
                                child: EmailSenderBuilder(
                                  emailAddress: emailSelected.from!.first,
                                  openEmailAddressDetailAction: openEmailAddressDetailAction,
                                  showSenderEmail: _showSenderEmail(
                                    isMobileResponsive,
                                    senderEmail: emailSelected.from!.first,
                                  ),
                                  isMobileResponsive: isMobileResponsive,
                                ),
                              ),
                            if (sMimeStatus != null && sMimeStatus != SMimeSignatureStatus.notSigned)
                              Tooltip(
                                key: const Key('smime_signature_status_icon'),
                                message: sMimeStatus!.getTooltipMessage(context),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: SvgPicture.asset(
                                    sMimeStatus!.getIcon(imagePaths),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            if (!emailSelected.isSubscribed && emailUnsubscribe != null && !responsiveUtils.isPortraitMobile(context))
                              TMailButtonWidget.fromText(
                                text: AppLocalizations.of(context).unsubscribe,
                                textStyle: ThemeUtils.textStyleInter400.copyWith(
                                  fontSize: 14,
                                  height: 1,
                                  letterSpacing: -0.14,
                                  color: AppColor.gray6D7885,
                                  decoration: TextDecoration.underline,
                                ),
                                padding: const EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 8),
                                backgroundColor: Colors.transparent,
                                onTapActionCallback: () => onEmailActionClick?.call(emailSelected, EmailActionType.unsubscribe),
                              ),
                            if (_showAttachmentIcon() && !isMobileResponsive)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(start: 8),
                                child: SvgPicture.asset(
                                  imagePaths.icAttachment,
                                  colorFilter: AppColor.steelGray200.asFilter(),
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            if (isInsideThreadDetailView && !isMobileResponsive)
                              ReceivedTimeBuilder(
                                emailSelected: emailSelected,
                                padding: const EdgeInsetsDirectional.only(start: 8, top: 2),
                                showDaysAgo: _showDaysAgo(responsiveUtils.isDesktop(context)),
                              ),
                            if (showUnreadVisualization &&
                                !emailSelected.hasRead &&
                                !isMobileResponsive)
                              TMailButtonWidget.fromIcon(
                                icon: imagePaths.icUnreadStatus,
                                backgroundColor: Colors.transparent,
                                iconSize: 9,
                                margin: const EdgeInsetsDirectional.only(start: 8),
                                onTapActionCallback: () => onEmailActionClick?.call(
                                  emailSelected,
                                  EmailActionType.markAsRead,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!isInsideThreadDetailView)
                        ReceivedTimeBuilder(
                          emailSelected: emailSelected,
                          padding: const EdgeInsetsDirectional.only(start: 16, top: 2),
                          showDaysAgo: _showDaysAgo(responsiveUtils.isDesktop(context)),
                        ),
                      if (isInsideThreadDetailView)
                        SizedBox(
                          height: IconUtils.defaultIconSize,
                          child: OverflowBox(
                            maxHeight: EmailViewAppBarWidgetStyles.height,
                            fit: OverflowBoxFit.deferToChild,
                            child: EmailViewAppBarWidget(
                              key: const Key('email_view_app_bar_widget'),
                              presentationEmail: emailSelected,
                              mailboxContain: mailboxContain,
                              isSearchActivated: false,
                              onBackAction: () {},
                              onEmailActionClick: onEmailActionClick,
                              onMoreActionClick: onMoreActionClick,
                              supportBackAction: false,
                              appBarDecoration: const BoxDecoration(),
                              emailLoaded: emailLoaded,
                              isInsideThreadDetailView: isInsideThreadDetailView,
                              iconPadding: const EdgeInsets.all(8),
                              iconMargin: EdgeInsets.zero,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isMobileResponsive && isInsideThreadDetailView)
                    Row(
                      children: [
                        if (_showAttachmentIcon())
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: SvgPicture.asset(
                              imagePaths.icAttachment,
                              colorFilter: AppColor.steelGray200.asFilter(),
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ReceivedTimeBuilder(
                          emailSelected: emailSelected,
                          padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
                          showDaysAgo: _showDaysAgo(responsiveUtils.isDesktop(context)),
                        ),
                      ],
                    ),
                  if (emailSelected.countRecipients > 0 && showRecipients)
                    EmailReceiverWidget(
                      emailSelected: emailSelected,
                      maxWidth: constraints.maxWidth,
                      maxHeight: maxBodyHeight,
                      openEmailAddressDetailAction: openEmailAddressDetailAction,
                    )
                ]
              ),
            );
          })),
        ]
      ),
    );
  }

  EdgeInsetsGeometry _getPadding(bool isMobileResponsive) {
    if (isInsideThreadCollapsed) {
      return EdgeInsetsDirectional.symmetric(
        horizontal: isMobileResponsive ? 12 : 16,
        vertical: isMobileResponsive ? 12 : 8,
      );
    } else {
      return EdgeInsetsDirectional.all(isMobileResponsive ? 12 : 16);
    }
  }

  CrossAxisAlignment _getAxisAlignment(bool isMobileResponsive) {
    return emailSelected.countRecipients > 0 &&
            (showRecipients || isMobileResponsive)
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
  }

  bool _showSenderEmail(
    bool isResponsiveMobile, {
    required EmailAddress senderEmail,
  }) {
    return senderEmail.displayName.isEmpty ||
        (emailSelected.emailInThreadStatus == EmailInThreadStatus.expanded &&
            !isResponsiveMobile);
  }

  bool _showAttachmentIcon() {
    return isInsideThreadDetailView &&
      emailSelected.hasAttachment == true &&
      emailSelected.emailInThreadStatus == EmailInThreadStatus.collapsed;
  }

  bool _showDaysAgo(bool isResponsiveDesktop) {
    return isInsideThreadDetailView && isResponsiveDesktop;
  }
}