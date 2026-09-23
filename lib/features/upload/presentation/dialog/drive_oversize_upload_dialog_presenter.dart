import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/drive_oversize_upload_dialog_view.dart';
import 'package:tmail_ui_user/features/upload/presentation/styles/drive_oversize_upload_dialog_style.dart';

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
        child: isWebLayout ? _webSurface(body) : _mobileSurface(body),
      ),
      barrierDismissible: false,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  static Widget _webSurface(Widget body) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        alignment: Alignment.center,
        child: Builder(
          builder: (context) => Container(
            width: min(context.width, DriveOversizeUploadDialogStyle.webMaxWidth),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                DriveOversizeUploadDialogStyle.webSurfaceRadius),
              boxShadow: DriveOversizeUploadDialogStyle.surfaceShadow,
            ),
            child: body,
          ),
        ),
      );

  /// A bottom sheet, not a centred card — mobile frame 12004-18682.
  static Widget _mobileSurface(Widget body) => Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  DriveOversizeUploadDialogStyle.mobileSurfaceRadius)),
              boxShadow: DriveOversizeUploadDialogStyle.surfaceShadow,
            ),
            child: SafeArea(top: false, child: body),
          ),
        ),
      );

  /// Safe to call when nothing is open — `Get.isDialogOpen` guards a double pop.
  static void close() {
    if (Get.isDialogOpen == true) Get.back();
  }
}
