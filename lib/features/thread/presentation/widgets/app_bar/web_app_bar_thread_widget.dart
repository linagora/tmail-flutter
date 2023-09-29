
import 'package:flutter/cupertino.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/default_web_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/selection_web_app_bar_thread_widget.dart';

class WebAppBarThreadWidget extends StatelessWidget {

  final PresentationMailbox? mailboxSelected;
  final List<PresentationEmail> listEmailSelected;
  final SelectMode selectMode;
  final FilterMessageOption filterOption;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final OnEditThreadAction editThreadAction;
  final OnCancelEditThreadAction cancelEditThreadAction;
  final OnEmailSelectionAction emailSelectionAction;
  final OnPopupMenuFilterEmailAction? onPopupMenuFilterEmailAction;
  final OnContextMenuFilterEmailAction? onContextMenuFilterEmailAction;

  const WebAppBarThreadWidget({
    super.key,
    required this.listEmailSelected,
    required this.mailboxSelected,
    required this.selectMode,
    required this.filterOption,
    required this.openMailboxAction,
    required this.editThreadAction,
    required this.cancelEditThreadAction,
    required this.emailSelectionAction,
    this.onPopupMenuFilterEmailAction,
    this.onContextMenuFilterEmailAction,
  });

  @override
  Widget build(BuildContext context) {
    if (selectMode == SelectMode.INACTIVE) {
      return DefaultWebAppBarThreadWidget(
        key: const Key('default_web_app_bar_thread_widget'),
        mailboxSelected: mailboxSelected,
        filterOption: filterOption,
        openMailboxAction: openMailboxAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
      );
    } else {
      return SelectionWebAppBarThreadWidget(
        key: const Key('selection_web_app_bar_thread_widget'),
        listEmailSelected: listEmailSelected,
        mailboxSelected: mailboxSelected,
        filterOption: filterOption,
        openMailboxAction: openMailboxAction,
        cancelEditThreadAction: cancelEditThreadAction,
        emailSelectionAction: emailSelectionAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
      );
    }
  }
}
