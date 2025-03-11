import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

class InsertImageLoadingBarWidget extends StatelessWidget {

  final Either<Failure, Success> viewState;
  final Either<Failure, Success> uploadInlineViewState;
  final EdgeInsetsGeometry? margin;

  const InsertImageLoadingBarWidget({
    super.key,
    required this.viewState,
    required this.uploadInlineViewState,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final child = uploadInlineViewState.fold(
      (failure) => _viewStateToUI(viewState),
      (success) {
        if (success is UploadingAttachmentUploadState) {
          return const LinearProgressIndicator(
            color: AppColor.primaryColor,
            backgroundColor: AppColor.colorBgMailboxSelected,
          );
        } else {
          return _viewStateToUI(viewState);
        }
      }
    );

    return Container(
      height: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  Widget _viewStateToUI(Either<Failure, Success> viewState) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is DownloadingImageAsBase64) {
          return const LinearProgressIndicator(
            color: AppColor.primaryColor,
            backgroundColor: AppColor.colorBgMailboxSelected,
          );
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}
