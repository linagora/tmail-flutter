import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/default_mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/selection_mobile_app_bar_thread_widget.dart';

class MobileAppBarThreadWidget extends StatelessWidget {

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

  const MobileAppBarThreadWidget({
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
    if (selectMode == SelectMode.ACTIVE) {
      return SelectionMobileAppBarThreadWidget(
        key: const Key('selection_mobile_app_bar_thread_widget'),
        imagePaths: imagePaths,
        responsiveUtils: responsiveUtils,
        listEmailSelected: listEmailSelected,
        mailboxSelected: mailboxSelected,
        selectMode: selectMode,
        filterOption: filterOption,
        cancelEditThreadAction: cancelEditThreadAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
      );
    } else {
      return DefaultMobileAppBarThreadWidget(
        key: const Key('default_mobile_app_bar_thread_widget'),
        imagePaths: imagePaths,
        responsiveUtils: responsiveUtils,
        listEmailSelected: listEmailSelected,
        mailboxSelected: mailboxSelected,
        selectMode: selectMode,
        filterOption: filterOption,
        openMailboxAction: openMailboxAction,
        cancelEditThreadAction: cancelEditThreadAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
      );
    }
  }
}
