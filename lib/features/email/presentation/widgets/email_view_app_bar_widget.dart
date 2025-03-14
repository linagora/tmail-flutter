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
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEmailActionClick = void Function(PresentationEmail, EmailActionType);
typedef OnMoreActionClick = void Function(PresentationEmail, RelativeRect?);

class EmailViewAppBarWidget extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _singleEmailController = Get.find<SingleEmailController>();

  final PresentationEmail presentationEmail;
  final List<Widget>? optionsWidget;
  final PresentationMailbox? mailboxContain;
  final bool isSearchActivated;
  final VoidCallback onBackAction;
  final OnEmailActionClick? onEmailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  EmailViewAppBarWidget({
    Key? key,
    required this.presentationEmail,
    required this.onBackAction,
    required this.isSearchActivated,
    this.mailboxContain,
    this.onEmailActionClick,
    this.onMoreActionClick,
    this.optionsWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: PlatformInfo.isIOS
          ? EmailViewAppBarWidgetStyles.heightIOS(context, _responsiveUtils)
          : EmailViewAppBarWidgetStyles.height,
        padding: PlatformInfo.isIOS
          ? EmailViewAppBarWidgetStyles.paddingIOS(context, _responsiveUtils)
          : EmailViewAppBarWidgetStyles.padding,
        decoration: const BoxDecoration(
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
          if (_supportDisplayMailboxNameTitle(context))
            EmailViewBackButton(
              onBackAction: onBackAction,
              mailboxContain: mailboxContain,
              isSearchActivated: isSearchActivated,
              maxWidth: constraints.maxWidth,
            ),
          const Spacer(),
          Row(
            children: [
                const SizedBox(width: EmailViewAppBarWidgetStyles.space),
                TMailButtonWidget.fromIcon(
                  icon: _imagePaths.icMoveEmail,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  tooltipMessage: AppLocalizations.of(context).move_message,
                  backgroundColor: Colors.transparent,
                  padding: EmailViewAppBarWidgetStyles.buttonPadding,
                  onTapActionCallback: () => onEmailActionClick?.call(presentationEmail, EmailActionType.moveToMailbox)
                ),
                const SizedBox(width: EmailViewAppBarWidgetStyles.space),
                TMailButtonWidget.fromIcon(
                  icon: presentationEmail.hasStarred
                    ? _imagePaths.icStar
                    : _imagePaths.icUnStar,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  backgroundColor: Colors.transparent,
                  padding: EmailViewAppBarWidgetStyles.buttonPadding,
                  tooltipMessage: presentationEmail.hasStarred
                    ? AppLocalizations.of(context).not_starred
                    : AppLocalizations.of(context).mark_as_starred,
                  onTapActionCallback: () => onEmailActionClick?.call(
                    presentationEmail,
                    presentationEmail.hasStarred ? EmailActionType.unMarkAsStarred : EmailActionType.markAsStarred
                  )
                ),
                Obx(() {
                  if (_singleEmailController.currentEmailLoaded.value != null
                    && PlatformInfo.isWeb
                    && PlatformInfo.isCanvasKit
                  ) {
                    return TMailButtonWidget.fromIcon(
                      icon: _imagePaths.icPrinter,
                      margin: const EdgeInsetsDirectional.only(start: EmailViewAppBarWidgetStyles.space),
                      iconSize: EmailViewAppBarWidgetStyles.deleteButtonIconSize,
                      backgroundColor: Colors.transparent,
                      padding: EmailViewAppBarWidgetStyles.buttonPadding,
                      tooltipMessage: AppLocalizations.of(context).printAll,
                      onTapActionCallback: () => onEmailActionClick?.call(
                        presentationEmail,
                        EmailActionType.printAll
                      )
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
                const SizedBox(width: EmailViewAppBarWidgetStyles.space),
                TMailButtonWidget.fromIcon(
                  icon: _imagePaths.icDeleteComposer,
                  iconSize: EmailViewAppBarWidgetStyles.deleteButtonIconSize,
                  backgroundColor: Colors.transparent,
                  padding: EmailViewAppBarWidgetStyles.buttonPadding,
                  iconColor: canDeletePermanently
                    ? EmailViewAppBarWidgetStyles.deletePermanentButtonColor
                    : EmailViewAppBarWidgetStyles.emptyTrashButtonColor,
                  tooltipMessage: canDeletePermanently
                    ? AppLocalizations.of(context).delete_permanently
                    : AppLocalizations.of(context).move_to_trash,
                  onTapActionCallback: () {
                    if (canDeletePermanently) {
                      onEmailActionClick?.call(presentationEmail, EmailActionType.deletePermanently);
                    } else {
                      onEmailActionClick?.call(presentationEmail, EmailActionType.moveToTrash);
                    }
                  }
                ),
                const SizedBox(width: EmailViewAppBarWidgetStyles.space),
                TMailButtonWidget.fromIcon(
                  icon: _imagePaths.icMore,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  backgroundColor: Colors.transparent,
                  padding: EmailViewAppBarWidgetStyles.buttonPadding,
                  tooltipMessage: AppLocalizations.of(context).more,
                  onTapActionCallback: _responsiveUtils.isScreenWithShortestSide(context)
                    ? () => onMoreActionClick?.call(presentationEmail, null)
                    : null,
                  onTapActionAtPositionCallback: !_responsiveUtils.isScreenWithShortestSide(context)
                    ? (position) => onMoreActionClick?.call(presentationEmail, position)
                    : null
                ),
                if(optionsWidget != null)
                  ...optionsWidget!,
                const SizedBox(width: EmailViewAppBarWidgetStyles.space),
              ]
          ),
        ])
      );
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        onBackAction();
        return;
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
}