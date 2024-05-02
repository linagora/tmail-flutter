
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_starred_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_unread_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_email_searched_to_folder_state.dart';

class PerformActionSearchSelectionEmailLoadingWidget extends StatelessWidget with AppLoaderMixin {

  final Either<Failure, Success> viewState;

  const PerformActionSearchSelectionEmailLoadingWidget({super.key, required this.viewState});

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is MarkAllSearchAsReadLoading
            || success is MarkAllSearchAsUnreadLoading
            || success is MarkAllSearchAsStarredLoading
            || success is MoveAllEmailSearchedToFolderLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: horizontalLoadingWidget
          );
        }
        return const SizedBox.shrink();
      }
    );
  }
}
