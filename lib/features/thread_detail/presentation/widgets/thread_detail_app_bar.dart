import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_bottom_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_app_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';


class ThreadDetailAppBar extends StatelessWidget {
  const ThreadDetailAppBar({
    super.key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.isSearchRunning,
    required this.closeThreadDetailAction,
    required this.firstEmailOfThread,
    required this.ownUserName,
    this.mailboxContain,
    this.optionWidgets = const [],
    this.onEmailActionClick,
    this.onMoreActionClick,
    this.emailLoaded,
  });

  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final bool isSearchRunning;
  final void Function(BuildContext context) closeThreadDetailAction;
  final PresentationEmail? firstEmailOfThread;
  final String ownUserName;
  final PresentationMailbox? mailboxContain;
  final List<Widget> optionWidgets;
  final OnEmailActionClick? onEmailActionClick;
  final OnMoreActionClick? onMoreActionClick;
  final EmailLoaded? emailLoaded;

  @override
  Widget build(BuildContext context) {
    if (responsiveUtils.isTablet(context)) return const SizedBox.shrink();
    final isReplyToListEnabled = EmailUtils.isReplyToListEnabled(
      emailLoaded?.emailCurrent?.listPost ?? '',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: PlatformInfo.isIOS
            ? EmailViewAppBarWidgetStyles.heightIOS(context, responsiveUtils)
            : EmailViewAppBarWidgetStyles.height,
          padding: PlatformInfo.isIOS
            ? EmailViewAppBarWidgetStyles.paddingIOS(context, responsiveUtils)
            : EmailViewAppBarWidgetStyles.padding,
          margin: !PlatformInfo.isMobile && responsiveUtils.isDesktop(context)
            ? const EdgeInsetsDirectional.only(end: 16)
            : EdgeInsets.zero,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: EmailViewAppBarWidgetStyles.bottomBorderColor,
                width: EmailViewAppBarWidgetStyles.bottomBorderWidth,
              ),
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(EmailViewAppBarWidgetStyles.radius),
            ),
            color: EmailViewAppBarWidgetStyles.backgroundColor,
          ),
          child: Row(
            children: [
              if (_supportDisplayMailboxNameTitle(context))
                EmailViewBackButton(
                  imagePaths: imagePaths,
                  onBackAction: () => closeThreadDetailAction(context),
                  mailboxContain: mailboxContain,
                  isSearchActivated: isSearchRunning,
                  maxWidth: constraints.maxWidth,
                ),
              const Spacer(),
              ...optionWidgets,
              if (firstEmailOfThread != null) ...[
                TMailButtonWidget.fromIcon(
                  icon: imagePaths.icReply,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  iconColor: EmailViewAppBarWidgetStyles.iconColor,
                  tooltipMessage: AppLocalizations.of(context).reply,
                  backgroundColor: Colors.transparent,
                  onTapActionCallback: () => onEmailActionClick?.call(
                    firstEmailOfThread!,
                    EmailActionType.reply,
                  ),
                ),
                if (firstEmailOfThread!.getCountMailAddressWithoutMe(ownUserName) > 1)
                  TMailButtonWidget.fromIcon(
                    icon: imagePaths.icReplyAll,
                    iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                    iconColor: EmailViewAppBarWidgetStyles.iconColor,
                    tooltipMessage: AppLocalizations.of(context).reply_all,
                    backgroundColor: Colors.transparent,
                    onTapActionCallback: () => onEmailActionClick?.call(
                      firstEmailOfThread!,
                      EmailActionType.replyAll,
                    ),
                  ),
                if (isReplyToListEnabled)
                  TMailButtonWidget(
                    key: const Key('reply_to_list_email_button'),
                    text: AppLocalizations.of(context).replyToList,
                    icon: imagePaths.icReply,
                    borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                    iconSize: EmailViewBottomBarWidgetStyles.buttonIconSize,
                    iconColor: EmailViewBottomBarWidgetStyles.iconColor,
                    textAlign: TextAlign.center,
                    flexibleText: true,
                    padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                    backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                    textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(
                      context,
                      responsiveUtils,
                    ),
                    verticalDirection: responsiveUtils.isPortraitMobile(context),
                    onTapActionCallback: () => onEmailActionClick?.call(
                      firstEmailOfThread!,
                      EmailActionType.replyToList,
                    ),
                  ),
                TMailButtonWidget.fromIcon(
                  icon: imagePaths.icForward,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  iconColor: EmailViewAppBarWidgetStyles.iconColor,
                  tooltipMessage: AppLocalizations.of(context).forward,
                  backgroundColor: Colors.transparent,
                  onTapActionCallback: () => onEmailActionClick?.call(
                    firstEmailOfThread!,
                    EmailActionType.forward,
                  ),
                ),
                TMailButtonWidget.fromIcon(
                  icon: firstEmailOfThread!.hasStarred
                    ? imagePaths.icStar
                    : imagePaths.icUnStar,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  iconColor: firstEmailOfThread!.hasStarred
                    ? null
                    : EmailViewAppBarWidgetStyles.iconColor,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: firstEmailOfThread!.hasStarred
                    ? AppLocalizations.of(context).not_starred
                    : AppLocalizations.of(context).mark_as_starred,
                  onTapActionCallback: () => onEmailActionClick?.call(
                    firstEmailOfThread!,
                    firstEmailOfThread!.hasStarred
                      ? EmailActionType.unMarkAsStarred
                      : EmailActionType.markAsStarred
                  ),
                ),
                TMailButtonWidget.fromIcon(
                  icon: imagePaths.icMoreVertical,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  iconColor: EmailViewAppBarWidgetStyles.iconColor,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).more,
                  onTapActionCallback: responsiveUtils.isScreenWithShortestSide(context)
                    ? () => onMoreActionClick?.call(firstEmailOfThread!, null)
                    : null,
                  onTapActionAtPositionCallback: !responsiveUtils.isScreenWithShortestSide(context)
                    ? (position) => onMoreActionClick?.call(firstEmailOfThread!, position)
                    : null,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  bool _supportDisplayMailboxNameTitle(BuildContext context) {
    final isSupportedDevice = PlatformInfo.isWeb
      ? responsiveUtils.isDesktop(context)
          || responsiveUtils.isMobile(context)
          || responsiveUtils.isTablet(context)
      : responsiveUtils.isPortraitMobile(context)
          || responsiveUtils.isLandscapeMobile(context)
          || responsiveUtils.isTablet(context);
    return isSupportedDevice || isSearchRunning;
  }
}
