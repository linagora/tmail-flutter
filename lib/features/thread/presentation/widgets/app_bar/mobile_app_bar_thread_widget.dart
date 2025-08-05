import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/default_mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/selection_mobile_app_bar_thread_widget.dart';

typedef OnPopupMenuFilterEmailAction = void Function(
  FilterMessageOption option,
  RelativeRect position,
);
typedef OnContextMenuFilterEmailAction = void Function(
  FilterMessageOption option,
);
typedef OnOpenMailboxMenuActionClick = void Function();
typedef OnCancelSelectionAction = void Function();
typedef OnPressEmailSelectionActionClick = void Function(
  EmailSelectionActionType type,
  List<PresentationEmail> emails,
);

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
  final OnCancelSelectionAction onCancelSelectionAction;
  final OnPressEmailSelectionActionClick? onPressEmailSelectionActionClick;

  const MobileAppBarThreadWidget({
    super.key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.listEmailSelected,
    required this.mailboxSelected,
    required this.selectMode,
    required this.filterOption,
    required this.openMailboxAction,
    required this.onCancelSelectionAction,
    this.onPopupMenuFilterEmailAction,
    this.onContextMenuFilterEmailAction,
    this.onPressEmailSelectionActionClick,
  });

  @override
  Widget build(BuildContext context) {
    if (selectMode == SelectMode.ACTIVE) {
      final actionTypes = <EmailSelectionActionType>[
        EmailSelectionActionType.selectAll,
        if (mailboxSelected?.isArchive != true)
          EmailSelectionActionType.archiveMessage,
        if (mailboxSelected?.isDeletePermanentlyEnabled == true)
          EmailSelectionActionType.deletePermanently
        else
          EmailSelectionActionType.moveToTrash,
        if (listEmailSelected.isAllEmailRead)
          EmailSelectionActionType.markAsUnread
        else
          EmailSelectionActionType.markAsRead,
        EmailSelectionActionType.moreAction,
      ];

      return SelectionMobileAppBarThreadWidget(
        imagePaths: imagePaths,
        responsiveUtils: responsiveUtils,
        selectedEmails: listEmailSelected,
        onCancelSelectionAction: onCancelSelectionAction,
        emailSelectionActionTypes: actionTypes,
        onPressEmailSelectionActionClick: (type, emails) =>
            onPressEmailSelectionActionClick?.call(type, emails),
      );
    } else {
      return DefaultMobileAppBarThreadWidget(
        imagePaths: imagePaths,
        responsiveUtils: responsiveUtils,
        mailboxSelected: mailboxSelected,
        filterOption: filterOption,
        openMailboxAction: openMailboxAction,
        onPopupMenuFilterEmailAction: onPopupMenuFilterEmailAction,
        onContextMenuFilterEmailAction: onContextMenuFilterEmailAction,
      );
    }
  }
}
