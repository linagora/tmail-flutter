
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

typedef UpdateFileUploadingState = UploadFileState? Function(UploadFileState? currentState);
typedef MatchedState = bool Function(UploadFileState? state);

class UploadFileStateList {

  final List<UploadFileState?> _uploadingStateFiles = <UploadFileState?>[];

  /// Keeps by-id access O(1): a batch of N drive transfers resolves one chip at
  /// a time, so a linear scan per resolution would make the batch O(N²).
  /// Holds the first index for a taskId, matching the old scan semantics.
  final Map<UploadTaskId, int> _indexByTaskId = <UploadTaskId, int>{};

  List<UploadFileState?> get uploadingStateFiles => _uploadingStateFiles.toList(growable: false);

  UploadFileStateList add(UploadFileState element) {
    _indexByTaskId.putIfAbsent(element.uploadTaskId, () => _uploadingStateFiles.length);
    _uploadingStateFiles.add(element);
    return this;
  }

  UploadFileStateList addAll(Iterable<UploadFileState> elements) {
    for (final element in elements) {
      add(element);
    }
    return this;
  }

  UploadFileStateList updateElementBy(
    MatchedState matchedState,
    UpdateFileUploadingState updateFileUploadingState,
  ) {
    final matchIndex = _uploadingStateFiles.indexWhere((element) => matchedState(element));
    if (matchIndex >= 0) {
      _replaceAt(matchIndex, updateFileUploadingState(_uploadingStateFiles[matchIndex]));
    }
    return this;
  }

  UploadFileStateList updateElementByUploadTaskId(
    UploadTaskId uploadTaskId,
    UpdateFileUploadingState updateFileUploadingState,
  ) {
    final matchIndex = _indexByTaskId[uploadTaskId];
    if (matchIndex != null) {
      _replaceAt(matchIndex, updateFileUploadingState(_uploadingStateFiles[matchIndex]));
    }
    return this;
  }

  bool get allSuccess {
    if (_uploadingStateFiles.isEmpty) {
      return false;
    }
    return _uploadingStateFiles
        .every((file) => file?.uploadStatus == UploadFileStatus.succeed);
  }

  void clear() {
    _uploadingStateFiles.clear();
    _indexByTaskId.clear();
  }

  /// Cancels every pending upload/drive-transfer token before dropping them,
  /// so in-flight requests don't keep running after the list is torn down.
  void cancelAll() {
    for (final fileState in _uploadingStateFiles) {
      fileState?.cancelToken?.cancel();
    }
    clear();
  }

  void deleteElementByUploadTaskId(UploadTaskId uploadTaskId) {
    final matchIndex = _indexByTaskId[uploadTaskId];
    if (matchIndex == null) return;

    _uploadingStateFiles[matchIndex]?.cancelToken?.cancel();
    _uploadingStateFiles.removeAt(matchIndex);
    _reindex();
  }

  UploadFileState? getUploadFileStateById(UploadTaskId uploadTaskId) {
    final matchIndex = _indexByTaskId[uploadTaskId];
    return matchIndex == null ? null : _uploadingStateFiles[matchIndex];
  }

  /// Swaps in [newState], reindexing only when the swap changes which taskId
  /// sits at [index].
  void _replaceAt(int index, UploadFileState? newState) {
    final previousTaskId = _uploadingStateFiles[index]?.uploadTaskId;
    _uploadingStateFiles[index] = newState;
    if (newState?.uploadTaskId != previousTaskId) {
      _reindex();
    }
  }

  void _reindex() {
    _indexByTaskId.clear();
    _uploadingStateFiles.forEachIndexed((index, fileState) {
      if (fileState != null) {
        _indexByTaskId.putIfAbsent(fileState.uploadTaskId, () => index);
      }
    });
  }

  @visibleForTesting
  void addNullableForTest(UploadFileState? state) {
    if (state == null) {
      _uploadingStateFiles.add(null);
    } else {
      add(state);
    }
  }
}
