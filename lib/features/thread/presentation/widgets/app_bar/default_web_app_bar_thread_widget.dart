
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/app_bar/default_web_app_bar_thread_widget_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DefaultWebAppBarThreadWidget extends StatelessWidget {
  
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final PresentationMailbox? mailboxSelected;
  final FilterMessageOption filterOption;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final OnPopupMenuFilterEmailAction? onPopupMenuFilterEmailAction;
  final OnContextMenuFilterEmailAction? onContextMenuFilterEmailAction;

  const DefaultWebAppBarThreadWidget({
    super.key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.mailboxSelected,
    required this.filterOption,
    required this.openMailboxAction,
    this.onPopupMenuFilterEmailAction,
    this.onContextMenuFilterEmailAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color: DefaultWebAppBarThreadWidgetStyle.backgroundColor,
        padding: DefaultWebAppBarThreadWidgetStyle.getPadding(context, responsiveUtils),
        constraints: const BoxConstraints(minHeight: DefaultWebAppBarThreadWidgetStyle.minHeight),
        child: Row(
          children: [
            TMailButtonWidget.fromIcon(
              key: const Key('mailbox_menu_button'),
              icon: imagePaths.icMenuDrawer,
              backgroundColor: Colors.transparent,
              padding: DefaultWebAppBarThreadWidgetStyle.mailboxMenuPadding,
              maxWidth: DefaultWebAppBarThreadWidgetStyle.buttonMaxWidth,
              tooltipMessage: AppLocalizations.of(context).openFolderMenu,
              onTapActionCallback: openMailboxAction,
            ),
            Expanded(
              child: Padding(
                padding: DefaultWebAppBarThreadWidgetStyle.titlePadding,
                child: Text(
                  mailboxSelected?.getDisplayName(context) ?? '',
                  maxLines: 1,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  style: DefaultWebAppBarThreadWidgetStyle.titleTextStyle
                ),
              ),
            ),
            TMailButtonWidget.fromIcon(
              key: const Key('filter_message_button'),
              icon: imagePaths.icFilter,
              iconColor: DefaultWebAppBarThreadWidgetStyle.getFilterButtonColor(filterOption),
              backgroundColor: Colors.transparent,
              maxWidth: DefaultWebAppBarThreadWidgetStyle.buttonMaxWidth,
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
