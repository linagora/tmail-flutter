enum ShownAccountLoadKind { folders, emailList }

class ShownAccountLoad {
  final int attemptId;
  final Future<ShownAccountLoadResult> result;

  const ShownAccountLoad({required this.attemptId, required this.result});
}

sealed class ShownAccountLoadResult {
  const ShownAccountLoadResult();
}

class ShownAccountLoaded extends ShownAccountLoadResult {
  const ShownAccountLoaded();
}

/// The last result was a failure, or the stream threw.
class ShownAccountLoadFailed extends ShownAccountLoadResult {
  final Object error;
  final StackTrace? stackTrace;

  const ShownAccountLoadFailed(this.error, [this.stackTrace]);
}

/// Its switch attempt ended first, so its results never reached the view.
class ShownAccountLoadDropped extends ShownAccountLoadResult {
  const ShownAccountLoadDropped();
}
