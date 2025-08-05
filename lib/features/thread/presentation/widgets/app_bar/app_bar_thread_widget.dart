import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/web_app_bar_thread_widget.dart';

typedef OnPopupMenuFilterEmailAction = void Function(
  FilterMessageOption option,
  RelativeRect position,
);
typedef OnContextMenuFilterEmailAction = void Function(
  FilterMessageOption option,
);
typedef OnOpenMailboxMenuActionClick = void Function();
typedef OnCancelSelectionAction = void Function();
typedef OnEmailSelectionAction = void Function(
  EmailActionType type,
  List<PresentationEmail> emails,
);
typedef OnPressEmailSelectionActionClick = void Function(
  EmailSelectionActionType type,
  List<PresentationEmail> emails,
);

class AppBarThreadWidget extends StatelessWidget {
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final OnPopupMenuFilterEmailAction? onPopupMenuFilterEmailAction;
  final OnContextMenuFilterEmailAction? onContextMenuFilterEmailAction;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final OnCancelSelectionAction onCancelSelectionAction;
  final OnEmailSelectionAction emailSelectionAction;
  final PresentationMailbox? mailboxSelected;
  final List<PresentationEmail> listEmailSelected;
  final SelectMode selectMode;
  final FilterMessageOption filterOption;
  final OnPressEmailSelectionActionClick? onPressEmailSelectionActionClick;

  const AppBarThreadWidget({
    Key? key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.mailboxSelected,
    required this.listEmailSelected,
    required this.selectMode,
    required this.filterOption,
    required this.openMailboxAction,
    required this.onCancelSelectionAction,
    required this.emailSelectionAction,
    this.onPopupMenuFilterEmailAction,
    this.onContextMenuFilterEmailAction,
    this.onPressEmailSelectionActionClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return WebAppBarThreadWidget(
        key: const Key('web_app_bar_thread_widget'),
        imagePaths: imagePaths,
        responsiveUtils: responsiveUtils,
        listEmailSelected: listEmailSelected,
        mailboxSelected: mailboxSelected,
        selectMode: selectMode,
        filterOption: filterOption,
        openMailboxAction: openMailboxAction,
        onCancelSelectionAction: onCancelSelectionAction,
        emailSelectionAction: emailSelectionAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
      );
    } else {
      return MobileAppBarThreadWidget(
        key: const Key('mobile_app_bar_thread_widget'),
        imagePaths: imagePaths,
        responsiveUtils: responsiveUtils,
        listEmailSelected: listEmailSelected,
        mailboxSelected: mailboxSelected,
        selectMode: selectMode,
        filterOption: filterOption,
        openMailboxAction: openMailboxAction,
        onCancelSelectionAction: onCancelSelectionAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
        onPressEmailSelectionActionClick: onPressEmailSelectionActionClick,
      );
    }
  }
}
