import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/drive_oversize_upload_dialog_view.dart';

/// Web gets the centred `Dialog`, mobile the bottom sheet, matching the two
/// Figma frames.
class DriveOversizeUploadDialogPresenter {
  const DriveOversizeUploadDialogPresenter._();

  /// Opens the batch dialog. Modal, opaque barrier, no dismiss — this is what
  /// blocks every user input for the Drive path. Chips are untouched.
  static void show(ProviderContainer container) {
    final isWebLayout = PlatformInfo.isWeb;
    final body = PointerInterceptor(
      child: UncontrolledProviderScope(
        container: container,
        child: DriveOversizeUploadDialogView(
          imagePaths: ImagePaths(),
          isWebLayout: isWebLayout,
        ),
      ),
    );

    Get.dialog(
      PopScope(
        canPop: false,
        child: LinagoraFileTransferSurface(
          layout: isWebLayout
              ? LinagoraFileTransferLayout.wide
              : LinagoraFileTransferLayout.compact,
          semanticLabel: Get.context == null
              ? null
              : AppLocalizations.of(Get.context!).attachingFileTitle,
          child: body,
        ),
      ),
      barrierDismissible: false,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  /// Safe to call when nothing is open — `Get.isDialogOpen` guards a double pop.
  static void close() {
    if (Get.isDialogOpen == true) Get.back();
  }
}
