
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';

class MoveAllSelectionAllEmailsLoadingWidget extends StatelessWidget with AppLoaderMixin {

  final Either<Failure, Success> viewState;

  const MoveAllSelectionAllEmailsLoadingWidget({super.key, required this.viewState});

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is MoveAllSelectionAllEmailsLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: horizontalLoadingWidget
          );
        } else if (success is MoveAllSelectionAllEmailsUpdating) {
          final percent = success.total > 0
            ? success.countMoved / success.total
            : 0.0;
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
