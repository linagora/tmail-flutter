import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_loading_bar_widget_styles.dart';

class MailboxLoadingBarWidget extends StatelessWidget {

  final Either<Failure, Success> viewState;

  const MailboxLoadingBarWidget({
    super.key,
    required this.viewState,
  });

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is GetAllMailboxLoading) {
          return const Padding(
            padding: MailboxLoadingBarWidgetStyles.padding,
            child: CupertinoLoadingWidget());
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}
