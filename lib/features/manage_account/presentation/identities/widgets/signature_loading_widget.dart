import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/transform_list_signature_state.dart';

class SignatureLoadingWidget extends StatelessWidget {

  final Either<Failure, Success> signatureViewState;

  const SignatureLoadingWidget({
    super.key,
    required this.signatureViewState,
  });

  @override
  Widget build(BuildContext context) {
    return signatureViewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is TransformListSignatureLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CupertinoActivityIndicator(color: AppColor.colorLoading),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}