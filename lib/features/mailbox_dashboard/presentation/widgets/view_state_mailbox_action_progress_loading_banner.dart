import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/mark_mailbox_as_read_loading_banner_style.dart';
import 'package:tmail_ui_user/features/thread/domain/state/delete_all_permanently_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_starred_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_unread_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_starred_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_unread_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_email_searched_to_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';

class ViewStateMailboxActionProgressLoadingBanner extends StatelessWidget with AppLoaderMixin {
  final Either<Failure, Success> viewState;
  final ResponsiveUtils responsiveUtils;

  const ViewStateMailboxActionProgressLoadingBanner({
    super.key,
    required this.viewState,
    required this.responsiveUtils,
  });

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is MarkAsMailboxReadLoading
            || success is EmptySpamFolderLoading
            || success is EmptyTrashFolderLoading
            || success is MarkAllAsUnreadSelectionAllEmailsLoading
            || success is MarkAllAsStarredSelectionAllEmailsLoading
            || success is MoveAllSelectionAllEmailsLoading
            || success is DeleteAllPermanentlyEmailsLoading
            || success is MarkAllSearchAsReadLoading
            || success is MarkAllSearchAsUnreadLoading
            || success is MarkAllSearchAsStarredLoading
            || success is MoveAllEmailSearchedToFolderLoading
        ) {
          return Padding(
            padding: MarkMailboxAsReadLoadingBannerStyle.getBannerMargin(context, responsiveUtils),
            child: horizontalLoadingWidget);
        } else if (success is UpdatingMarkAsMailboxReadState) {
          return _buildProgressBanner(context, success.countRead, success.totalUnread);
        } else if (success is MarkAllAsUnreadSelectionAllEmailsUpdating) {
          return _buildProgressBanner(context, success.countUnread, success.totalRead);
        } else if (success is MarkAllAsStarredSelectionAllEmailsUpdating) {
          return _buildProgressBanner(context, success.countStarred, success.total);
        } else if (success is MoveAllSelectionAllEmailsUpdating) {
          return _buildProgressBanner(context, success.countMoved, success.total);
        } else if (success is DeleteAllPermanentlyEmailsUpdating) {
          return _buildProgressBanner(context, success.countDeleted, success.total);
        } else if (success is EmptyingFolderState) {
          return _buildProgressBanner(context, success.countEmailsDeleted, success.totalEmails);
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }

  Padding _buildProgressBanner(BuildContext context, int progress, int total) {
    final percent = total > 0 ? progress / total : 0.68;
    return Padding(
      padding: MarkMailboxAsReadLoadingBannerStyle.getBannerMargin(context, responsiveUtils),
      child: horizontalPercentLoadingWidget(percent)
    );
  }
}