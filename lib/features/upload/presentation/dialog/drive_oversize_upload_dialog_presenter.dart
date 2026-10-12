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

  static Object? _owner;

  /// True while a batch's dialog is on screen.
  static bool get isShowing => _owner != null;

  /// Opens the batch dialog for [owner]. Modal, opaque barrier, no dismiss — this is what
  /// blocks every user input for the Drive path. Chips are untouched.
  /// Completes when the route is removed, by [close] or by anything else.
  static Future<void> show(ProviderContainer container, {required Object owner}) {
    _owner = owner;
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

    final surface = LinagoraFileTransferSurface(
      layout: isWebLayout
          ? LinagoraFileTransferLayout.wide
          : LinagoraFileTransferLayout.compact,
      semanticLabel: Get.context == null
          ? null
          : AppLocalizations.of(Get.context!).attachingFileTitle,
      child: body,
    );

    return Get.dialog<void>(
      PopScope(
        canPop: false,
        // The sheet pads its own bottom/sides so its background reaches the screen edge.
        child: isWebLayout
            ? surface
            : SafeArea(bottom: false, left: false, right: false, child: surface),
      ),
      barrierDismissible: false,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      useSafeArea: isWebLayout,
    ).whenComplete(() {
      if (identical(_owner, owner)) _owner = null;
    });
  }

  /// Pops only [owner]'s dialog, so a batch that outlived its dialog never closes the next one.
  static void close(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    if (Get.isDialogOpen == true) Get.back();
  }
}
