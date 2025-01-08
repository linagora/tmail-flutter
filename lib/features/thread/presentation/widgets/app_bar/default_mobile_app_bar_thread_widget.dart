
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/app_bar/mobile_app_bar_thread_widget_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DefaultMobileAppBarThreadWidget extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final PresentationMailbox? mailboxSelected;
  final List<PresentationEmail> listEmailSelected;
  final SelectMode selectMode;
  final FilterMessageOption filterOption;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final OnPopupMenuFilterEmailAction? onPopupMenuFilterEmailAction;
  final OnContextMenuFilterEmailAction? onContextMenuFilterEmailAction;
  final OnCancelEditThreadAction cancelEditThreadAction;

  const DefaultMobileAppBarThreadWidget({
    super.key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.listEmailSelected,
    required this.mailboxSelected,
    required this.selectMode,
    required this.filterOption,
    required this.openMailboxAction,
    required this.cancelEditThreadAction,
    this.onPopupMenuFilterEmailAction,
    this.onContextMenuFilterEmailAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color: MobileAppBarThreadWidgetStyle.backgroundColor,
        padding: MobileAppBarThreadWidgetStyle.getPadding(context, responsiveUtils),
        constraints: const BoxConstraints(minHeight: MobileAppBarThreadWidgetStyle.minHeight),
        child: Row(
          children: [
            TMailButtonWidget.fromIcon(
              key: const Key('mobile_mailbox_menu_button'),
              icon: imagePaths.icMenuDrawer,
              backgroundColor: Colors.transparent,
              padding: MobileAppBarThreadWidgetStyle.mailboxMenuPadding,
              maxWidth: MobileAppBarThreadWidgetStyle.buttonMaxWidth,
              tooltipMessage: AppLocalizations.of(context).openFolderMenu,
              onTapActionCallback: openMailboxAction,
            ),
            Expanded(
              child: Padding(
                padding: MobileAppBarThreadWidgetStyle.titlePadding,
                child: Text(
                  mailboxSelected?.getDisplayName(context) ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MobileAppBarThreadWidgetStyle.titleTextStyle
                ),
              ),
            ),
            TMailButtonWidget.fromIcon(
              key: const Key('mobile_filter_message_button'),
              icon: imagePaths.icFilter,
              iconColor: MobileAppBarThreadWidgetStyle.getFilterButtonColor(filterOption),
              backgroundColor: Colors.transparent,
              maxWidth: MobileAppBarThreadWidgetStyle.buttonMaxWidth,
              tooltipMessage: AppLocalizations.of(context).filter_messages,
              onTapActionCallback: () => onContextMenuFilterEmailAction?.call(filterOption),
              onTapActionAtPositionCallback: (position) => onPopupMenuFilterEmailAction?.call(filterOption, position),
            ),
          ]
        ),
      );
    });
  }
}
