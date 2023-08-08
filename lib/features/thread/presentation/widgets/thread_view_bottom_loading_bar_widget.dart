import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/cupertino_loading_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';

class ThreadViewBottomLoadingBarWidget extends StatelessWidget {

  final Either<Failure, Success> viewState;

  const ThreadViewBottomLoadingBarWidget({
    super.key,
    required this.viewState,
  });

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is SearchingMoreState || success is LoadingMoreEmails) {
          return const Padding(
            padding: EdgeInsetsDirectional.only(bottom: 16),
            child: CupertinoLoadingWidget());
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}
