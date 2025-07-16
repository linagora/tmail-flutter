import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/icon_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
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
  final OnTapAvatarActionClick? onTapAvatarActionClick;
  final PresentationMailbox? mailboxContain;
  final bool showUnreadVisualization;

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
    this.onTapAvatarActionClick,
    this.mailboxContain,
    this.showUnreadVisualization = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: emailSelected.countRecipients > 0 && (showRecipients || responsiveUtils.isMobile(context))
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
        children: [
          EmailAvatarBuilder(
            emailSelected: emailSelected,
            onTapAvatarActionClick: onTapAvatarActionClick,
            size: 56,
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
                                responsiveUtils.isMobile(context))
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
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: AppColor.colorTextBody,
                                  decoration: TextDecoration.underline,
                                ),
                                padding: const EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 8),
                                backgroundColor: Colors.transparent,
                                onTapActionCallback: () => onEmailActionClick?.call(emailSelected, EmailActionType.unsubscribe),
                              ),
                            if (isInsideThreadDetailView && !responsiveUtils.isMobile(context))
                              ReceivedTimeBuilder(
                                emailSelected: emailSelected,
                                padding: const EdgeInsetsDirectional.only(start: 16, top: 2),
                              ),
                            if (showUnreadVisualization &&
                                !emailSelected.hasRead &&
                                !responsiveUtils.isMobile(context))
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
                  if (responsiveUtils.isMobile(context) && isInsideThreadDetailView)
                    ReceivedTimeBuilder(
                      emailSelected: emailSelected,
                      padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
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
}