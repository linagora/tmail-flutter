import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_app_bar_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class ThreadDetailAppBar extends StatelessWidget {
  const ThreadDetailAppBar({
    super.key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.isSearchRunning,
    required this.closeThreadDetailAction,
    required this.lastEmailOfThread,
    required this.ownUserName,
    required this.isThreadDetailEnabled,
    this.mailboxContain,
    this.optionWidgets = const [],
    this.onEmailActionClick,
    this.onMoreActionClick,
  });

  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final bool isSearchRunning;
  final void Function(BuildContext context) closeThreadDetailAction;
  final PresentationEmail? lastEmailOfThread;
  final String ownUserName;
  final bool isThreadDetailEnabled;
  final PresentationMailbox? mailboxContain;
  final List<Widget> optionWidgets;
  final OnEmailActionClick? onEmailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  @override
  Widget build(BuildContext context) {
    final isReplyToListEnabled = EmailUtils.isReplyToListEnabled(
      lastEmailOfThread?.listPost ?? '',
    );

    final child = LayoutBuilder(
      builder: (context, constraints) {
        Widget backButton = EmailViewBackButton(
          imagePaths: imagePaths,
          onBackAction: () => closeThreadDetailAction(context),
          mailboxContain: mailboxContain,
          isSearchActivated: isSearchRunning,
          maxWidth: constraints.maxWidth,
        );
        if (responsiveUtils.isMobile(context)) {
          backButton = Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: backButton,
            ),
          );
        }

        return Container(
          height: PlatformInfo.isIOS
            ? EmailViewAppBarWidgetStyles.heightIOS(context, responsiveUtils)
            : EmailViewAppBarWidgetStyles.height,
          padding: PlatformInfo.isIOS
            ? EmailViewAppBarWidgetStyles.paddingIOS(context, responsiveUtils)
            : EmailViewAppBarWidgetStyles.padding,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: EmailViewAppBarWidgetStyles.bottomBorderColor,
                width: EmailViewAppBarWidgetStyles.bottomBorderWidth,
              ),
            ),
            color: EmailViewAppBarWidgetStyles.backgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_supportDisplayMailboxNameTitle(context)) backButton,
              if (lastEmailOfThread != null && isThreadDetailEnabled) ...[
                _ThreadDetailAppBarButton(
                  icon: imagePaths.icReply,
                  tooltipMessage: AppLocalizations.of(context).reply,
                  responsiveUtils: responsiveUtils,
                  onTapActionCallback: (_) => onEmailActionClick?.call(
                    lastEmailOfThread!,
                    EmailActionType.reply,
                  ),
                ),
                if (!responsiveUtils.isMobile(context)) ...[
                  if (lastEmailOfThread!.getCountMailAddressWithoutMe(ownUserName) > 1)
                    _ThreadDetailAppBarButton(
                      icon: imagePaths.icReplyAll,
                      tooltipMessage: AppLocalizations.of(context).reply_all,
                      responsiveUtils: responsiveUtils,
                      onTapActionCallback: (_) => onEmailActionClick?.call(
                        lastEmailOfThread!,
                        EmailActionType.replyAll,
                      ),
                    ),
                  if (isReplyToListEnabled)
                    _ThreadDetailAppBarButton(
                      icon: imagePaths.icReply,
                      tooltipMessage: AppLocalizations.of(context).replyToList,
                      responsiveUtils: responsiveUtils,
                      onTapActionCallback: (_) => onEmailActionClick?.call(
                        lastEmailOfThread!,
                        EmailActionType.replyToList,
                      ),
                    ),
                  _ThreadDetailAppBarButton(
                    icon: imagePaths.icForward,
                    tooltipMessage: AppLocalizations.of(context).forward,
                    responsiveUtils: responsiveUtils,
                    onTapActionCallback: (_) => onEmailActionClick?.call(
                      lastEmailOfThread!,
                      EmailActionType.forward,
                    ),
                  ),
                ],
                if (!responsiveUtils.isMobile(context)) const Spacer(),
              ] else const Spacer(),
              if (AppUtils.getCurrentDirection(context) == TextDirection.rtl)
                ...optionWidgets.reversed
              else
                ...optionWidgets,
              if (lastEmailOfThread != null)
                _ThreadDetailAppBarButton(
                  icon: imagePaths.icMoreVertical,
                  tooltipMessage: AppLocalizations.of(context).more,
                  responsiveUtils: responsiveUtils,
                  onTapActionCallback: lastEmailOfThread != null
                    ? (position) => onMoreActionClick?.call(lastEmailOfThread!, position)
                    : null,
                ),
            ],
          ),
        );
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        closeThreadDetailAction(context);
      },
      child: child,
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

class _ThreadDetailAppBarButton extends StatelessWidget {
  const _ThreadDetailAppBarButton({
    required this.icon,
    required this.tooltipMessage,
    required this.onTapActionCallback,
    required this.responsiveUtils,
  });

  final String icon;
  final String tooltipMessage;
  final void Function(RelativeRect? position)? onTapActionCallback;
  final ResponsiveUtils responsiveUtils;

  @override
  Widget build(BuildContext context) {
    final smallScreen = responsiveUtils.isScreenWithShortestSide(context);
    return TMailButtonWidget.fromIcon(
      icon: icon,
      iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
      iconColor: EmailViewAppBarWidgetStyles.iconColor,
      backgroundColor: Colors.transparent,
      tooltipMessage: AppLocalizations.of(context).more,
      onTapActionCallback:
          smallScreen ? () => onTapActionCallback?.call(null) : null,
      onTapActionAtPositionCallback: !smallScreen
          ? (position) => onTapActionCallback?.call(position)
          : null,
    );
  }
}