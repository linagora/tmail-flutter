import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/state/clean_and_get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';

class ThreadViewLoadingBarWidget extends StatelessWidget {

  final Either<Failure, Success> viewState;

  const ThreadViewLoadingBarWidget({
    super.key,
    required this.viewState,
  });

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is SearchingState ||
            success is GetAllEmailLoading ||
            success is CleanAndGetAllEmailLoading) {
          return const Padding(
            padding: EdgeInsetsDirectional.only(top: 16),
            child: CupertinoLoadingWidget(
              semanticLabel: 'Mail list loading icon',
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}
