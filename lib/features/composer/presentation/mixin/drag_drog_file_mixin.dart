import 'dart:async' as async;
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
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
}
