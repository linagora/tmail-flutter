import 'dart:async';

import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_load.dart';

class ShownAccountLoadException implements Exception {
  final Object error;

  const ShownAccountLoadException(this.error);

  @override
  String toString() => 'ShownAccountLoadException: $error';
}

/// Keeps the loads of the latest switch attempt only.
class ShownAccountLoadTracker {
  _AttemptLoads? _latest;

  void reportFolders(ShownAccountLoad folders) => _loadsOf(folders.attemptId)?.reportFolders(folders.result);

  void reportEmailList(ShownAccountLoad emailList) =>
      _loadsOf(emailList.attemptId)?.emailList = emailList.result;

  bool hasFoldersLoad(int attemptId) => _latest?.attemptId == attemptId && _latest!.folders != null;

  /// The folders report the email list they open before their own load completes.
  Future<void> waitFor(int attemptId) async {
    final loads = _loadsOf(attemptId);
    if (loads == null) return;

    _throwIfFailed(await loads.latestFolders());
    final emailList = loads.emailList;
    if (emailList != null) _throwIfFailed(await emailList);
  }

  _AttemptLoads? _loadsOf(int attemptId) {
    final latest = _latest;
    if (latest != null && latest.attemptId > attemptId) return null;
    if (latest?.attemptId == attemptId) return latest;
    return _latest = _AttemptLoads(attemptId);
  }

  void _throwIfFailed(ShownAccountLoadResult result) {
    if (result is ShownAccountLoadFailed) {
      Error.throwWithStackTrace(ShownAccountLoadException(result.error), result.stackTrace ?? StackTrace.current);
    }
  }
}

class _AttemptLoads {
  final int attemptId;
  final _foldersReported = Completer<void>();
  Future<ShownAccountLoadResult>? folders;
  Future<ShownAccountLoadResult>? emailList;

  _AttemptLoads(this.attemptId);

  void reportFolders(Future<ShownAccountLoadResult> folderLoad) {
    folders = folderLoad;
    if (!_foldersReported.isCompleted) _foldersReported.complete();
  }

  Future<ShownAccountLoadResult> latestFolders() async {
    await _foldersReported.future;
    Future<ShownAccountLoadResult> awaited;
    ShownAccountLoadResult result;
    do {
      awaited = folders!;
      result = await awaited;
    } while (!identical(awaited, folders));
    return result;
  }
}
