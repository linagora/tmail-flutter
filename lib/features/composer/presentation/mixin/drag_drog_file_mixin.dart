import 'dart:async' as async;
import 'package:async/async.dart';
import 'package:core/data/constants/constant.dart';
import 'package:core/utils/platform_info.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import 'file_size_reader_stub.dart'
    if (dart.library.io) 'file_size_reader_io.dart';

@visibleForTesting
Future<FileInfo> fileInfoFromDroppedFile(dynamic xFile) async {
  // desktop_drop uses XFile (from cross_file). Keep this helper dynamic to avoid
  // relying on transitive imports in production code.
  final String name = xFile.name as String;
  final String? mimeType = xFile.mimeType as String?;
  final String path = (xFile.path as String?) ?? '';
  final bool isInline = mimeType?.startsWith(Constant.imageType) == true;

  // Prefer file path on non-web to avoid loading entire files into memory.
  if (!PlatformInfo.isWeb && path.isNotEmpty) {
    final size = await readFileLength(path);
    return FileInfo(
      fileName: name,
      fileSize: size,
      filePath: path,
      type: mimeType,
      isInline: isInline,
    );
  }

  final bytes = await xFile.readAsBytes();
  return FileInfo(
    bytes: bytes,
    fileName: name,
    type: mimeType,
    fileSize: bytes.length,
    isInline: isInline,
  );
}

mixin DragDropFileMixin {
  async.Future<Result<T>> showFutureLoadingDialogFullScreen<T>({
    required BuildContext context,
    required async.Future<T> Function() future,
  }) async {
    return await showFutureLoadingDialog(
      context: context,
      title: AppLocalizations.of(context).loadingPleaseWait,
      backLabel: AppLocalizations.of(context).close,
      future: future,
    );
  }

  async.Future<List<FileInfo>> onDragDone({
    required BuildContext context,
    required DropDoneDetails details
  }) async {
    final result = await showFutureLoadingDialogFullScreen<List<FileInfo>>(
      context: context,
      // Avoid Future.wait(readAsBytes) which loads all dropped files into RAM at once.
      future: () async {
        final listFileInfo = <FileInfo>[];
        for (final xFile in details.files) {
          listFileInfo.add(await fileInfoFromDroppedFile(xFile));
        }
        return listFileInfo;
      },
    );

    if (result.error != null) return [];
    return result.result ?? [];
  }
}
