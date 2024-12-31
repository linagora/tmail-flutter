import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/mark_mailbox_as_read_loading_banner_style.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';

class MarkMailboxAsReadLoadingBanner extends StatelessWidget with AppLoaderMixin {
  final Either<Failure, Success> viewState;

  const MarkMailboxAsReadLoadingBanner({
    super.key,
    required this.viewState,
  });

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is MarkAsMailboxReadLoading) {
          return Padding(
            padding: MarkMailboxAsReadLoadingBannerStyle.bannerMargin,
            child: horizontalLoadingWidget);
        } else if (success is UpdatingMarkAsMailboxReadState) {
          return _buildProgressBanner(success.countRead, success.totalUnread);
        } else if (success is EmptyingFolderState) {
          return _buildProgressBanner(success.countEmailsDeleted, success.totalEmails);
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }

  Padding _buildProgressBanner(int progress, int total) {
    final percent = total > 0 ? progress / total : 0.68;
    return Padding(
      padding: MarkMailboxAsReadLoadingBannerStyle.bannerMargin,
      child: horizontalPercentLoadingWidget(percent)
    );
  }
}