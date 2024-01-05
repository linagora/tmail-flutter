
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:model/user/user_profile.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/web_app_bar_thread_widget.dart';

typedef OnPopupMenuFilterEmailAction = void Function(FilterMessageOption, RelativeRect);
typedef OnContextMenuFilterEmailAction = void Function(FilterMessageOption);
typedef OnEditThreadAction = void Function();
typedef OnOpenMailboxMenuActionClick = void Function();
typedef OnCancelEditThreadAction = void Function();
typedef OnEmailSelectionAction = void Function(EmailActionType, List<PresentationEmail>);

class AppBarThreadWidget extends StatelessWidget {
  final OnPopupMenuFilterEmailAction? onPopupMenuFilterEmailAction;
  final OnContextMenuFilterEmailAction? onContextMenuFilterEmailAction;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final OnEditThreadAction editThreadAction;
  final OnCancelEditThreadAction cancelEditThreadAction;
  final OnEmailSelectionAction emailSelectionAction;
  final PresentationMailbox? mailboxSelected;
  final List<PresentationEmail> listEmailSelected;
  final SelectMode selectMode;
  final FilterMessageOption filterOption;
  final UserProfile? userProfile;

  const AppBarThreadWidget({
    Key? key,
    required this.mailboxSelected,
    required this.listEmailSelected,
    required this.selectMode,
    required this.filterOption,
    required this.openMailboxAction,
    required this.editThreadAction,
    required this.cancelEditThreadAction,
    required this.emailSelectionAction,
    required this.userProfile,
    this.onPopupMenuFilterEmailAction,
    this.onContextMenuFilterEmailAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return WebAppBarThreadWidget(
        key: const Key('web_app_bar_thread_widget'),
        listEmailSelected: listEmailSelected,
        mailboxSelected: mailboxSelected,
        selectMode: selectMode,
        filterOption: filterOption,
        openMailboxAction: openMailboxAction,
        editThreadAction: editThreadAction,
        cancelEditThreadAction: cancelEditThreadAction,
        emailSelectionAction: emailSelectionAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
      );
    } else {
      return MobileAppBarThreadWidget(
        key: const Key('mobile_app_bar_thread_widget'),
        listEmailSelected: listEmailSelected,
        mailboxSelected: mailboxSelected,
        userProfile: userProfile,
        selectMode: selectMode,
        filterOption: filterOption,
        openMailboxAction: openMailboxAction,
        editThreadAction: editThreadAction,
        cancelEditThreadAction: cancelEditThreadAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
      );
    }
  }
}