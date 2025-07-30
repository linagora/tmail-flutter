import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/circle_loading_widget.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';

class IdentityLoadingWidget extends StatelessWidget {

  final Either<Failure, Success> identityViewState;

  const IdentityLoadingWidget({
    super.key,
    required this.identityViewState,
  });

  @override
  Widget build(BuildContext context) {
    return identityViewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is GetAllIdentitiesLoading) {
          return const Center(
            child: CircleLoadingWidget(margin: EdgeInsets.all(16.0)),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}