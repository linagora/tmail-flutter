import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/synchronize_latest_session_state.dart';

class SynchronizingSessionBar extends StatelessWidget {

  final Either<Failure, Success> viewState;

  const SynchronizingSessionBar({super.key, required this.viewState});

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is SynchronizingLatestSession) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            margin: const EdgeInsetsDirectional.only(bottom: 8),
            child: Center(
              child: LinearProgressIndicator(
                color: AppColor.primaryColor.withOpacity(0.5),
                minHeight: 2,
                backgroundColor: AppColor.primaryColor.withOpacity(0.3)
              ),
            )
          );
        }
        return const SizedBox.shrink();
      });
  }
}
