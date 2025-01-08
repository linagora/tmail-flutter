
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/app_bar/mobile_app_bar_thread_widget_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SelectionMobileAppBarThreadWidget extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final PresentationMailbox? mailboxSelected;
  final List<PresentationEmail> listEmailSelected;
  final SelectMode selectMode;
  final FilterMessageOption filterOption;
  final OnPopupMenuFilterEmailAction? onPopupMenuFilterEmailAction;
  final OnContextMenuFilterEmailAction? onContextMenuFilterEmailAction;
  final OnCancelEditThreadAction cancelEditThreadAction;

  const SelectionMobileAppBarThreadWidget({
    super.key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.listEmailSelected,
    required this.mailboxSelected,
    required this.selectMode,
    required this.filterOption,
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
            TMailButtonWidget(
              key: const Key('mobile_cancel_selection_thread_button'),
              text: AppLocalizations.of(context).count_email_selected(listEmailSelected.length),
              icon: imagePaths.icCancel,
              iconColor: MobileAppBarThreadWidgetStyle.backButtonColor,
              textStyle: MobileAppBarThreadWidgetStyle.emailCounterTitleStyle,
              backgroundColor: Colors.transparent,
              onTapActionCallback: cancelEditThreadAction,
            ),
            const Spacer(),
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
