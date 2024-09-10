import 'dart:io';

import 'package:core/domain/extensions/media_type_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/main/exceptions/storage_permission_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/permissions/permission_dialog.dart';
import 'package:tmail_ui_user/main/permissions/storage_permission_service.dart';

typedef OnSaveCallbackAction = Function(bool isSuccess);

mixin SaveMediaToGalleryMixin {
  Future<void> handleAndroidStoragePermission(BuildContext context) async {
    if (await StoragePermissionService().isUserHaveToRequestStoragePermissionAndroid()) {
      final permission = await Permission.storage.request();

      if (permission.isPermanentlyDenied && context.mounted) {
        showDialog(
          useRootNavigator: false,
          context: context,
          builder: (_) {
            return PermissionDialog(
              icon: const Icon(Icons.storage_rounded),
              permission: Permission.storage,
              explainTextRequestPermission: Text(
                AppLocalizations.of(context).explainPermissionToDownloadFiles(
                  AppLocalizations.of(context).app_name,
                ),
              ),
              onAcceptButton: () =>
                  StoragePermissionService().goToSettingsForPermissionActions(),
            );
          },
        );
      }

      if (!permission.isGranted) {
        log('SaveMediaToGalleryMixin::handleAndroidStoragePermission: Permission Denied');
        throw StoragePermissionException("Don't have permission to save file");
      }
    }
  }

  Future<void> handlePhotoPermissionIOS(BuildContext context) async {
    final permissionStatus = await StoragePermissionService().requestPhotoAddOnlyPermissionIOS();
    if (permissionStatus.isPermanentlyDenied && context.mounted) {
      showDialog(
        useRootNavigator: false,
        context: context,
        builder: (_) {
          return PermissionDialog(
            icon: const Icon(Icons.photo),
            permission: Permission.photos,
            explainTextRequestPermission: Text(
              AppLocalizations.of(context).explainPermissionToGallery(
                AppLocalizations.of(context).app_name,
              ),
            ),
            onAcceptButton: () =>
                StoragePermissionService().goToSettingsForPermissionActions(),
          );
        },
      );
    }
    if (!permissionStatus.isGranted) {
      throw StoragePermissionException('Permission denied');
    }
  }

  Future<void> saveMediaToGallery({
    required File fileInDownloadsInApp,
    required MediaType mediaType,
    OnSaveCallbackAction? onSaveCallbackAction
  }) async {
    if (mediaType.isImageFile()) {
      await saveImageToGallery(file: fileInDownloadsInApp);
    } else if (mediaType.isVideoFile()) {
      await saveVideoToGallery(file: fileInDownloadsInApp);
    } else {
      return;
    }
    onSaveCallbackAction?.call(true);
  }

  Future<void> saveImageToGallery({
    required File file,
  }) async {
   log('SaveMediaToGalleryMixin::saveImageToGallery:file path: ${file.path}');
    await Gal.putImage(file.path);
  }

  Future<void> saveVideoToGallery({
    required File file,
  }) async {
    log('SaveMediaToGalleryMixin::saveVideoToGallery:file path: ${file.path}');
    await Gal.putVideo(file.path);
  }


  Future<void> saveToGallery({
    required BuildContext context,
    required String filePath,
    required MediaType mediaType,
    OnSaveCallbackAction? onSaveCallbackAction
  }) async {
    try {
      if (PlatformInfo.isAndroid) {
        await handleAndroidStoragePermission(context);
      } else if (PlatformInfo.isIOS) {
        await handlePhotoPermissionIOS(context);
      } else {
        return;
      }

      final fileInDownloadsInApp = File(filePath);

      if (context.mounted) {
        await saveMediaToGallery(
          mediaType: mediaType,
          fileInDownloadsInApp: fileInDownloadsInApp,
          onSaveCallbackAction: onSaveCallbackAction
        );
      }

    } catch (e) {
     logError('SaveMediaToGalleryMixin::saveSelectedEventToGallery: $e');
      if (e is! StoragePermissionException) {
        onSaveCallbackAction?.call(false);
      }
    }
  }
}
