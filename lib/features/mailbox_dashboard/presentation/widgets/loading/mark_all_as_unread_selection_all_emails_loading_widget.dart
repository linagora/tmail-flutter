
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_unread_selection_all_emails_state.dart';

class MarkAllAsUnreadSelectionAllEmailsLoadingWidget extends StatelessWidget with AppLoaderMixin {

  final Either<Failure, Success> viewState;

  const MarkAllAsUnreadSelectionAllEmailsLoadingWidget({super.key, required this.viewState});

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is MarkAllAsUnreadSelectionAllEmailsLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: horizontalLoadingWidget
          );
        } else if (success is MarkAllAsUnreadSelectionAllEmailsUpdating) {
          final percent = success.countUnread / success.totalRead;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: horizontalPercentLoadingWidget(percent)
          );
        }
        return const SizedBox.shrink();
      }
    );
  }
}
