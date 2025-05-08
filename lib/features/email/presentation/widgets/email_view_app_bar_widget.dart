import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEmailActionClick = void Function(PresentationEmail, EmailActionType);
typedef OnMoreActionClick = void Function(PresentationEmail, RelativeRect?);

class EmailViewAppBarWidget extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final PresentationEmail presentationEmail;
  final List<Widget>? optionsWidget;
  final PresentationMailbox? mailboxContain;
  final bool isSearchActivated;
  final VoidCallback onBackAction;
  final OnEmailActionClick? onEmailActionClick;
  final OnMoreActionClick? onMoreActionClick;
  final bool supportBackAction;
  final BoxDecoration? appBarDecoration;
  final EmailLoaded? emailLoaded;
  final bool isInsideThreadDetailView;
  final double? height;
  final EdgeInsetsGeometry? iconPadding;
  final EdgeInsetsGeometry? iconMargin;
  final EdgeInsetsGeometry? padding;

  EmailViewAppBarWidget({
    Key? key,
    required this.presentationEmail,
    required this.onBackAction,
    required this.isSearchActivated,
    this.mailboxContain,
    this.onEmailActionClick,
    this.onMoreActionClick,
    this.optionsWidget,
    this.supportBackAction = true,
    this.appBarDecoration,
    required this.emailLoaded,
    this.isInsideThreadDetailView = false,
    this.height,
    this.iconPadding,
    this.iconMargin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height ?? (PlatformInfo.isIOS
          ? EmailViewAppBarWidgetStyles.heightIOS(context, _responsiveUtils)
          : EmailViewAppBarWidgetStyles.height),
        padding: padding ?? (PlatformInfo.isIOS
          ? EmailViewAppBarWidgetStyles.paddingIOS(context, _responsiveUtils)
          : EmailViewAppBarWidgetStyles.padding),
        decoration: appBarDecoration ?? const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: EmailViewAppBarWidgetStyles.bottomBorderColor,
              width: EmailViewAppBarWidgetStyles.bottomBorderWidth,
            )
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(EmailViewAppBarWidgetStyles.radius),
            topRight: Radius.circular(EmailViewAppBarWidgetStyles.radius),
          ),
          color: EmailViewAppBarWidgetStyles.backgroundColor,
        ),
        child: Row(children: [
          if (_supportDisplayMailboxNameTitle(context) && supportBackAction)
            Expanded(
              child: EmailViewBackButton(
                imagePaths: _imagePaths,
                onBackAction: onBackAction,
                mailboxContain: mailboxContain,
                isSearchActivated: isSearchActivated,
                maxWidth: constraints.maxWidth,
              ),
            ),
          Row(
            children: [
              if (optionsWidget != null) ... optionsWidget!,
              ..._buildActionButtons(
                appLocalizations: AppLocalizations.of(context),
                isScreenWithShortestSide: _responsiveUtils.isScreenWithShortestSide(context),
                isResponsiveMobile: _responsiveUtils.isMobile(context),
                isResponsiveDesktop: _responsiveUtils.isDesktop(context),
              ),
            ]
          ),
        ])
      );
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        if (!PlatformInfo.isAndroid) return;
        onBackAction();
      },
      child: child,
    );
  }

  bool _supportDisplayMailboxNameTitle(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return _responsiveUtils.isDesktop(context) ||
        _responsiveUtils.isMobile(context) ||
        _responsiveUtils.isTablet(context) ||
        isSearchActivated;
    } else {
      return _responsiveUtils.isPortraitMobile(context) ||
        _responsiveUtils.isLandscapeMobile(context) ||
        _responsiveUtils.isTablet(context) ||
        isSearchActivated;
    }
  }

  bool get canDeletePermanently {
    return mailboxContain?.isTrash == true || mailboxContain?.isSpam == true;
  }

  Widget getReplyButton(AppLocalizations appLocalizations) => TMailButtonWidget.fromIcon(
    icon: _imagePaths.icReply,
    iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
    iconColor: EmailViewAppBarWidgetStyles.iconColor,
    tooltipMessage: appLocalizations.reply,
    backgroundColor: Colors.transparent,
    onTapActionCallback: () => onEmailActionClick?.call(
      presentationEmail,
      EmailActionType.reply,
    ),
    padding: iconPadding,
    margin: iconMargin,
  );

  Widget getPrintButton(AppLocalizations appLocalizations) => AbsorbPointer(
    absorbing: emailLoaded == null,
    child: TMailButtonWidget.fromIcon(
      icon: _imagePaths.icPrinter,
      iconSize: EmailViewAppBarWidgetStyles.deleteButtonIconSize,
      iconColor: EmailViewAppBarWidgetStyles.iconColor,
      backgroundColor: Colors.transparent,
      tooltipMessage: appLocalizations.printAll,
      onTapActionCallback: () => onEmailActionClick?.call(
        presentationEmail,
        EmailActionType.printAll,
      ),
      padding: iconPadding,
      margin: iconMargin,
    ),
  );

  Widget getMoveEmailButton(AppLocalizations appLocalizations) => TMailButtonWidget.fromIcon(
    icon: _imagePaths.icMoveEmail,
    iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
    iconColor: EmailViewAppBarWidgetStyles.iconColor,
    tooltipMessage: appLocalizations.move_message,
    backgroundColor: Colors.transparent,
    onTapActionCallback: () => onEmailActionClick?.call(
      presentationEmail,
      EmailActionType.moveToMailbox,
    ),
    padding: iconPadding,
    margin: iconMargin,
  );

  Widget getMarkStarButton(AppLocalizations applocalizations) => TMailButtonWidget.fromIcon(
    icon: presentationEmail.hasStarred
      ? _imagePaths.icStar
      : _imagePaths.icUnStar,
    iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
    iconColor: presentationEmail.hasStarred
      ? null
      : EmailViewAppBarWidgetStyles.iconColor,
    backgroundColor: Colors.transparent,
    tooltipMessage: presentationEmail.hasStarred
      ? applocalizations.not_starred
      : applocalizations.mark_as_starred,
    onTapActionCallback: () => onEmailActionClick?.call(
      presentationEmail,
      presentationEmail.hasStarred
        ? EmailActionType.unMarkAsStarred
        : EmailActionType.markAsStarred
    ),
    padding: iconPadding,
    margin: iconMargin,
  );

  Widget getDeleteButton(AppLocalizations applocalizations) => TMailButtonWidget.fromIcon(
    icon: _imagePaths.icDeleteComposer,
    iconSize: EmailViewAppBarWidgetStyles.deleteButtonIconSize,
    iconColor: EmailViewAppBarWidgetStyles.iconColor,
    backgroundColor: Colors.transparent,
    tooltipMessage: canDeletePermanently
      ? applocalizations.delete_permanently
      : applocalizations.move_to_trash,
    onTapActionCallback: () {
      if (canDeletePermanently) {
        onEmailActionClick?.call(presentationEmail, EmailActionType.deletePermanently);
      } else {
        onEmailActionClick?.call(presentationEmail, EmailActionType.moveToTrash);
      }
    },
    padding: iconPadding,
    margin: iconMargin,
  );

  Widget getMoreButton(
    AppLocalizations applocalizations,
    bool isScreenWithShortestSide,
  ) => TMailButtonWidget.fromIcon(
    icon: _imagePaths.icMoreVertical,
    iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
    iconColor: EmailViewAppBarWidgetStyles.iconColor,
    backgroundColor: Colors.transparent,
    tooltipMessage: applocalizations.more,
    onTapActionCallback: isScreenWithShortestSide
      ? () => onMoreActionClick?.call(presentationEmail, null)
      : null,
    onTapActionAtPositionCallback: !isScreenWithShortestSide
      ? (position) => onMoreActionClick?.call(presentationEmail, position)
      : null,
    padding: iconPadding,
    margin: iconMargin,
  );

  List<Widget> _buildActionButtons({
    required AppLocalizations appLocalizations,
    required bool isScreenWithShortestSide,
    required bool isResponsiveMobile,
    required bool isResponsiveDesktop,
  }) {
    if (!isInsideThreadDetailView) {
      return [
        getPrintButton(appLocalizations),
        getMoveEmailButton(appLocalizations),
        getMarkStarButton(appLocalizations),
        getDeleteButton(appLocalizations),
        getMoreButton(appLocalizations, isScreenWithShortestSide),
      ];
    }

    return [
      getReplyButton(appLocalizations),
      if (!isResponsiveMobile)
        getMoveEmailButton(appLocalizations),
      if (isResponsiveDesktop) ...[
        getMarkStarButton(appLocalizations),
        getDeleteButton(appLocalizations),
      ],
      getMoreButton(appLocalizations, isScreenWithShortestSide),
    ];
  }
}