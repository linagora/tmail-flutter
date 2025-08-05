import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnThreadActionClick = void Function(EmailActionType);
typedef OnThreadMoreActionClick = void Function(RelativeRect?);

class ThreadDetailAppBar extends StatelessWidget {
  const ThreadDetailAppBar({
    super.key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.isSearchRunning,
    required this.closeThreadDetailAction,
    required this.threadActionReady,
    required this.threadDetailIsStarred,
    required this.isThreadDetailEnabled,
    this.mailboxContain,
    this.optionWidgets = const [],
    this.onThreadActionClick,
    this.onThreadMoreActionClick,
  });

  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final bool isSearchRunning;
  final void Function(BuildContext context) closeThreadDetailAction;
  final bool threadActionReady;
  final bool threadDetailIsStarred;
  final bool isThreadDetailEnabled;
  final PresentationMailbox? mailboxContain;
  final List<Widget> optionWidgets;
  final OnThreadActionClick? onThreadActionClick;
  final OnThreadMoreActionClick? onThreadMoreActionClick;

  @override
  Widget build(BuildContext context) {
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
              if (isThreadDetailEnabled && threadActionReady)
                _ThreadDetailAppBarButton(
                  icon: threadDetailIsStarred
                      ? imagePaths.icStar
                      : imagePaths.icUnStar,
                  tooltipMessage: threadDetailIsStarred
                      ? AppLocalizations.of(context).not_starred
                      : AppLocalizations.of(context).mark_as_starred,
                  responsiveUtils: responsiveUtils,
                  iconColor: null,
                  onTapActionCallback: threadDetailIsStarred
                      ? (_) => onThreadActionClick?.call(EmailActionType.unMarkAsStarred)
                      : (_) => onThreadActionClick?.call(EmailActionType.markAsStarred),
                ),
              if (!responsiveUtils.isMobile(context)) const Spacer(),
              if (AppUtils.getCurrentDirection(context) == TextDirection.rtl)
                ...optionWidgets.reversed
              else
                ...optionWidgets,
              if (isThreadDetailEnabled && threadActionReady)
                _ThreadDetailAppBarButton(
                  icon: imagePaths.icMoreVertical,
                  tooltipMessage: AppLocalizations.of(context).more,
                  responsiveUtils: responsiveUtils,
                  onTapActionCallback: onThreadMoreActionClick,
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
    this.iconColor = EmailViewAppBarWidgetStyles.iconColor,
  });

  final String icon;
  final String tooltipMessage;
  final void Function(RelativeRect? position)? onTapActionCallback;
  final ResponsiveUtils responsiveUtils;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final smallScreen = responsiveUtils.isScreenWithShortestSide(context);

    return TMailButtonWidget.fromIcon(
      icon: icon,
      iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
      iconColor: iconColor,
      backgroundColor: Colors.transparent,
      tooltipMessage: tooltipMessage,
      onTapActionCallback:
          smallScreen ? () => onTapActionCallback?.call(null) : null,
      onTapActionAtPositionCallback: !smallScreen
          ? (position) => onTapActionCallback?.call(position)
          : null,
    );
  }
}
