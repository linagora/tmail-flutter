import 'dart:async' as async;
import 'package:async/async.dart';
import 'package:core/data/constants/constant.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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
    final bytesList = await showFutureLoadingDialogFullScreen(
      context: context,
      future: () => async.Future.wait(
        details.files.map(
          (xFile) => xFile.readAsBytes(),
        ),
      ),
    );

    if (bytesList.error != null) return [];

    final listFileInfo = <FileInfo>[];
    for (var i = 0; i < bytesList.result!.length; i++) {
      listFileInfo.add(
        FileInfo(
          bytes: bytesList.result![i],
          fileName: details.files[i].name,
          type: details.files[i].mimeType,
          fileSize: bytesList.result![i].length,
          isInline: details.files[i].mimeType?.startsWith(Constant.imageType) == true
        ),
      );
    }
    return listFileInfo;
  }
}
