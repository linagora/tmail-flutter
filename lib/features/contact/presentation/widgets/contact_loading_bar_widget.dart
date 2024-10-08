
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';

class ContactLoadingBarWidget extends StatelessWidget {

  final Either<Failure, Success> viewState;

  const ContactLoadingBarWidget({super.key, required this.viewState});

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is SearchingState) {
          return const CupertinoLoadingWidget(
            padding: EdgeInsets.symmetric(vertical: 12)
          );
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}