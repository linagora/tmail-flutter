
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

mixin ComposerLoadingMixin {

  Widget _loadingWidgetWithSizeColor({double? size, Color? color}) {
    return Center(child: Container(
        margin: const EdgeInsets.all(10),
        width: size ?? 24,
        height: size ?? 24,
        child: CircularProgressIndicator(color: color ?? AppColor.primaryColor)));
  }

  Widget buildInlineLoadingView(ComposerController controller) {
    return Obx(() => controller.uploadController.uploadInlineViewState.value.fold(
        (failure) {
          return controller.viewState.value.fold(
            (failure) => const SizedBox.shrink(),
            (success) {
              if (success is DownloadingImageAsBase64) {
                return _loadingWidgetWithSizeColor();
              }
              return const SizedBox.shrink();
            });
        },
        (success) {
          if (success is UploadingAttachmentUploadState) {
            return _loadingWidgetWithSizeColor();
          }
          return controller.viewState.value.fold(
            (failure) => const SizedBox.shrink(),
            (success) {
              if (success is DownloadingImageAsBase64) {
                return _loadingWidgetWithSizeColor();
              }
              return const SizedBox.shrink();
            });
        }));
  }
}