
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/app_bar/selection_web_app_bar_thread_widget_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SelectionWebAppBarThreadWidget extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final PresentationMailbox? mailboxSelected;
  final List<PresentationEmail> listEmailSelected;
  final FilterMessageOption filterOption;
  final OnOpenMailboxMenuActionClick openMailboxAction;
  final OnCancelEditThreadAction cancelEditThreadAction;
  final OnEmailSelectionAction emailSelectionAction;
  final OnPopupMenuFilterEmailAction? onPopupMenuFilterEmailAction;
  final OnContextMenuFilterEmailAction? onContextMenuFilterEmailAction;

  SelectionWebAppBarThreadWidget({
    super.key,
    required this.listEmailSelected,
    required this.mailboxSelected,
    required this.filterOption,
    required this.openMailboxAction,
    required this.cancelEditThreadAction,
    required this.emailSelectionAction,
    this.onPopupMenuFilterEmailAction,
    this.onContextMenuFilterEmailAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SelectionWebAppBarThreadWidgetStyle.backgroundColor,
      padding: SelectionWebAppBarThreadWidgetStyle.getPadding(context, _responsiveUtils),
      constraints: const BoxConstraints(minHeight: SelectionWebAppBarThreadWidgetStyle.minHeight),
      child: Row(
        children: [
          TMailButtonWidget.fromIcon(
            key: const Key('cancel_selection_button'),
            icon: _imagePaths.icClose,
            backgroundColor: Colors.transparent,
            iconColor: SelectionWebAppBarThreadWidgetStyle.cancelButtonColor,
            iconSize: SelectionWebAppBarThreadWidgetStyle.closeButtonIconSize,
            padding: SelectionWebAppBarThreadWidgetStyle.closeButtonPadding,
            tooltipMessage: AppLocalizations.of(context).cancel,
            onTapActionCallback: cancelEditThreadAction,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context).count_email_selected(listEmailSelected.length),
              maxLines: 1,
              overflow: CommonTextStyle.defaultTextOverFlow,
              softWrap: CommonTextStyle.defaultSoftWrap,
              style: SelectionWebAppBarThreadWidgetStyle.emailCounterStyle
            )
          ),
          if (mailboxSelected?.isDrafts == false)
            TMailButtonWidget.fromIcon(
              key: const Key('mark_as_read_email_selection_button'),
              icon: listEmailSelected.isAllEmailRead
                ? _imagePaths.icUnread
                : _imagePaths.icRead,
              iconSize: SelectionWebAppBarThreadWidgetStyle.mediumIconSize,
              backgroundColor: Colors.transparent,
              tooltipMessage: listEmailSelected.isAllEmailRead
                ? AppLocalizations.of(context).unread
                : AppLocalizations.of(context).read,
              onTapActionCallback: () {
                return emailSelectionAction(
                  listEmailSelected.isAllEmailRead
                    ? EmailActionType.markAsUnread
                    : EmailActionType.markAsRead,
                  listEmailSelected
                );
              },
            ),
          TMailButtonWidget.fromIcon(
            key: const Key('mark_as_star_email_selection_button'),
            icon: listEmailSelected.isAllEmailStarred
              ? _imagePaths.icUnStar
              : _imagePaths.icStar,
            iconSize: SelectionWebAppBarThreadWidgetStyle.mediumIconSize,
            backgroundColor: Colors.transparent,
            tooltipMessage: listEmailSelected.isAllEmailStarred
              ? AppLocalizations.of(context).not_starred
              : AppLocalizations.of(context).starred,
            onTapActionCallback: () {
              return emailSelectionAction(
                listEmailSelected.isAllEmailStarred
                  ? EmailActionType.unMarkAsStarred
                  : EmailActionType.markAsStarred,
                listEmailSelected
              );
            },
          ),
          if (mailboxSelected?.isDrafts == false)
            TMailButtonWidget.fromIcon(
              key: const Key('move_email_selection_button'),
              icon: _imagePaths.icMove,
              iconSize: SelectionWebAppBarThreadWidgetStyle.iconSize,
              backgroundColor: Colors.transparent,
              tooltipMessage: AppLocalizations.of(context).move_message,
              onTapActionCallback: () => emailSelectionAction(EmailActionType.moveToMailbox, listEmailSelected),
            ),
          if (mailboxSelected?.isDrafts == false)
            TMailButtonWidget.fromIcon(
              key: const Key('mark_as_spam_email_selection_button'),
              icon: mailboxSelected?.isSpam == true
                ? _imagePaths.icNotSpam
                : _imagePaths.icSpam,
              iconSize: SelectionWebAppBarThreadWidgetStyle.iconSize,
              backgroundColor: Colors.transparent,
              tooltipMessage: mailboxSelected?.isSpam == true
                ? AppLocalizations.of(context).un_spam
                : AppLocalizations.of(context).mark_as_spam,
              onTapActionCallback: () {
                return mailboxSelected?.isSpam == true
                  ? emailSelectionAction(EmailActionType.unSpam, listEmailSelected)
                  : emailSelectionAction(EmailActionType.moveToSpam, listEmailSelected);
              },
            ),
          TMailButtonWidget.fromIcon(
            key: const Key('delete_email_selection_button'),
            icon: _deletePermanentlyValid
              ? _imagePaths.icDeleteComposer
              : _imagePaths.icDelete,
            iconSize: SelectionWebAppBarThreadWidgetStyle.iconSize,
            iconColor: SelectionWebAppBarThreadWidgetStyle.getDeleteButtonColor(_deletePermanentlyValid),
            backgroundColor: Colors.transparent,
            tooltipMessage: _deletePermanentlyValid
              ? AppLocalizations.of(context).delete_permanently
              : AppLocalizations.of(context).move_to_trash,
            onTapActionCallback: () {
              return _deletePermanentlyValid
                ? emailSelectionAction(EmailActionType.deletePermanently, listEmailSelected)
                : emailSelectionAction(EmailActionType.moveToTrash, listEmailSelected);
            },
          ),
        ]
      ),
    );
  }

  bool get _deletePermanentlyValid => mailboxSelected?.isTrash == true || mailboxSelected?.isDrafts == true || mailboxSelected?.isSpam == true;
}
