import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/mark_mailbox_as_read_loading_banner_style.dart';

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
          final percent = success.countRead / success.totalUnread;
          return Padding(
            padding: MarkMailboxAsReadLoadingBannerStyle.bannerMargin,
            child: horizontalPercentLoadingWidget(percent));
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}