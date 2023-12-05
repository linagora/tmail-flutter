
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/app_bar/mobile_app_bar_thread_widget_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/title_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MobileAppBarThreadWidget extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final PresentationMailbox? mailboxSelected;
  final List<PresentationEmail> listEmailSelected;
  final SelectMode selectMode;
  final FilterMessageOption filterOption;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final OnEditThreadAction editThreadAction;
  final OnPopupMenuFilterEmailAction? onPopupMenuFilterEmailAction;
  final OnContextMenuFilterEmailAction? onContextMenuFilterEmailAction;
  final OnCancelEditThreadAction cancelEditThreadAction;

  MobileAppBarThreadWidget({
    super.key,
    required this.listEmailSelected,
    required this.mailboxSelected,
    required this.selectMode,
    required this.filterOption,
    required this.openMailboxAction,
    required this.editThreadAction,
    required this.cancelEditThreadAction,
    this.onPopupMenuFilterEmailAction,
    this.onContextMenuFilterEmailAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color: MobileAppBarThreadWidgetStyle.backgroundColor,
        padding: MobileAppBarThreadWidgetStyle.getPadding(context, _responsiveUtils),
        constraints: const BoxConstraints(minHeight: MobileAppBarThreadWidgetStyle.minHeight),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            if (selectMode == SelectMode.INACTIVE)
              PositionedDirectional(
                start: 0,
                child: TMailButtonWidget.fromText(
                  key: const Key('selection_thread_button'),
                  text: AppLocalizations.of(context).edit,
                  textStyle: MobileAppBarThreadWidgetStyle.editButtonStyle,
                  backgroundColor: Colors.transparent,
                  maxWidth: MobileAppBarThreadWidgetStyle.buttonMaxWidth,
                  maxLines: 1,
                  tooltipMessage: AppLocalizations.of(context).edit,
                  onTapActionCallback: editThreadAction,
                ),
              )
            else
              PositionedDirectional(
                start: 0,
                child: TMailButtonWidget(
                  key: const Key('cancel_selection_thread_button'),
                  text: '${listEmailSelected.length}',
                  icon: _imagePaths.icBack,
                  iconColor: MobileAppBarThreadWidgetStyle.backButtonColor,
                  textStyle: MobileAppBarThreadWidgetStyle.emailCounterTitleStyle,
                  backgroundColor: Colors.transparent,
                  onTapActionCallback: cancelEditThreadAction,
                ),
              ),
            Center(
              child: TitleAppBarThreadWidget(
                key: const Key('title_app_bar_thread'),
                mailboxSelected: mailboxSelected,
                filterOption: filterOption,
                maxWidth: constraints.maxWidth - MobileAppBarThreadWidgetStyle.titleOffset,
                openMailboxAction: openMailboxAction,
              ),
            ),
            PositionedDirectional(
              end: 0,
              child: TMailButtonWidget.fromIcon(
                key: const Key('filter_message_button'),
                icon: _imagePaths.icFilter,
                iconColor: MobileAppBarThreadWidgetStyle.getFilterButtonColor(filterOption),
                backgroundColor: Colors.transparent,
                maxWidth: MobileAppBarThreadWidgetStyle.buttonMaxWidth,
                tooltipMessage: AppLocalizations.of(context).filter_messages,
                onTapActionCallback: () => onContextMenuFilterEmailAction?.call(filterOption),
                onTapActionAtPositionCallback: (position) => onPopupMenuFilterEmailAction?.call(filterOption, position),
              ),
            ),
          ]
        ),
      );
    });
  }
}
