import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/circle_loading_widget.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

class InsertImageLoadingBarWidget extends StatelessWidget {

  final Either<Failure, Success> viewState;
  final Either<Failure, Success> uploadInlineViewState;
  final EdgeInsetsGeometry? padding;

  const InsertImageLoadingBarWidget({
    super.key,
    required this.viewState,
    required this.uploadInlineViewState,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return uploadInlineViewState.fold(
      (failure) => _viewStateToUI(viewState),
      (success) {
        if (success is UploadingAttachmentUploadState) {
          return CircleLoadingWidget(padding: padding);
        } else {
          return _viewStateToUI(viewState);
        }
      }
    );
  }

  Widget _viewStateToUI(Either<Failure, Success> viewState) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is DownloadingImageAsBase64) {
          return CircleLoadingWidget(padding: padding);
        } else {
          return const SizedBox.shrink();
        }
      }
    );
  }
}
