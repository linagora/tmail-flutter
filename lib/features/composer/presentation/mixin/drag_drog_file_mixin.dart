import 'dart:async' as async;
import 'package:async/async.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/x_file_extension.dart';
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
    final files = await _withoutFolders(details.files);
    if (files.isEmpty || !context.mounted) return [];

    final result = await showFutureLoadingDialogFullScreen(
      context: context,
      future: () => async.Future.wait(
        files.map((xFile) => xFile.toFileInfo()),
      ),
    );

    if (result.error != null) return [];

    return result.result ?? [];
  }

  async.Future<List<XFile>> _withoutFolders(List<XFile> files) async {
    final isFolder = await async.Future.wait(
      files.map((xFile) => xFile.isDroppedFolder()),
    );
    return [
      for (var i = 0; i < files.length; i++)
        if (!isFolder[i]) files[i],
    ];
  }
}
