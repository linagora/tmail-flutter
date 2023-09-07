import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/cupertino_loading_widget.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';

class EmailViewLoadingBarWidget extends StatelessWidget {

  final Either<Failure, Success> viewState;

  const EmailViewLoadingBarWidget({
    super.key,
    required this.viewState,
  });

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is GetEmailContentLoading || success is ParseCalendarEventLoading) {
          return const CupertinoLoadingWidget();
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}
