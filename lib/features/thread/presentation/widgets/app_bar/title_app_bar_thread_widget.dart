
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/app_bar/title_app_bar_thread_widget_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';

class TitleAppBarThreadWidget extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();

  final PresentationMailbox? mailboxSelected;
  final FilterMessageOption filterOption;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final double maxWidth;

  TitleAppBarThreadWidget({
    super.key,
    required this.mailboxSelected,
    required this.filterOption,
    required this.maxWidth,
    required this.openMailboxAction,
  });

  @override
  Widget build(BuildContext context) {
    if (filterOption == FilterMessageOption.all) {
      if (mailboxSelected != null) {
        return TMailButtonWidget(
          text: mailboxSelected!.getDisplayName(context),
          icon: _imagePaths.icChevronDown,
          textStyle: TitleAppBarThreadWidgetStyle.titleStyle,
          backgroundColor: Colors.transparent,
          iconAlignment: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          padding: TitleAppBarThreadWidgetStyle.padding,
          maxWidth: maxWidth,
          flexibleText: true,
          maxLines: 1,
          tooltipMessage: mailboxSelected!.getDisplayName(context),
          onTapActionCallback: openMailboxAction,
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return Column(
        children: [
          if (mailboxSelected != null)
            TMailButtonWidget(
              text: mailboxSelected!.getDisplayName(context),
              icon: _imagePaths.icChevronDown,
              textStyle: TitleAppBarThreadWidgetStyle.titleStyle,
              backgroundColor: Colors.transparent,
              iconAlignment: TextDirection.rtl,
              mainAxisSize: MainAxisSize.min,
              padding: TitleAppBarThreadWidgetStyle.padding,
              maxWidth: maxWidth,
              flexibleText: true,
              maxLines: 1,
              tooltipMessage: mailboxSelected!.getDisplayName(context),
              onTapActionCallback: openMailboxAction,
            ),
          Text(
            filterOption.getTitle(context),
            style: TitleAppBarThreadWidgetStyle.filterOptionStyle
          )
        ],
      );
    }
  }
}
